from __future__ import annotations

import re

import pandas as pd

from charts import suggest_chart
from insights import build_insights, detect_view
from kpi_queries import match_kpi_sql
from memory import resolve_follow_up
from retriever import retrieve_context
from sql_guard import SqlGuardError, validate_sql
from db import run_query
from text_to_sql import explain_from_docs, format_kpi_value_answer, generate_sql, summarize_answer


def _is_definition_question(question: str) -> bool:
    lowered = question.lower()
    definition_patterns = (
        r"\bwhat does\b.*\bmean\b",
        r"\bdefine\b",
        r"\bexplain\b",
        r"\bmeaning of\b",
        r"\bhow is .* calculated\b",
        r"\bhow do you calculate\b",
    )
    return any(re.search(pattern, lowered) for pattern in definition_patterns)


def answer_question(question: str, history: list[dict] | None = None) -> dict:
    history = history or []
    question = question.strip()
    if not question:
        return {
            "mode": "error",
            "answer": "Please enter a question.",
            "sql": None,
            "rows": [],
            "columns": [],
            "steps": [],
            "chart": None,
            "resolved_question": question,
        }

    resolved_question = resolve_follow_up(question, history)
    steps: list[str] = ["Understand question"]
    if resolved_question != question:
        steps.append(f"Conversation memory applied: '{question}' -> '{resolved_question}'")

    context = retrieve_context(resolved_question, k=5)
    steps.append("Retrieve RAG context")

    if _is_definition_question(resolved_question):
        answer = explain_from_docs(resolved_question, context)
        steps.extend(build_agent_steps("explain", None, None)[2:])
        return {
            "mode": "explain",
            "answer": answer,
            "sql": None,
            "rows": [],
            "columns": [],
            "steps": steps,
            "chart": None,
            "resolved_question": resolved_question,
        }

    raw_sql = match_kpi_sql(resolved_question)
    if raw_sql is None:
        steps.append("Select view via LLM + RAG context")
        raw_sql = generate_sql(resolved_question, context)
        if "EXPLAIN_ONLY" in raw_sql.upper():
            answer = explain_from_docs(resolved_question, context)
            steps.extend(build_agent_steps("explain", None, None)[2:])
            return {
                "mode": "explain",
                "answer": answer,
                "sql": None,
                "rows": [],
                "columns": [],
                "steps": steps,
                "chart": None,
                "resolved_question": resolved_question,
            }
    else:
        steps.append("Select view: semantic.vw_ride_kpis_daily (KPI template)")

    view = detect_view(raw_sql)
    if view and "Select view" not in steps[-1]:
        steps.append(f"Selected semantic view: {view}")

    try:
        steps.extend(["Generate SQL", "Validate SQL with sql_guard"])
        safe_sql = validate_sql(raw_sql)
        steps.append("Execute on SQL Server")
        columns, rows = run_query(safe_sql)

        kpi_answer = format_kpi_value_answer(resolved_question, columns, rows)
        if kpi_answer:
            base_answer = kpi_answer
        else:
            base_answer = summarize_answer(resolved_question, safe_sql, columns, rows)

        steps.append("Analyze results and generate insights")
        answer, insight_lines = build_insights(
            resolved_question, safe_sql, columns, rows, base_answer
        )

        chart = None
        if rows:
            df = pd.DataFrame(rows, columns=columns)
            chart = suggest_chart(df)

        return {
            "mode": "query",
            "answer": answer,
            "sql": safe_sql,
            "rows": rows,
            "columns": columns,
            "steps": steps,
            "insights": insight_lines,
            "chart": chart,
            "resolved_question": resolved_question,
        }
    except SqlGuardError as exc:
        return {
            "mode": "error",
            "answer": f"SQL guard blocked the generated query: {exc}",
            "sql": raw_sql,
            "rows": [],
            "columns": [],
            "steps": steps,
            "chart": None,
            "resolved_question": resolved_question,
        }
    except Exception as exc:
        return {
            "mode": "error",
            "answer": f"Query failed: {exc}",
            "sql": raw_sql,
            "rows": [],
            "columns": [],
            "steps": steps,
            "chart": None,
            "resolved_question": resolved_question,
        }

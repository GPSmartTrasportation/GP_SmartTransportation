from __future__ import annotations

from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import AzureChatOpenAI, ChatOpenAI

from config import (
    AZURE_OPENAI_API_KEY,
    AZURE_OPENAI_BASE_URL,
    AZURE_OPENAI_DEPLOYMENT_CHAT,
    AZURE_OPENAI_ENDPOINT,
    AZURE_OPENAI_API_VERSION,
    AZURE_OPENAI_USE_V1,
    LLM_PROVIDER,
    OPENAI_API_KEY,
    OPENAI_MODEL,
)
from sql_guard import allowed_relations


def get_chat_model():
    if LLM_PROVIDER == "azure":
        if AZURE_OPENAI_USE_V1:
            return ChatOpenAI(
                base_url=AZURE_OPENAI_BASE_URL,
                api_key=AZURE_OPENAI_API_KEY,
                model=AZURE_OPENAI_DEPLOYMENT_CHAT,
                temperature=0,
            )

        return AzureChatOpenAI(
            azure_endpoint=AZURE_OPENAI_ENDPOINT,
            api_key=AZURE_OPENAI_API_KEY,
            azure_deployment=AZURE_OPENAI_DEPLOYMENT_CHAT,
            api_version=AZURE_OPENAI_API_VERSION,
            temperature=0,
        )

    return ChatOpenAI(model=OPENAI_MODEL, api_key=OPENAI_API_KEY, temperature=0)


SQL_PROMPT = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            """You are a SQL Server analytics assistant for Massar Smart Transportation.
Generate exactly ONE read-only T-SQL SELECT query.

Rules:
- Use only these relations: {allowed_relations}
- Prefer fully qualified names like semantic.vw_ride_kpis_daily
- No INSERT, UPDATE, DELETE, DDL, EXEC, temp tables, or CTEs that write data
- No semicolons, no comments, no explanation — SQL only
- Use TOP when returning raw rows
- Use T-SQL syntax compatible with SQL Server
- For KPI rate questions, compute percentages the same way as Power BI:
  completion rate = CAST(SUM(completed_ride_count) AS FLOAT) / NULLIF(SUM(ride_count), 0) * 100
  cancellation rate = CAST(SUM(cancelled_ride_count) AS FLOAT) / NULLIF(SUM(ride_count), 0) * 100
- Prefer vw_ride_kpis_daily for completion rate, cancellation rate, total rides, revenue
- If the user asks ONLY for a KPI definition (not the current value), return: SELECT 'EXPLAIN_ONLY' AS mode

Context from documentation:
{context}
""",
        ),
        ("human", "{question}"),
    ]
)


SUMMARY_PROMPT = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            """You are a transport analytics assistant for Massar (Egypt).
Answer clearly using the SQL result. Mention domain, date, zone, or occasion when relevant.
If the result is empty, say no matching data was found.
Do not invent numbers not present in the result.
For rate/percentage KPIs, show the value as a percentage with 2 decimal places (example: 87.35%).""",
        ),
        (
            "human",
            """Question: {question}

SQL executed:
{sql}

Result columns: {columns}
Result rows (sample): {rows}

Write a concise business answer.""",
        ),
    ]
)


EXPLAIN_PROMPT = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            """You are a transport analytics assistant for Massar Smart Transportation.
Explain KPIs and business rules using only the provided documentation context.
If the answer is not in the context, say you do not have enough documentation.""",
        ),
        ("human", "Context:\n{context}\n\nQuestion:\n{question}"),
    ]
)


INSIGHT_PROMPT = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            """You are an agentic analytics assistant for Massar Smart Transportation.
Write ONE short insight sentence based only on the SQL result.
Prefer comparisons, trends, peaks, or anomalies.
If the result is a single KPI value, compare it qualitatively only when obvious from the numbers.
Do not invent data. Example: "Cancellation rate increased by 3.2 percentage points compared with the previous month."
""",
        ),
        (
            "human",
            """Question: {question}
SQL: {sql}
Columns: {columns}
Rows: {rows}

Insight:""",
        ),
    ]
)


def generate_agent_insights(
    question: str, sql: str, columns: list[str], rows: list[tuple]
) -> str:
    if not rows:
        return ""
    chain = INSIGHT_PROMPT | get_chat_model() | StrOutputParser()
    return chain.invoke(
        {
            "question": question,
            "sql": sql,
            "columns": columns,
            "rows": rows,
        }
    ).strip()


def generate_sql(question: str, context: str) -> str:
    chain = SQL_PROMPT | get_chat_model() | StrOutputParser()
    return chain.invoke(
        {
            "question": question,
            "context": context,
            "allowed_relations": ", ".join(allowed_relations()),
        }
    ).strip()


def summarize_answer(question: str, sql: str, columns: list[str], rows: list[tuple]) -> str:
    preview_rows = rows[:20]
    chain = SUMMARY_PROMPT | get_chat_model() | StrOutputParser()
    return chain.invoke(
        {
            "question": question,
            "sql": sql,
            "columns": columns,
            "rows": preview_rows,
        }
    ).strip()


def explain_from_docs(question: str, context: str) -> str:
    chain = EXPLAIN_PROMPT | get_chat_model() | StrOutputParser()
    return chain.invoke({"question": question, "context": context}).strip()


def format_kpi_value_answer(
    question: str, columns: list[str], rows: list[tuple]
) -> str | None:
    """Format single-row KPI results as a percentage/value answer (Power BI style)."""
    if not rows or len(rows) != 1:
        return None

    row = dict(zip(columns, rows[0], strict=False))

    if "completion_rate_pct" in row and row["completion_rate_pct"] is not None:
        rate = float(row["completion_rate_pct"])
        total = row.get("total_rides")
        completed = row.get("completed_rides")
        return (
            f"**Completion Rate: {rate:.2f}%**\n\n"
            f"Based on **{int(completed):,}** completed rides out of **{int(total):,}** total rides "
            f"(same formula as Power BI: completed ÷ total × 100)."
        )

    if "cancellation_rate_pct" in row and row["cancellation_rate_pct"] is not None:
        rate = float(row["cancellation_rate_pct"])
        total = row.get("total_rides")
        cancelled = row.get("cancelled_rides")
        return (
            f"**Cancellation Rate: {rate:.2f}%**\n\n"
            f"Based on **{int(cancelled):,}** cancelled rides out of **{int(total):,}** total rides."
        )

    if "total_rides" in row and row["total_rides"] is not None and len(row) <= 4:
        total = int(row["total_rides"])
        parts = [f"**Total Rides: {total:,}**"]
        if row.get("completed_rides") is not None:
            parts.append(f"Completed: {int(row['completed_rides']):,}")
        if row.get("cancelled_rides") is not None:
            parts.append(f"Cancelled: {int(row['cancelled_rides']):,}")
        return "\n\n".join(parts)

    if "avg_minutes_to_accept" in row and row["avg_minutes_to_accept"] is not None:
        return f"**Average Minutes to Accept: {float(row['avg_minutes_to_accept']):.2f}** minutes"

    if "total_net_revenue" in row and row["total_net_revenue"] is not None:
        return f"**Total Net Revenue: {float(row['total_net_revenue']):,.2f}**"

    return None

from __future__ import annotations

import re

import pandas as pd

from text_to_sql import generate_agent_insights


def _detect_view(sql: str | None) -> str | None:
    if not sql:
        return None
    match = re.search(r"\b(vw_[a-z0-9_]+)\b", sql, flags=re.IGNORECASE)
    return match.group(1) if match else None


detect_view = _detect_view


def _month_over_month_rate_insight(df: pd.DataFrame, rate_col: str) -> str | None:
    if "month_number" not in df.columns or rate_col not in df.columns or len(df) < 2:
        return None

    ordered = df.sort_values("month_number")
    latest = ordered.iloc[-1]
    previous = ordered.iloc[-2]
    latest_rate = float(latest[rate_col])
    previous_rate = float(previous[rate_col])
    delta = latest_rate - previous_rate
    direction = "increased" if delta > 0 else "decreased" if delta < 0 else "remained unchanged"
    month = int(latest["month_number"])
    prev_month = int(previous["month_number"])
    return (
        f"Insight: {rate_col.replace('_', ' ')} {direction} by "
        f"**{abs(delta):.2f} percentage points** from month {prev_month} "
        f"({previous_rate:.2f}%) to month {month} ({latest_rate:.2f}%)."
    )


def _trend_insight(df: pd.DataFrame, metric_col: str) -> str | None:
    if "month_number" not in df.columns or metric_col not in df.columns or len(df) < 2:
        return None

    ordered = df.sort_values("month_number")
    first = float(ordered.iloc[0][metric_col])
    last = float(ordered.iloc[-1][metric_col])
    if first == 0:
        return None
    change_pct = ((last - first) / first) * 100
    direction = "increased" if change_pct > 0 else "decreased" if change_pct < 0 else "remained flat"
    return (
        f"Insight: {metric_col.replace('_', ' ')} {direction} by "
        f"**{abs(change_pct):.1f}%** from the first to the last month in the result."
    )


def build_insights(
    question: str,
    sql: str,
    columns: list[str],
    rows: list[tuple],
    base_answer: str,
) -> tuple[str, list[str]]:
    insight_lines: list[str] = []
    df = pd.DataFrame(rows, columns=columns) if rows else pd.DataFrame()

    if not df.empty:
        for rate_col in ("cancellation_rate_pct", "completion_rate_pct"):
            if rate_col in df.columns:
                local = _month_over_month_rate_insight(df, rate_col)
                if local:
                    insight_lines.append(local)

        for metric_col in ("total_rides", "ride_count", "cancelled_ride_count"):
            if metric_col in df.columns:
                local = _trend_insight(df, metric_col)
                if local:
                    insight_lines.append(local)
                    break

    llm_insight = generate_agent_insights(question, sql, columns, rows[:20])
    if llm_insight:
        insight_lines.append(llm_insight)

    if not insight_lines:
        return base_answer, []

    combined = base_answer + "\n\n" + "\n\n".join(f"📊 {line}" for line in insight_lines)
    return combined, insight_lines


def build_agent_steps(mode: str, sql: str | None, view: str | None) -> list[str]:
    steps = ["Understand question", "Retrieve RAG context"]
    if mode == "explain":
        steps.append("Route: KPI definition / explanation")
        steps.append("Answer from documentation")
        return steps

    steps.append("Route: analytics query")
    if view:
        steps.append(f"Selected semantic view: {view}")
    steps.append("Generate SQL")
    steps.append("Validate SQL with sql_guard")
    steps.append("Execute on SQL Server")
    steps.append("Analyze results and generate insights")
    return steps

from __future__ import annotations

import re

from config import DB_SCHEMA


def _time_filter_sql(question: str) -> str:
    lowered = question.lower()
    conditions: list[str] = []

    year_match = re.search(r"\b(20\d{2})\b", question)
    if year_match:
        conditions.append(f"year = {int(year_match.group(1))}")

    if "ramadan" in lowered:
        conditions.append("occasion = 'Ramadan'")
    elif "eid al-fitr" in lowered or "eid al fitr" in lowered:
        conditions.append("occasion = 'Eid al-Fitr'")
    elif "eid al-adha" in lowered or "eid al adha" in lowered:
        conditions.append("occasion = 'Eid al-Adha'")

    if re.search(r"\blast month\b", lowered):
        conditions.append(
            "full_date >= DATEADD(month, DATEDIFF(month, 0, GETDATE()) - 1, 0) "
            "AND full_date < DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)"
        )
    elif re.search(r"\bthis month\b", lowered):
        conditions.append(
            "full_date >= DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0) "
            "AND full_date < DATEADD(month, DATEDIFF(month, 1, GETDATE()), 0)"
        )

    if not conditions:
        return ""
    return " WHERE " + " AND ".join(conditions)


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


def match_kpi_sql(question: str) -> str | None:
    """
    Return Power BI-aligned KPI SQL when the user asks for a KPI value.
    Returns None for definition-only questions or unmatched KPIs.
    """
    if _is_definition_question(question):
        return None

    lowered = question.lower()
    view = f"{DB_SCHEMA}.vw_ride_kpis_daily"
    where_clause = _time_filter_sql(question)

    kpi_patterns: list[tuple[str, str]] = [
        (
            r"\bcompletion rate\b",
            f"""SELECT TOP 1
    CAST(SUM(completed_ride_count) AS FLOAT) / NULLIF(SUM(ride_count), 0) * 100 AS completion_rate_pct,
    SUM(ride_count) AS total_rides,
    SUM(completed_ride_count) AS completed_rides
FROM {view}{where_clause}""",
        ),
        (
            r"\bcancellation rate\b",
            f"""SELECT TOP 1
    CAST(SUM(cancelled_ride_count) AS FLOAT) / NULLIF(SUM(ride_count), 0) * 100 AS cancellation_rate_pct,
    SUM(ride_count) AS total_rides,
    SUM(cancelled_ride_count) AS cancelled_rides
FROM {view}{where_clause}""",
        ),
        (
            r"\btotal rides\b|\bhow many rides\b",
            f"""SELECT TOP 1
    SUM(ride_count) AS total_rides,
    SUM(completed_ride_count) AS completed_rides,
    SUM(cancelled_ride_count) AS cancelled_rides
FROM {view}{where_clause}""",
        ),
        (
            r"\bavg.*minutes to accept\b|\baverage minutes to accept\b",
            f"""SELECT TOP 1
    AVG(avg_minutes_to_accept) AS avg_minutes_to_accept
FROM {view}{where_clause}""",
        ),
        (
            r"\bnet revenue\b|\btotal net revenue\b",
            f"""SELECT TOP 1
    SUM(total_net_revenue) AS total_net_revenue
FROM {view}{where_clause}""",
        ),
    ]

    asks_for_value = any(
        re.search(pattern, lowered)
        for pattern in (
            r"\bwhat is\b",
            r"\bwhat's\b",
            r"\bwhat was\b",
            r"\bshow me\b",
            r"\btell me\b",
            r"\bcurrent\b",
            r"\brate\b",
            r"\bhow many\b",
            r"\btotal\b",
            r"\baverage\b",
            r"\bavg\b",
        )
    )

    if not asks_for_value:
        return None

    for pattern, sql in kpi_patterns:
        if re.search(pattern, lowered):
            return sql

    return None

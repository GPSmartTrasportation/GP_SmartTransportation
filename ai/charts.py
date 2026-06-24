from __future__ import annotations

import pandas as pd


def suggest_chart(df: pd.DataFrame) -> dict | None:
    """Return chart config for Streamlit when the result looks chartable."""
    if df.empty or len(df.columns) < 2:
        return None

    cols = {col.lower(): col for col in df.columns}
    numeric_cols = [col for col in df.columns if pd.api.types.is_numeric_dtype(df[col])]

    time_candidates = [
        cols.get(name)
        for name in ("month_number", "full_date", "cancelled_date", "rating_date", "hour_24")
        if cols.get(name)
    ]
    metric_candidates = [
        col
        for col in numeric_cols
        if col.lower()
        in {
            "total_rides",
            "ride_count",
            "completed_ride_count",
            "cancelled_ride_count",
            "completion_rate_pct",
            "cancellation_rate_pct",
            "total_net_revenue",
            "avg_minutes_to_accept",
            "rating_count",
        }
        or "total" in col.lower()
        or "count" in col.lower()
        or "rate" in col.lower()
    ]

    category_candidates = [
        cols.get(name)
        for name in (
            "pickup_zone_name",
            "pickup_city_name",
            "reason_title",
            "domain_name",
            "rater_role",
            "period_of_day",
        )
        if cols.get(name)
    ]

    if time_candidates and metric_candidates and len(df) >= 2:
        x_col = time_candidates[0]
        y_cols = metric_candidates[:3]
        chart_type = "line" if x_col.lower() in {"month_number", "hour_24", "full_date"} else "line"
        return {"type": chart_type, "x": x_col, "y": y_cols}

    if category_candidates and metric_candidates and len(df) <= 20:
        x_col = category_candidates[0]
        y_col = metric_candidates[0]
        return {"type": "bar", "x": x_col, "y": [y_col]}

    return None

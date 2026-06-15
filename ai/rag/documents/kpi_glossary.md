# Massar AI — KPI Glossary

## Completion Rate
- **Formula (Power BI aligned):** `SUM(completed_ride_count) / SUM(ride_count) * 100`
- **Source view:** `semantic.vw_ride_kpis_daily`
- **When user asks "What is completion rate?"** → run SQL and return the percentage value, not just the definition.
- **Example SQL:**
```sql
SELECT TOP 1
  CAST(SUM(completed_ride_count) AS FLOAT) / NULLIF(SUM(ride_count), 0) * 100 AS completion_rate_pct,
  SUM(ride_count) AS total_rides,
  SUM(completed_ride_count) AS completed_rides
FROM semantic.vw_ride_kpis_daily
```

## Cancellation Rate
- **Formula (Power BI aligned):** `SUM(cancelled_ride_count) / SUM(ride_count) * 100`
- **Source views:** `semantic.vw_ride_kpis_daily`, `semantic.vw_cancellation_summary`
- **Notes:** For reason-level analysis, use `vw_cancellation_summary`.

## Total Rides
- **Definition:** Count of rides requested on a calendar day.
- **Column:** `ride_count` in `semantic.vw_ride_kpis_daily`

## Net Revenue
- **Definition:** Revenue after refunds and discounts.
- **Column:** `total_net_revenue` in `semantic.vw_ride_kpis_daily` and `semantic.vw_zone_demand`

## Average Minutes to Accept
- **Definition:** Average time from ride request to driver acceptance.
- **Columns:** `avg_minutes_to_accept` in `semantic.vw_ride_kpis_daily` and `semantic.vw_ride_sla`

## Average Minutes to Complete
- **Definition:** Average time from driver acceptance to ride completion.
- **Columns:** `avg_minutes_to_complete` in `semantic.vw_ride_kpis_daily` and `semantic.vw_ride_sla`

## Average Actual Duration
- **Definition:** Average actual trip duration in minutes.
- **Columns:** `avg_actual_duration_minutes` in `semantic.vw_ride_kpis_daily` and `semantic.vw_ride_sla`

## Peak Hour
- **Definition:** Request hour flagged as peak demand window.
- **Columns:** `is_peak_hour`, `period_of_day`, `hour_24` in `semantic.vw_ride_sla`

## Zone Demand
- **Definition:** Ride volume by pickup geography.
- **Source view:** `semantic.vw_zone_demand`
- **Columns:** `pickup_zone_name`, `pickup_city_name`, `pickup_governorate_name`, `ride_count`

## Rating Score
- **Definition:** Ride rating score, typically 1 to 5.
- **Source view:** `semantic.vw_rating_summary`
- **Columns:** `score`, `rating_count`, `rater_role`

## Occasion
- **Values:** `Regular Day`, `Ramadan`, `Eid al-Fitr`, `Eid al-Adha`
- **Use for:** Comparing KPIs during religious/holiday periods vs normal days.

## Egypt Weekend
- **Definition:** Friday and Saturday (`is_weekend = 1`).

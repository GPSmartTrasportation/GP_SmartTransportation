# Example Questions and SQL Templates

Use these patterns when generating SQL. Always query `semantic` schema views only.

---

## Explain-only
**Question:** What is completion rate?  
**Answer type:** Explain from KPI glossary — no SQL.

---

## Daily rides in a year
**Question:** Total rides by month in 2025  
```sql
SELECT
    year,
    month_number,
    SUM(ride_count) AS total_rides
FROM semantic.vw_ride_kpis_daily
WHERE year = 2025
GROUP BY year, month_number
ORDER BY month_number
```

---

## Completion vs cancellation in Ramadan
**Question:** Compare completed and cancelled rides during Ramadan 2025  
```sql
SELECT TOP 100
    full_date,
    ride_count,
    completed_ride_count,
    cancelled_ride_count
FROM semantic.vw_ride_kpis_daily
WHERE year = 2025
  AND occasion = 'Ramadan'
ORDER BY full_date
```

---

## Top pickup zones
**Question:** Top 5 pickup zones by ride count last month  
```sql
SELECT TOP 5
    pickup_zone_name,
    pickup_city_name,
    SUM(ride_count) AS total_rides
FROM semantic.vw_zone_demand
WHERE year = 2025
  AND month_number = 4
GROUP BY pickup_zone_name, pickup_city_name
ORDER BY total_rides DESC
```

---

## Cancellation reasons
**Question:** Top cancellation reasons in Cairo zones  
```sql
SELECT TOP 10
    reason_title,
    applies_to,
    SUM(cancelled_ride_count) AS cancelled_rides
FROM semantic.vw_cancellation_summary
WHERE pickup_city_name = 'Cairo'
GROUP BY reason_title, applies_to
ORDER BY cancelled_rides DESC
```

---

## Peak hour SLA
**Question:** Average minutes to accept during peak hours  
```sql
SELECT
    period_of_day,
    AVG(avg_minutes_to_accept) AS avg_minutes_to_accept
FROM semantic.vw_ride_sla
WHERE is_peak_hour = 1
GROUP BY period_of_day
ORDER BY avg_minutes_to_accept
```

---

## Ratings by role
**Question:** Weighted average passenger rating score in 2025  
```sql
SELECT
    rater_role,
    SUM(score * rating_count) * 1.0 / NULLIF(SUM(rating_count), 0) AS weighted_avg_score
FROM semantic.vw_rating_summary
WHERE year = 2025
  AND rater_role = 'Passenger'
GROUP BY rater_role
```

---

## Weekend demand
**Question:** Total rides on Egypt weekends vs weekdays in 2025  
```sql
SELECT
    is_weekend,
    SUM(ride_count) AS total_rides
FROM semantic.vw_ride_kpis_daily
WHERE year = 2025
GROUP BY is_weekend
ORDER BY is_weekend
```

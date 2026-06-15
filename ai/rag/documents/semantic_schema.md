# Massar Semantic Layer — AI Schema Reference

All objects live in schema **`semantic`**. The AI chatbot may query **only** these views.

---

## semantic.vw_ride_kpis_daily
- **Purpose:** Daily ride volume, revenue, and timing KPIs.
- **Grain:** One row per `full_date`.
- **Key columns:** `full_date`, `year`, `month_number`, `quarter`, `day_name`, `is_weekend`, `occasion`, `ride_count`, `completed_ride_count`, `cancelled_ride_count`, `total_amount`, `total_net_revenue`, `total_refund_amount`, `avg_minutes_to_accept`, `avg_minutes_to_complete`, `avg_actual_duration_minutes`
- **Use when:** Questions about daily totals, monthly trends, occasions, revenue, completion/cancellation counts.

---

## semantic.vw_cancellation_summary
- **Purpose:** Cancelled rides by reason, domain, and pickup geography.
- **Grain:** One row per `cancelled_date`, `reason_title`, `applies_to`, `domain_name`, and pickup geography.
- **Key columns:** `cancelled_date`, `occasion`, `reason_title`, `applies_to`, `domain_name`, `pickup_zone_name`, `pickup_city_name`, `pickup_governorate_name`, `cancelled_ride_count`, `avg_minutes_to_accept_before_cancel`
- **Use when:** Top cancellation reasons, domain-specific cancellations, zone-level cancellation patterns.

---

## semantic.vw_zone_demand
- **Purpose:** Pickup-zone demand and revenue by day.
- **Grain:** One row per `full_date` and pickup geography.
- **Key columns:** `full_date`, `occasion`, `pickup_zone_name`, `pickup_city_name`, `pickup_governorate_name`, `ride_count`, `completed_ride_count`, `cancelled_ride_count`, `total_amount`, `total_net_revenue`, `avg_passenger_count`
- **Use when:** Busiest zones/cities/governorates, geographic demand heatmaps in natural language.

---

## semantic.vw_ride_sla
- **Purpose:** SLA and timing KPIs by day and hour bucket.
- **Grain:** One row per `full_date`, `hour_24`, and time bucket fields.
- **Key columns:** `full_date`, `occasion`, `hour_24`, `period_of_day`, `is_peak_hour`, `ride_count`, `completed_ride_count`, `avg_minutes_to_accept`, `avg_minutes_to_complete`, `avg_actual_duration_minutes`, `rides_accepted_within_5_min`, `rides_completed_within_60_min`
- **Use when:** Peak hours, accept-time SLA, completion-time SLA.

---

## semantic.vw_rating_summary
- **Purpose:** Rating distribution without user PII.
- **Grain:** One row per `rating_date`, `rater_role`, and `score`.
- **Key columns:** `rating_date`, `occasion`, `rater_role`, `score`, `rating_count`, `rated_ride_count`
- **Use when:** Passenger vs driver ratings, score distribution, average rating questions.

---

## Query rules for text-to-SQL
- Use T-SQL for SQL Server.
- Prefer fully qualified names: `semantic.vw_ride_kpis_daily`
- Use `SUM`, `AVG`, `COUNT`, `GROUP BY`, `ORDER BY`, `TOP`
- Filter dates with `full_date`, `cancelled_date`, or `rating_date`
- Filter occasions with `occasion = 'Ramadan'` etc.

# Massar Business Rules

## Business Domains
Massar supports multi-domain transport in Egypt:
- **Mobility** — passenger rides
- **Carrier** — parcel / carrier flows
- **Freight** — freight transport

Domain appears on cancellation summaries as `domain_name`. Daily KPI views may aggregate across all domains unless filtered elsewhere.

## Calendar Rules
- Egypt weekend is **Friday and Saturday** (`is_weekend = 1`).
- `occasion` values:
  - `Regular Day`
  - `Ramadan`
  - `Eid al-Fitr`
  - `Eid al-Adha`

Use occasion filters when users ask about holidays, Ramadan, or Eid performance.

## Cancellation Reasons
- `reason_title` — human-readable reason label
- `applies_to` — who the reason applies to (Passenger, Driver, Both, etc.)

Use `vw_cancellation_summary` for reason-level analysis.

## Geography Hierarchy
Pickup geography columns follow:
- `pickup_governorate_name`
- `pickup_city_name`
- `pickup_zone_name`

Use `vw_zone_demand` for location demand questions.

## Ratings
- `rater_role` is typically **Passenger** or **Driver**
- Ratings are stored as discrete `score` values (usually 1 to 5)
- Use weighted average when answering average rating questions:
  `SUM(score * rating_count) / NULLIF(SUM(rating_count), 0)`

## AI Safety Rules
- AI must query **semantic views only**
- No PII columns are exposed in semantic views
- Power BI continues to use mart tables; AI uses semantic views only

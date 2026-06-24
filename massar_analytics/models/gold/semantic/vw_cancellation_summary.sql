/*
  Cancellation KPIs by reason, domain, and pickup zone.
  Grain: cancelled date + reason + preference domain + pickup geography.
  Source: fact_rides + dim_date + dim_cancellation_reason + dim_preference + dim_geography.
*/

with rides as (

    select * from {{ ref('fact_rides') }}
    where is_cancelled = 1

),

dates as (

    select * from {{ ref('dim_date') }}

),

reasons as (

    select * from {{ ref('dim_cancellation_reason') }}

),

preferences as (

    select * from {{ ref('dim_preference') }}

),

zones as (

    select * from {{ ref('dim_geography') }}

),

final as (

    select
        d.full_date as cancelled_date,
        d.year,
        d.month_number,
        d.day_name,
        d.is_weekend,
        d.occasion,
        coalesce(cr.reason_title, 'Unknown') as reason_title,
        coalesce(cr.applies_to, 'Unknown') as applies_to,
        coalesce(p.domain_name, 'Unknown') as domain_name,
        coalesce(z.zone_name_en, 'Unknown') as pickup_zone_name,
        coalesce(z.city_name_en, 'Unknown') as pickup_city_name,
        coalesce(z.governorate_name_en, 'Unknown') as pickup_governorate_name,
        count(*) as cancelled_ride_count,
        avg(cast(r.minutes_to_accept as float)) as avg_minutes_to_accept_before_cancel
    from rides as r
    inner join dates as d
        on r.cancelled_date_key = d.date_key
    left join reasons as cr
        on r.cancellation_reason_key = cr.cancellation_reason_key
    left join preferences as p
        on r.preference_key = p.preference_key
    left join zones as z
        on r.pickup_zone_key = z.zone_key
    group by
        d.full_date,
        d.year,
        d.month_number,
        d.day_name,
        d.is_weekend,
        d.occasion,
        coalesce(cr.reason_title, 'Unknown'),
        coalesce(cr.applies_to, 'Unknown'),
        coalesce(p.domain_name, 'Unknown'),
        coalesce(z.zone_name_en, 'Unknown'),
        coalesce(z.city_name_en, 'Unknown'),
        coalesce(z.governorate_name_en, 'Unknown')

)

select * from final

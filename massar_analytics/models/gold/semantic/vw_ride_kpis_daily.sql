/*
  Daily ride KPIs for AI / text-to-SQL.
  Grain: one row per calendar day (requested_at date).
  Source: fact_rides + dim_date only.
*/

with rides as (

    select * from {{ ref('fact_rides') }}

),

dates as (

    select * from {{ ref('dim_date') }}

),

final as (

    select
        d.full_date,
        d.year,
        d.month_number,
        d.quarter,
        d.day_name,
        d.is_weekend,
        d.occasion,
        count(*) as ride_count,
        sum(cast(r.is_completed as int)) as completed_ride_count,
        sum(cast(r.is_cancelled as int)) as cancelled_ride_count,
        sum(r.amount) as total_amount,
        sum(r.net_revenue) as total_net_revenue,
        sum(r.refund_amount) as total_refund_amount,
        avg(cast(r.minutes_to_accept as float)) as avg_minutes_to_accept,
        avg(cast(r.minutes_to_complete as float)) as avg_minutes_to_complete,
        avg(cast(r.actual_duration_minutes as float)) as avg_actual_duration_minutes
    from rides as r
    inner join dates as d
        on r.requested_date_key = d.date_key
    group by
        d.full_date,
        d.year,
        d.month_number,
        d.quarter,
        d.day_name,
        d.is_weekend,
        d.occasion

)

select * from final

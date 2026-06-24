/*
  Ride SLA / timing KPIs by day and time-of-day bucket.
  Grain: requested date + time period (peak hour flags).
  Source: fact_rides + dim_date + dim_time.
*/

with rides as (

    select * from {{ ref('fact_rides') }}

),

dates as (

    select * from {{ ref('dim_date') }}

),

times as (

    select * from {{ ref('dim_time') }}

),

final as (

    select
        d.full_date,
        d.year,
        d.month_number,
        d.day_name,
        d.is_weekend,
        d.occasion,
        t.hour_24,
        t.period_of_day,
        t.is_peak_hour,
        count(*) as ride_count,
        sum(cast(r.is_completed as int)) as completed_ride_count,
        avg(cast(r.minutes_to_accept as float)) as avg_minutes_to_accept,
        avg(cast(r.minutes_to_complete as float)) as avg_minutes_to_complete,
        avg(cast(r.actual_duration_minutes as float)) as avg_actual_duration_minutes,
        min(r.minutes_to_accept) as min_minutes_to_accept,
        max(r.minutes_to_accept) as max_minutes_to_accept,
        sum(
            case
                when r.minutes_to_accept is not null and r.minutes_to_accept <= 5 then 1
                else 0
            end
        ) as rides_accepted_within_5_min,
        sum(
            case
                when r.minutes_to_complete is not null and r.minutes_to_complete <= 60 then 1
                else 0
            end
        ) as rides_completed_within_60_min
    from rides as r
    inner join dates as d
        on r.requested_date_key = d.date_key
    inner join times as t
        on r.requested_time_key = t.time_key
    group by
        d.full_date,
        d.year,
        d.month_number,
        d.day_name,
        d.is_weekend,
        d.occasion,
        t.hour_24,
        t.period_of_day,
        t.is_peak_hour

)

select * from final

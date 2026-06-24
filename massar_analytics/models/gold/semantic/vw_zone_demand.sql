/*
  Pickup-zone demand KPIs by day.
  Grain: requested date + pickup zone + city + governorate + occasion.
  Source: fact_rides + dim_date + dim_geography.
*/

with rides as (

    select * from {{ ref('fact_rides') }}

),

dates as (

    select * from {{ ref('dim_date') }}

),

zones as (

    select * from {{ ref('dim_geography') }}

),

final as (

    select
        d.full_date,
        d.year,
        d.month_number,
        d.day_name,
        d.is_weekend,
        d.occasion,
        z.zone_name_en as pickup_zone_name,
        z.city_name_en as pickup_city_name,
        z.governorate_name_en as pickup_governorate_name,
        count(*) as ride_count,
        sum(cast(r.is_completed as int)) as completed_ride_count,
        sum(cast(r.is_cancelled as int)) as cancelled_ride_count,
        sum(r.amount) as total_amount,
        sum(r.net_revenue) as total_net_revenue,
        avg(cast(r.passenger_count as float)) as avg_passenger_count
    from rides as r
    inner join dates as d
        on r.requested_date_key = d.date_key
    inner join zones as z
        on r.pickup_zone_key = z.zone_key
    group by
        d.full_date,
        d.year,
        d.month_number,
        d.day_name,
        d.is_weekend,
        d.occasion,
        z.zone_name_en,
        z.city_name_en,
        z.governorate_name_en

)

select * from final

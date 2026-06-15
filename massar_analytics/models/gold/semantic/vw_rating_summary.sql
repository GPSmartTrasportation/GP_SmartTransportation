/*
  Ride rating KPIs by day and rater role.
  Grain: rating date + rater role + score.
  Source: fact_ride_ratings + dim_date.
  No user PII — aggregates only.
*/

with ratings as (

    select * from {{ ref('fact_ride_ratings') }}

),

dates as (

    select * from {{ ref('dim_date') }}

),

final as (

    select
        d.full_date as rating_date,
        d.year,
        d.month_number,
        d.day_name,
        d.is_weekend,
        d.occasion,
        r.rater_role,
        r.score,
        count(*) as rating_count,
        count(distinct r.ride_id) as rated_ride_count
    from ratings as r
    inner join dates as d
        on r.rating_date_key = d.date_key
    group by
        d.full_date,
        d.year,
        d.month_number,
        d.day_name,
        d.is_weekend,
        d.occasion,
        r.rater_role,
        r.score

)

select * from final

/*
  Fact prep: FACT_USER_SUBSCRIPTIONS (1 row per subscription period).

  Degenerate dimension:
    - user_subscription_id   (UK on fact)

  Natural keys for dimensions in gold (no plan attributes here):
    - user_id   → dim_user
    - plan_id   → dim_subscription_plan (plan_code, names, catalog price live on the dim)

  Fact attributes (subscription grain, including locked-in pricing snapshots):
    - status, locked_*, auto_renew, dates, duration_days
*/

with subscriptions as (

    select * from {{ ref('stg_user_subscriptions') }}

),

final as (

    select
        user_subscription_id,
        user_id,
        plan_id,
        status,
        locked_discount_type,
        locked_monthly_price_egp,
        locked_discount_value,
        cast(case when auto_renew = 1 then 1 else 0 end as bit) as auto_renew,
        start_date,
        end_date,
        next_renewal_date,
        cancelled_at,

        case
            when end_date is not null and start_date is not null
                then datediff(day, start_date, end_date)
            else null
        end as duration_days

    from subscriptions

)

select * from final

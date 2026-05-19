/*
  Fact prep: FACT_PAYMENTS (1 row per payment event).

  Degenerate dimensions (operational IDs / attributes — no FK to other facts):
    - payment_id
    - ride_id
    - promo_code_redemption_id
    - user_subscription_id
    - payment_type, status

  Measures on this fact: amount only (plus is_refund flag).
  Ride economics (driver earning, commission, discounts) live on int_ride_payments_rollup
  for FACT_RIDES — not duplicated here.

  Dimensions in gold: user_id → dim_user; occurred_at → dim_date.
*/

with payments as (

    select * from {{ ref('stg_payments') }}

),

final as (

    select
        payment_id,
        user_id,
        ride_id,
        promo_code_redemption_id,
        user_subscription_id,
        payment_type,
        status,
        amount,
        cast(case when is_refund = 1 then 1 else 0 end as bit) as is_refund,
        occurred_at

    from payments

)

select * from final

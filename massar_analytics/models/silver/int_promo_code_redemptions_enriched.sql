/*
  Fact prep: FACT_PROMO_CODE_REDEMPTIONS (1 row per redemption).

  Degenerate dimensions:
    - redemption_id
    - ride_id          (not RideKey → fct_rides)

  Resolve to dimensions in gold:
    - promo_code_id    → dim_promo_code
    - user_id          → dim_user
    - redeemed_at      → dim_date (RedeemedDateKey)
*/

with redemptions as (

    select * from {{ ref('stg_promo_code_redemptions') }}

),

final as (

    select
        redemption_id,
        promo_code_id,
        user_id,
        ride_id,
        discount_amount_applied,
        redeemed_at

    from redemptions

)

select * from final

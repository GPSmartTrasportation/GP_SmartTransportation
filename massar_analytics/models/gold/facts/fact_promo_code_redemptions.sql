with redemptions as (

    select * from {{ ref('int_promo_code_redemptions_enriched') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['redemption_id']) }} as redemption_key,
        redemption_id,
        {{ dbt_utils.generate_surrogate_key(['promo_code_id']) }} as promo_code_key,
        {{ dbt_utils.generate_surrogate_key(['user_id']) }} as user_key,
        ride_id,
        {{ to_date_key('redeemed_at') }} as redeemed_date_key,
        discount_amount_applied
    from redemptions

)

select * from final

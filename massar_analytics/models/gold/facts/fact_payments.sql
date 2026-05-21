with payments as (

    select * from {{ ref('int_payments_enriched') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['payment_id']) }} as payment_key,
        payment_id,
        {{ dbt_utils.generate_surrogate_key(['user_id']) }} as user_key,
        ride_id,
        promo_code_redemption_id,
        user_subscription_id,
        {{ to_date_key('occurred_at') }} as occurred_date_key,
        payment_type,
        status,
        amount,
        is_refund
    from payments

)

select * from final

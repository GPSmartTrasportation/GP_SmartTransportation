with subscriptions as (

    select * from {{ ref('int_user_subscriptions_enriched') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['user_subscription_id']) }} as user_subscription_key,
        user_subscription_id,
        {{ dbt_utils.generate_surrogate_key(['user_id']) }} as user_key,
        {{ dbt_utils.generate_surrogate_key(['plan_id']) }} as plan_key,
        {{ to_date_key('start_date') }} as start_date_key,
        {{ to_date_key('end_date') }} as end_date_key,
        {{ to_date_key('next_renewal_date') }} as next_renewal_date_key,
        {{ to_date_key('cancelled_at') }} as cancelled_date_key,
        status,
        auto_renew,
        locked_monthly_price_egp,
        duration_days
    from subscriptions

)

select * from final

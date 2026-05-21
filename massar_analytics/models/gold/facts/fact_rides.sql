with rides as (

    select * from {{ ref('int_rides_enriched') }}

),

payments as (

    select * from {{ ref('int_ride_payments_rollup') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['r.ride_id']) }} as ride_key,
        r.ride_id,
        {{ dbt_utils.generate_surrogate_key(['r.user_id']) }} as user_key,
        case
            when r.driver_id is not null
                then {{ dbt_utils.generate_surrogate_key(['r.driver_id']) }}
        end as driver_key,
        {{ dbt_utils.generate_surrogate_key(['r.vehicle_id']) }} as vehicle_key,
        {{ dbt_utils.generate_surrogate_key(['r.preference_id']) }} as preference_key,
        {{ dbt_utils.generate_surrogate_key(['r.pickup_zone_id']) }} as pickup_zone_key,
        {{ dbt_utils.generate_surrogate_key(['r.dropoff_zone_id']) }} as dropoff_zone_key,
        {{ to_date_key('r.requested_at') }} as requested_date_key,
        {{ to_time_key('r.requested_at') }} as requested_time_key,
        {{ to_date_key('r.accepted_at') }} as accepted_date_key,
        {{ to_date_key('r.completed_at') }} as completed_date_key,
        {{ to_date_key('r.cancelled_at') }} as cancelled_date_key,
        case
            when r.cancellation_reason_id is not null
                then {{ dbt_utils.generate_surrogate_key(['r.cancellation_reason_id']) }}
        end as cancellation_reason_key,
        r.session_id,
        r.requested_at,
        r.accepted_at,
        r.completed_at,
        r.cancelled_at,
        r.current_status,
        r.passenger_count,
        r.cargo_weight_kg,
        r.cargo_type,
        r.is_completed,
        r.is_cancelled,
        r.minutes_to_accept,
        r.minutes_to_complete,
        r.actual_duration_minutes,
        r.status_change_count,
        coalesce(p.amount, 0) as amount,
        coalesce(p.refund_amount, 0) as refund_amount,
        coalesce(p.driver_earning_amount, 0) as driver_earning_amount,
        coalesce(p.platform_commission_amount, 0) as platform_commission_amount,
        coalesce(p.subscription_discount_amount, 0) as subscription_discount_amount,
        coalesce(p.promo_discount_amount, 0) as promo_discount_amount,
        coalesce(p.net_revenue, 0) as net_revenue
    from rides r
    left join payments p
        on r.ride_id = p.ride_id

)

select * from final

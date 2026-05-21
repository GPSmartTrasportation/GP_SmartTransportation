with sessions as (

    select * from {{ ref('int_sessions_enriched') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['session_id']) }} as session_key,
        session_id,
        {{ dbt_utils.generate_surrogate_key(['driver_id']) }} as driver_key,
        {{ dbt_utils.generate_surrogate_key(['vehicle_id']) }} as vehicle_key,
        {{ dbt_utils.generate_surrogate_key(['preference_id']) }} as preference_key,
        online_at,
        offline_at,
        duration_minutes,
        is_currently_online,
        ride_count,
        completed_ride_count,
        total_revenue
    from sessions

)

select * from final

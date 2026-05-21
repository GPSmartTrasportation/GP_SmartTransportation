with rides as (

    select * from {{ ref('stg_rides') }}

),

sessions as (

    select * from {{ ref('stg_sessions') }}

),

zones as (

    select * from {{ ref('int_zones_enriched') }}

),

status_events as (

    select * from {{ ref('int_ride_status_events') }}

),

final as (

    select
        r.ride_id,
        r.user_id           as user_id,
        r.session_id,
        s.driver_id,
        s.preference_id,
        s.vehicle_id,

        r.pickup_zone_id,
        pz.zone_name_en         as pickup_zone_name_en,
        pz.city_id              as pickup_city_id,
        pz.city_name_en         as pickup_city_name_en,
        pz.governorate_id       as pickup_governorate_id,
        pz.governorate_name_en  as pickup_governorate_name_en,

        r.dropoff_zone_id,
        dz.zone_name_en         as dropoff_zone_name_en,
        dz.city_id              as dropoff_city_id,
        dz.city_name_en         as dropoff_city_name_en,
        dz.governorate_id       as dropoff_governorate_id,
        dz.governorate_name_en  as dropoff_governorate_name_en,

        r.current_status,
        r.cargo_type,
        r.receiver_name,
        r.receiver_phone,
        r.passenger_count,
        r.cargo_weight_kg,

        r.expected_start_at,
        r.expected_end_at,
        r.actual_start_at,
        r.actual_end_at,

        se.requested_at,
        se.accepted_at,
        se.completed_at,
        se.cancelled_at,
        se.cancellation_reason_id,
        se.status_change_count,

        cast(case when r.current_status = 'Completed' then 1 else 0 end as bit) as is_completed,
        cast(case when r.current_status = 'Cancelled' then 1 else 0 end as bit) as is_cancelled,
        cast(case when r.pickup_zone_id = r.dropoff_zone_id then 1 else 0 end as bit) as is_intra_zone,
        cast(case when pz.city_id = dz.city_id then 1 else 0 end as bit) as is_intra_city,
        cast(case when pz.governorate_id = dz.governorate_id then 1 else 0 end as bit) as is_intra_governorate,

        -- Durations (T-SQL: DATEDIFF returns int; use seconds → minutes for precision)
        cast(datediff(second, r.actual_start_at, r.actual_end_at) as decimal(18,2)) / 60.0
            as actual_duration_minutes,
        cast(datediff(second, r.expected_start_at, r.expected_end_at) as decimal(18,2)) / 60.0
            as expected_duration_minutes,
        datediff(minute, se.requested_at, se.accepted_at)   as minutes_to_accept,
        datediff(minute, se.accepted_at, se.completed_at)  as minutes_to_complete

    from rides r
    left join sessions      s  on r.session_id      = s.session_id
    left join zones         pz on r.pickup_zone_id  = pz.zone_id
    left join zones         dz on r.dropoff_zone_id = dz.zone_id
    left join status_events se on r.ride_id         = se.ride_id

)

select * from final

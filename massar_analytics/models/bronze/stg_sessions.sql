with source as (

    select * from {{ source('gp_smarttransport', 'Sessions') }}

),

renamed as (

    select
        SessionId       as session_id,
        DriverId        as driver_id,
        VehicleId       as vehicle_id,
        PreferenceId    as preference_id,
        OnlineAt        as online_at,
        OfflineAt       as offline_at
    from source

)

select * from renamed

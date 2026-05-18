with source as (

    select * from {{ source('gp_smarttransport', 'Rides') }}

),

renamed as (

    select
        RideId              as ride_id,
        UserId              as user_id,
        SessionId           as session_id,
        PickupZoneId        as pickup_zone_id,
        DropoffZoneId       as dropoff_zone_id,
        CurrentStatus       as current_status,
        CargoType           as cargo_type,
        ReceiverName        as receiver_name,
        ReceiverPhone       as receiver_phone,
        PassengerCount      as passenger_count,
        CargoWeightKg       as cargo_weight_kg,
        ExpectedStartTime   as expected_start_at,
        ExpectedEndTime     as expected_end_at,
        ActualStartTime     as actual_start_at,
        ActualEndTime       as actual_end_at
    from source

)

select * from renamed

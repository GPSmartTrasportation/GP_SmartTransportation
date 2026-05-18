with source as (

    select * from {{ source('gp_smarttransport', 'VehicleTypes') }}

),

renamed as (

    select
        VehicleTypeId       as vehicle_type_id,
        TypeName            as type_name,
        PassengerCapacity   as passenger_capacity,
        MaxCargoWeightKg    as max_cargo_weight_kg
    from source

)

select * from renamed

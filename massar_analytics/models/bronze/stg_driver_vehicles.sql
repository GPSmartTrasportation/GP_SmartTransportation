with source as (

    select * from {{ source('gp_smarttransport', 'DriverVehicles') }}

),

renamed as (

    select
        AssignmentId    as assignment_id,
        VehicleId       as vehicle_id,
        DriverId        as driver_id,
        AssignmentType  as assignment_type
    from source

)

select * from renamed

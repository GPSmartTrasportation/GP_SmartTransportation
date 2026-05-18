with source as (

    select * from {{ source('gp_smarttransport', 'Vehicles') }}

),

renamed as (

    select
        VehicleId           as vehicle_id,
        VehicleTypeId       as vehicle_type_id,
        Brand               as brand,
        LicensePlateAr     as license_plate_ar,
        ManufactureYear     as manufacture_year,
        HasAirConditioning  as has_air_conditioning
    from source

)

select * from renamed

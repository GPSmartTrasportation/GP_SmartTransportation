with source as (

    select * from {{ source('gp_smarttransport', 'DriverLicenses') }}

),

renamed as (

    select
        LicenseId       as license_id,
        DriverId        as driver_id,
        LicenseNumber   as license_number,
        LicenseType     as license_type,
        ExpiryDate      as expiry_date
    from source

)

select * from renamed

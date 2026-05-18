with source as (

    select * from {{ source('gp_smarttransport', 'Drivers') }}

),

renamed as (

    select
        DriverId                as driver_id,
        NationalId              as national_id,
        MilitaryServiceStatus   as military_service_status,
        CurrentRating           as current_rating,
        HireDate                as hire_date
    from source

)

select * from renamed

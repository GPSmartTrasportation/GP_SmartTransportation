with source as (

    select * from {{ source('gp_smarttransport', 'BackgroundChecks') }}

),

renamed as (

    select
        BackgroundCheckId   as background_check_id,
        DriverId            as driver_id,
        CertificateType     as certificate_type,
        Outcome             as outcome,
        CheckDate           as check_date,
        ExpiryDate          as expiry_date
    from source

)

select * from renamed

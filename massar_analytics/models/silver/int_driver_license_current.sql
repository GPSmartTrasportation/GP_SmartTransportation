with licenses as (

    select * from {{ ref('stg_driver_licenses') }}

),

ranked as (

    select
        license_id,
        driver_id,
        license_number,
        license_type,
        expiry_date,
        cast(
            case
                when expiry_date >= cast(getdate() as date) then 1
                else 0
            end as bit
        ) as is_license_valid,
        row_number() over (
            partition by driver_id
            order by
                case when expiry_date >= cast(getdate() as date) then 0 else 1 end,
                expiry_date desc,
                license_id desc
        ) as license_rank
    from licenses

)

select
    license_id,
    driver_id,
    license_number,
    license_type,
    expiry_date,
    is_license_valid
from ranked
where license_rank = 1

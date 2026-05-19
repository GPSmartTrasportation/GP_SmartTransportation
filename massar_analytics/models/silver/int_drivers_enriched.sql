with drivers as (

    select * from {{ ref('stg_drivers') }}

),

users as (

    select * from {{ ref('stg_users') }}

),

licenses as (

    select * from {{ ref('int_driver_license_current') }}

),

background_checks as (

    select * from {{ ref('int_driver_background_check_current') }}

),

final as (

    select
        d.driver_id,
        d.national_id,
        d.military_service_status,
        d.current_rating,
        d.hire_date,

        u.full_name_en,
        u.full_name_ar,
        u.phone_number,
        u.email,
        u.account_status,

        l.license_number          as current_license_number,
        l.license_type            as current_license_type,
        l.expiry_date             as current_license_expiry_date,
        cast(l.is_license_valid as bit) as is_license_valid,

        bc.certificate_type         as background_check_type,
        bc.check_date               as background_check_date,
        bc.outcome                  as background_check_outcome,
        bc.expiry_date              as background_check_expiry_date,
        cast(bc.is_background_check_valid as bit) as is_background_check_valid

    from drivers d
    inner join users u
        on d.driver_id = u.user_id
    left join licenses l
        on d.driver_id = l.driver_id
    left join background_checks bc
        on d.driver_id = bc.driver_id

)

select * from final

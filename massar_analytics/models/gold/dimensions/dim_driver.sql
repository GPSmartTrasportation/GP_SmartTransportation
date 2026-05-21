with drivers as (

    select * from {{ ref('int_drivers_enriched') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['driver_id']) }} as driver_key,
        driver_id,
        national_id,
        full_name_en,
        military_service_status,
        hire_date,
        current_license_number,
        current_license_type,
        current_license_expiry_date,
        is_license_valid,
        background_check_type,
        background_check_date,
        background_check_outcome,
        background_check_expiry_date,
        is_background_check_valid
    from drivers

)

select * from final

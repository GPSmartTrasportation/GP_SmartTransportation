with zones as (

    select * from {{ ref('int_zones_enriched') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['zone_id']) }} as zone_key,
        zone_id,
        zone_name_en,
        city_name_en,
        governorate_name_en,
        is_zone_active
    from zones

)

select * from final

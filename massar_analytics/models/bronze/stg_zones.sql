with source as (

    select * from {{ source('gp_smarttransport', 'Zones') }}

),

renamed as (

    select
        ZoneId      as zone_id,
        CityId      as city_id,
        ZoneNameAr  as zone_name_ar,
        ZoneNameEn  as zone_name_en,
        IsActive    as is_active
    from source

)

select * from renamed

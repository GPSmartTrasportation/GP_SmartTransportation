with source as (

    select * from {{ source('gp_smarttransport', 'Cities') }}

),

renamed as (

    select
        CityId          as city_id,
        GovernorateId   as governorate_id,
        CityNameAr      as city_name_ar,
        CityNameEn      as city_name_en
    from source

)

select * from renamed

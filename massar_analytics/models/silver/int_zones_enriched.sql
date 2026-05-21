with zones as (

    select * from {{ ref('stg_zones') }}

),

cities as (

    select * from {{ ref('stg_cities') }}

),

governorates as (

    select * from {{ ref('stg_governorates') }}

),

final as (

    select
        z.zone_id,
        z.zone_name_ar,
        z.zone_name_en,
        cast(case when z.is_active = 1 then 1 else 0 end as bit) as is_zone_active,

        c.city_id,
        c.city_name_ar,
        c.city_name_en,

        g.governorate_id,
        g.governorate_name_ar,
        g.governorate_name_en
    from zones z
    inner join cities c
        on z.city_id = c.city_id
    inner join governorates g
        on c.governorate_id = g.governorate_id

)

select * from final

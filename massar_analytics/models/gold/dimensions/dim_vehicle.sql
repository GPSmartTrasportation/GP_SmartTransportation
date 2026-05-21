with vehicles as (

    select * from {{ ref('stg_vehicles') }}

),

vehicle_types as (

    select * from {{ ref('stg_vehicle_types') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['v.vehicle_id']) }} as vehicle_key,
        v.vehicle_id,
        vt.type_name as vehicle_name,
        v.brand,
        vt.passenger_capacity,
        v.manufacture_year,
        v.license_plate_ar,
        cast(case when v.has_air_conditioning = 1 then 1 else 0 end as bit) as has_air_conditioning,
        vt.max_cargo_weight_kg
    from vehicles v
    inner join vehicle_types vt
        on v.vehicle_type_id = vt.vehicle_type_id

)

select * from final

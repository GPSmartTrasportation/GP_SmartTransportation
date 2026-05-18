with source as (

    select * from {{ source('gp_smarttransport', 'VehicleTypePreference') }}

),

renamed as (

    select
        VehicleTypeId   as vehicle_type_id,
        PreferenceId    as preference_id
    from source

)

select * from renamed

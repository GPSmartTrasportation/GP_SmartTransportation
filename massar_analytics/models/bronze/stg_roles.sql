with source as (

    select * from {{ source('gp_smarttransport', 'Roles') }}

),

renamed as (

    select
        RoleId      as role_id,
        RoleName    as role_name
    from source

)

select * from renamed

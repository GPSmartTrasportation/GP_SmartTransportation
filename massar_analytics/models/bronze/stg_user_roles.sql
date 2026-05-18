with source as (

    select * from {{ source('gp_smarttransport', 'UserRoles') }}

),

renamed as (

    select
        UserId  as user_id,
        RoleId  as role_id
    from source

)

select * from renamed

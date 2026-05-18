with source as (

    select * from {{ source('gp_smarttransport', 'Users') }}

),

renamed as (

    select
        UserId          as user_id,
        NationalId      as national_id,
        FullNameAr      as full_name_ar,
        FullNameEn      as full_name_en,
        PhoneNumber     as phone_number,
        Email           as email,
        AccountStatus   as account_status,
        FacebookId      as facebook_id,
        FacebookUrl     as facebook_url,
        DateOfBirth     as date_of_birth,
        CreatedAt       as created_at
    from source

)

select * from renamed

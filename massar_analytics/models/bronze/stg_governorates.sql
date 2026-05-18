with source as (

    select * from {{ source('gp_smarttransport', 'Governorates') }}

),

renamed as (

    select
        GovernorateId       as governorate_id,
        GovernorateNameAr   as governorate_name_ar,
        GovernorateNameEn   as governorate_name_en
    from source

)

select * from renamed

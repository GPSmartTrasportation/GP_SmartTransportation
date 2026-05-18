with source as (

    select * from {{ source('gp_smarttransport', 'CancellationReasons') }}

),

renamed as (

    select
        CancellationReasonId    as cancellation_reason_id,
        ReasonTitle             as reason_title,
        AppliesTo               as applies_to,
        DescriptionAr           as description_ar,
        DescriptionEn           as description_en
    from source

)

select * from renamed

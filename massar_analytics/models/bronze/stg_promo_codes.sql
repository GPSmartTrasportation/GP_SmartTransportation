with source as (

    select * from {{ source('gp_smarttransport', 'PromoCodes') }}

),

renamed as (

    select
        PromoCodeId         as promo_code_id,
        Code                as code,
        Description         as description,
        DiscountType        as discount_type,
        DiscountValue       as discount_value,
        MaxDiscountAmount   as max_discount_amount,
        MinRideAmount       as min_ride_amount,
        MaxTotalUses        as max_total_uses,
        IsActive            as is_active,
        ValidFrom           as valid_from_date,
        ValidUntil          as valid_until_date
    from source

)

select * from renamed

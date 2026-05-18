with source as (

    select * from {{ source('gp_smarttransport', 'PromoCodeRedemptions') }}

),

renamed as (

    select
        RedemptionId            as redemption_id,
        PromoCodeId             as promo_code_id,
        UserId                  as user_id,
        RideId                  as ride_id,
        DiscountAmountApplied   as discount_amount_applied,
        RedeemedAt              as redeemed_at
    from source

)

select * from renamed

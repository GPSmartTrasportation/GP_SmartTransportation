with source as (

    select * from {{ source('gp_smarttransport', 'Payments') }}

),

renamed as (

    select
        PaymentId                   as payment_id,
        UserId                      as user_id,
        RideId                      as ride_id,
        PromoCodeRedemptionId       as promo_code_redemption_id,
        SubscriptionId              as user_subscription_id,
        PaymentType                 as payment_type,
        Status                      as status,
        Amount                      as amount,
        DriverEarningAmount         as driver_earning_amount,
        PlatformCommissionAmount    as platform_commission_amount,
        SubscriptionDiscountAmount  as subscription_discount_amount,
        PromoDiscountAmount         as promo_discount_amount,
        case
            when Status = 'Refunded' then 1
            else 0
        end                         as is_refund,
        OccurredAt                  as occurred_at
    from source

)

select * from renamed

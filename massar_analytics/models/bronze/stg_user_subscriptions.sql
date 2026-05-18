with source as (

    select * from {{ source('gp_smarttransport', 'UserSubscriptions') }}

),

renamed as (

    select
        UserSubscriptionId      as user_subscription_id,
        UserId                  as user_id,
        PlanId                  as plan_id,
        Status                  as status,
        LockedDiscountType      as locked_discount_type,
        LockedMonthlyPriceEGP   as locked_monthly_price_egp,
        LockedDiscountValue     as locked_discount_value,
        AutoRenew               as auto_renew,
        StartDate               as start_date,
        EndDate                 as end_date,
        NextRenewalDate         as next_renewal_date,
        CancelledAt             as cancelled_at
    from source

)

select * from renamed

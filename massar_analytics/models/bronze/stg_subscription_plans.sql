with source as (

    select * from {{ source('gp_smarttransport', 'SubscriptionPlans') }}

),

renamed as (

    select
        PlanId              as plan_id,
        PlanCode            as plan_code,
        PlanNameAr          as plan_name_ar,
        PlanNameEn          as plan_name_en,
        DiscountType        as discount_type,
        MonthlyPriceEGP     as monthly_price_egp,
        DiscountValue       as discount_value,
        IsActive            as is_active
    from source

)

select * from renamed

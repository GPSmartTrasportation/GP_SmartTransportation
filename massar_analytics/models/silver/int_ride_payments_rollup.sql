with payments as (

    select * from {{ ref('stg_payments') }}

),

rollup as (

    select
        ride_id,

        sum(case when is_refund = 0 then amount else 0 end) as amount,
        sum(case when is_refund = 1 then abs(amount) else 0 end) as refund_amount,

        sum(case when is_refund = 0 then driver_earning_amount else 0 end)
            as driver_earning_amount,
        sum(case when is_refund = 0 then platform_commission_amount else 0 end)
            as platform_commission_amount,
        sum(case when is_refund = 0 then subscription_discount_amount else 0 end)
            as subscription_discount_amount,
        sum(case when is_refund = 0 then promo_discount_amount else 0 end)
            as promo_discount_amount

    from payments
    where ride_id is not null
    group by ride_id

),

final as (

    select
        ride_id,
        amount,
        refund_amount,
        driver_earning_amount,
        platform_commission_amount,
        subscription_discount_amount,
        promo_discount_amount,
        amount
            - refund_amount
            - subscription_discount_amount
            - promo_discount_amount as net_revenue
    from rollup

)

select * from final

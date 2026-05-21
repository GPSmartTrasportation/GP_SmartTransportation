with plans as (

    select * from {{ ref('stg_subscription_plans') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['plan_id']) }} as plan_key,
        plan_id,
        plan_code,
        plan_name_en,
        monthly_price_egp,
        discount_type,
        discount_value,
        cast(case when is_active = 1 then 1 else 0 end as bit) as is_active
    from plans

)

select * from final

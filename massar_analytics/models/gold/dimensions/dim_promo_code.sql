with promos as (

    select * from {{ ref('stg_promo_codes') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['promo_code_id']) }} as promo_code_key,
        promo_code_id,
        code,
        discount_type,
        discount_value,
        max_discount_amount,
        max_total_uses,
        cast(case when is_active = 1 then 1 else 0 end as bit) as is_active,
        valid_from_date,
        valid_until_date
    from promos

)

select * from final

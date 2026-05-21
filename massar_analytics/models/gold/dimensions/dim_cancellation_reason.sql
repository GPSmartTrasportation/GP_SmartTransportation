with reasons as (

    select * from {{ ref('stg_cancellation_reasons') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['cancellation_reason_id']) }} as cancellation_reason_key,
        cancellation_reason_id,
        reason_title,
        applies_to,
        description_ar,
        description_en
    from reasons

)

select * from final

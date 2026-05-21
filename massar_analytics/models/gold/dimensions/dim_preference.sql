with preferences as (

    select * from {{ ref('stg_preferences') }}

),

domains as (

    select * from {{ ref('stg_business_domains') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['p.preference_id']) }} as preference_key,
        p.preference_id,
        p.preference_name,
        d.domain_name
    from preferences p
    inner join domains d
        on p.domain_id = d.domain_id

)

select * from final

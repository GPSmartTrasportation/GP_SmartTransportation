with users as (

    select * from {{ ref('int_users_enriched') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['user_id']) }} as user_key,
        user_id,
        national_id,
        full_name_en,
        date_of_birth,
        account_status,
        user_role,
        wallet_balance
    from users

)

select * from final

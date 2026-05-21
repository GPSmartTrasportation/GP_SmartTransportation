with users_raw as (

    select * from {{ ref('stg_users') }}

),

users as (

    select
        user_id,
        national_id,
        full_name_ar,
        full_name_en,
        phone_number,
        email,
        account_status,
        nullif(ltrim(rtrim(cast(facebook_id as varchar(255)))), '') as facebook_id,
        nullif(ltrim(rtrim(facebook_url)), '') as facebook_url,
        date_of_birth,
        created_at
    from users_raw

),

user_roles as (

    select
        ur.user_id,
        r.role_name
    from {{ ref('stg_user_roles') }} ur
    inner join {{ ref('stg_roles') }} r
        on ur.role_id = r.role_id

),

-- UserRoles is many-to-many: one user can have Passenger and Driver rows.
-- Aggregate role_name to a single user_role per user for DIM_USER (1 row per user).
user_role_agg as (

    select
        user_id,
        case
            when sum(case when role_name = 'Passenger' then 1 else 0 end) > 0
                and sum(case when role_name = 'Driver' then 1 else 0 end) > 0
            then 'Both'
            when sum(case when role_name = 'Driver' then 1 else 0 end) > 0
            then 'Driver'
            when sum(case when role_name = 'Passenger' then 1 else 0 end) > 0
            then 'Passenger'
        end as user_role
    from user_roles
    group by user_id

),

wallets as (

    select * from {{ ref('stg_user_wallet') }}

),

final as (

    select
        u.user_id,
        u.national_id,
        u.full_name_ar,
        u.full_name_en,
        u.phone_number,
        u.email,
        u.account_status,
        u.facebook_id,
        u.facebook_url,
        u.date_of_birth,
        u.created_at,

        ura.user_role,

        w.wallet_id,
        w.balance     as wallet_balance

    from users u
    left join user_role_agg ura on u.user_id = ura.user_id
    left join wallets w on u.user_id = w.user_id

)

select * from final

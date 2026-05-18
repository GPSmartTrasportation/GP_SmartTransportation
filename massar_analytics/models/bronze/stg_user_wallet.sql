with source as (

    select * from {{ source('gp_smarttransport', 'UserWallet') }}

),

renamed as (

    select
        WalletId    as wallet_id,
        UserId      as user_id,
        Currency    as currency,
        Balance     as balance,
        UpdatedAt   as updated_at
    from source

)

select * from renamed

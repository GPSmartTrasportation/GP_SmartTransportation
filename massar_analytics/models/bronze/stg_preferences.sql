with source as (

    select * from {{ source('gp_smarttransport', 'Preferences') }}

),

renamed as (

    select
        PreferenceId    as preference_id,
        DomainId        as domain_id,
        PreferenceName  as preference_name
    from source

)

select * from renamed

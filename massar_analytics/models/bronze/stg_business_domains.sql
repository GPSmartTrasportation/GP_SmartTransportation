with source as (

    select * from {{ source('gp_smarttransport', 'BusinessDomains') }}

),

renamed as (

    select
        DomainId    as domain_id,
        DomainName  as domain_name
    from source

)

select * from renamed

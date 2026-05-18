with source as (

    select * from {{ source('gp_smarttransport', 'RideStatusHistory') }}

),

renamed as (

    select
        StatusHistoryId         as status_history_id,
        RideId                  as ride_id,
        CancellationReasonId    as cancellation_reason_id,
        Status                  as status,
        ChangedAt               as changed_at
    from source

)

select * from renamed

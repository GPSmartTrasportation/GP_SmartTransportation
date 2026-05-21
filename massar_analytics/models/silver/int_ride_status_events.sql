with history as (

    select * from {{ ref('stg_ride_status_history') }}

),

pivoted as (

    select
        ride_id,

        min(case when status = 'Requested' then changed_at end) as requested_at,
        min(case when status = 'Accepted'  then changed_at end) as accepted_at,
        max(case when status = 'Completed' then changed_at end) as completed_at,
        max(case when status = 'Cancelled' then changed_at end) as cancelled_at,

        max(case when status = 'Cancelled' then cancellation_reason_id end)
            as cancellation_reason_id,

        count(*) as status_change_count
    from history
    group by ride_id

)

select * from pivoted

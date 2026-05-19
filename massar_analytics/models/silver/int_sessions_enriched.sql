/*
  Fact prep: FACT_SESSIONS — driver shift grain (1 row per session_id).

  Shift attributes from OLTP Sessions; shift measures aggregated from rides/payments.
  Rides use session_id as degenerate shift reference (not a fact-to-fact FK).
*/

with sessions as (

    select * from {{ ref('stg_sessions') }}

),

rides_per_session as (

    select
        session_id,
        count(*) as ride_count,
        sum(cast(is_completed as int)) as completed_ride_count
    from {{ ref('int_rides_enriched') }}
    group by session_id

),

revenue_per_session as (

    select
        r.session_id,
        sum(coalesce(p.net_revenue, 0)) as total_revenue
    from {{ ref('int_rides_enriched') }} r
    left join {{ ref('int_ride_payments_rollup') }} p
        on r.ride_id = p.ride_id
    group by r.session_id

),

final as (

    select
        s.session_id,
        s.driver_id,
        s.vehicle_id,
        s.preference_id,
        s.online_at,
        s.offline_at,

        cast(case when s.offline_at is null then 1 else 0 end as bit) as is_currently_online,

        case
            when s.offline_at is not null
                then datediff(minute, s.online_at, s.offline_at)
            else null
        end as duration_minutes,

        coalesce(rps.ride_count, 0) as ride_count,
        coalesce(rps.completed_ride_count, 0) as completed_ride_count,
        coalesce(rev.total_revenue, 0) as total_revenue

    from sessions s
    left join rides_per_session rps
        on s.session_id = rps.session_id
    left join revenue_per_session rev
        on s.session_id = rev.session_id

)

select * from final

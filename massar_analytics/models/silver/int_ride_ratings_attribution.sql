/*
  Fact prep: FACT_RIDE_RATINGS (1 row per rating).

  Attribution mirrors OLTP joins:
    rr = RideRatings, r = Rides (UserId), s = Sessions (DriverId)
    ur = passenger user, ud = driver user (for display names)

  Degenerate: rating_id, ride_id, rater_role
  Gold dims: rater_user_id, rated_user_id → dim_user; created_at → dim_date
*/

with ratings as (

    select * from {{ ref('stg_ride_ratings') }}

),

rides as (

    select
        ride_id,
        user_id,
        session_id
    from {{ ref('stg_rides') }}

),

sessions as (

    select
        session_id,
        driver_id
    from {{ ref('stg_sessions') }}

),

passenger_users as (

    select
        user_id,
        full_name_en
    from {{ ref('stg_users') }}

),

driver_users as (

    select
        user_id,
        full_name_en
    from {{ ref('stg_users') }}

),

ride_context as (

    select
        r.ride_id,
        r.user_id,
        s.driver_id
    from rides r
    inner join sessions s
        on r.session_id = s.session_id

),

final as (

    select
        rr.rating_id,
        rr.ride_id,
        rr.rater_role,
        rr.score,

        case
            when rr.rater_role = 'Passenger' then rc.user_id
            when rr.rater_role = 'Driver' then rc.driver_id
        end as rater_user_id,

        case
            when rr.rater_role = 'Passenger' then ur.full_name_en
            when rr.rater_role = 'Driver' then ud.full_name_en
        end as rater_full_name,

        case
            when rr.rater_role = 'Passenger' then rc.driver_id
            when rr.rater_role = 'Driver' then rc.user_id
        end as rated_user_id,

        case
            when rr.rater_role = 'Passenger' then ud.full_name_en
            when rr.rater_role = 'Driver' then ur.full_name_en
        end as rated_full_name,

        rr.created_at

    from ratings rr
    inner join ride_context rc
        on rr.ride_id = rc.ride_id
    inner join passenger_users ur
        on rc.user_id = ur.user_id
    inner join driver_users ud
        on rc.driver_id = ud.user_id

)

select * from final

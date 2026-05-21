with ratings as (

    select * from {{ ref('int_ride_ratings_attribution') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['rating_id']) }} as rating_key,
        rating_id,
        ride_id,
        {{ dbt_utils.generate_surrogate_key(['rater_user_id']) }} as rater_user_key,
        {{ dbt_utils.generate_surrogate_key(['rated_user_id']) }} as rated_user_key,
        {{ to_date_key('created_at') }} as rating_date_key,
        rater_role,
        score,
        created_at
    from ratings
    where rater_user_id is not null
        and rated_user_id is not null

)

select * from final

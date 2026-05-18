with source as (

    select * from {{ source('gp_smarttransport', 'RideRatings') }}

),

renamed as (

    select
        RatingId    as rating_id,
        RideId      as ride_id,
        RaterRole   as rater_role,
        Score       as score,
        CreatedAt   as created_at
    from source

)

select * from renamed

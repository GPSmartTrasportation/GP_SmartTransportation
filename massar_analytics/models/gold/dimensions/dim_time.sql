with numbers as (

    select top (1440)
        row_number() over (order by (select null)) - 1 as minute_of_day
    from sys.all_objects a
    cross join sys.all_objects b

),

time_spine as (

    select
        minute_of_day,
        cast(minute_of_day / 60 as tinyint) as hour_24,
        cast(minute_of_day % 60 as tinyint) as minute_of_hour
    from numbers

),

final as (

    select
        cast(t.hour_24 * 100 + t.minute_of_hour as smallint) as time_key,
        t.hour_24,
        t.minute_of_hour,
        concat(
            right(concat('0', cast(t.hour_24 as varchar(2))), 2),
            ':',
            right(concat('0', cast(t.minute_of_hour as varchar(2))), 2)
        ) as time_24,
        concat(
            cast(
                case
                    when t.hour_24 = 0 then 12
                    when t.hour_24 > 12 then t.hour_24 - 12
                    else t.hour_24
                end as varchar(2)
            ),
            ':',
            right(concat('0', cast(t.minute_of_hour as varchar(2))), 2),
            ' ',
            case when t.hour_24 < 12 then 'AM' else 'PM' end
        ) as time_12,
        case when t.hour_24 < 12 then 'AM' else 'PM' end as am_pm,
        case
            when t.hour_24 between 0 and 5 then 'Late Night'
            when t.hour_24 between 6 and 8 then 'Morning Rush'
            when t.hour_24 between 9 and 11 then 'Morning'
            when t.hour_24 between 12 and 13 then 'Lunch'
            when t.hour_24 between 14 and 16 then 'Afternoon'
            when t.hour_24 between 17 and 20 then 'Evening Rush'
            else 'Night'
        end as period_of_day,
        cast(
            case
                when t.hour_24 between 7 and 9 then 1
                when t.hour_24 between 12 and 14 then 1
                when t.hour_24 between 17 and 20 then 1
                else 0
            end as bit
        ) as is_peak_hour
    from time_spine t

)

select * from final

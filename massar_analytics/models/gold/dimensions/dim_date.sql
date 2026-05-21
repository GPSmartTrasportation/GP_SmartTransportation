with numbers as (

    select top (datediff(day, '2024-01-01', '2026-12-31') + 1)
        row_number() over (order by (select null)) - 1 as day_offset
    from sys.all_objects a
    cross join sys.all_objects b

),

date_spine as (

    select dateadd(day, day_offset, cast('2024-01-01' as date)) as date_day
    from numbers

),

occasions as (

    select
        cast(start_date as date) as start_date,
        cast(end_date as date) as end_date,
        occasion_name
    from {{ ref('egypt_occasions') }}

),

final as (

    select
        {{ to_date_key('d.date_day') }} as date_key,
        cast(d.date_day as date) as full_date,
        cast(datepart(day, d.date_day) as tinyint) as day_of_month,
        cast(datepart(month, d.date_day) as tinyint) as month_number,
        cast(datepart(quarter, d.date_day) as tinyint) as quarter,
        cast(datepart(year, d.date_day) as smallint) as year,
        cast(datename(weekday, d.date_day) as varchar(10)) as day_name,

        cast(
            case
                when datename(weekday, d.date_day) in ('Friday', 'Saturday') then 1
                else 0
            end as bit
        ) as is_weekend,
        cast(
            case
                when datename(weekday, d.date_day) in ('Friday', 'Saturday') then 0
                else 1
            end as bit
        ) as is_weekday,

        coalesce(o.occasion_name, 'Regular Day') as occasion

    from date_spine d
    left join occasions o
        on d.date_day between o.start_date and o.end_date

)

select * from final

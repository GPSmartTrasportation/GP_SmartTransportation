with checks as (

    select * from {{ ref('stg_background_checks') }}

),

ranked as (

    select
        background_check_id,
        driver_id,
        certificate_type,
        outcome,
        check_date,
        expiry_date,
        cast(
            case
                when outcome = 'Passed'
                    and expiry_date >= cast(getdate() as date) then 1
                else 0
            end as bit
        ) as is_background_check_valid,
        row_number() over (
            partition by driver_id
            order by
                case
                    when outcome = 'Passed'
                        and expiry_date >= cast(getdate() as date) then 0
                    else 1
                end,
                check_date desc,
                background_check_id desc
        ) as check_rank
    from checks

)

select
    background_check_id,
    driver_id,
    certificate_type,
    outcome,
    check_date,
    expiry_date,
    is_background_check_valid
from ranked
where check_rank = 1

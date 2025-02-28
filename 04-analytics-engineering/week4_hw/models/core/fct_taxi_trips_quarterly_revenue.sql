{{
    config(
        materialized='table'
    )
}}

with quarterly_revenue as (
    select 
        extract(year from pickup_datetime) as year,
        extract(quarter from pickup_datetime) as quarter,
        format('%d-Q%d', extract(year from pickup_datetime), extract(quarter from pickup_datetime)) as year_quarter,
        sum(total_amount) as quarterly_revenue
    from {{ ref('fact_trips') }}
    group by 1, 2, 3
),

yoy_growth as (
    select 
        q1.year,
        q1.quarter,
        q1.year_quarter,
        q1.quarterly_revenue,
        q2.quarterly_revenue as prev_year_revenue,
        
        case 
            when q2.quarterly_revenue is not null and q2.quarterly_revenue > 0 
            then round((q1.quarterly_revenue - q2.quarterly_revenue) / q2.quarterly_revenue * 100, 2)
            else null 
        end as yoy_growth_percentage
    from quarterly_revenue q1
    left join quarterly_revenue q2
        on q1.quarter = q2.quarter 
        and q1.year = q2.year + 1
)

select * from yoy_growth

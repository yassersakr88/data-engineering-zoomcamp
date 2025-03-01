with filtered_trips as (
    select 
        service_type,  -- Column to distinguish between Green and Yellow taxis
        extract(year from pickup_datetime) as year,
        extract(month from pickup_datetime) as month,
        fare_amount
    from {{ ref('fact_trips') }}
    where fare_amount > 0
      and trip_distance > 0
      and payment_type_description in ('Cash', 'Credit card')
),

monthly_fare_p95 as (
    select 
        service_type,
        year,
        month,
        percentile_cont(fare_amount, 0.95) over (
            partition by service_type, year, month
        ) as fare_p95
    from filtered_trips
)

select distinct service_type, year, month, fare_p95
from monthly_fare_p95
order by service_type, year, month;
with filtered_trips as (
    select 
        service_type,
        extract(year from pickup_datetime) as year,
        extract(month from pickup_datetime) as month,
        fare_amount
    from {{ ref('fact_trips') }}
    where 
        fare_amount > 0 
        and trip_distance > 0
        and payment_type_description in ('Cash', 'Credit card')
),

percentiles as (
    select 
        service_type,
        year,
        month,
        approx_quantiles(fare_amount, 100)[safe_offset(90)] as fare_p90,
        approx_quantiles(fare_amount, 100)[safe_offset(95)] as fare_p95,
        approx_quantiles(fare_amount, 100)[safe_offset(97)] as fare_p97
    from filtered_trips
    group by 1, 2, 3
)

select * from percentiles
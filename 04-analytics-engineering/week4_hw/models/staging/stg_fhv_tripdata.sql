{{
    config(
        materialized='view'
    )
}}

with tripdata as 
(
  select *,
    row_number() over(partition by dispatching_base_num, pickup_datetime) as rn
  from {{ source('staging', 'fhv_tripdata') }}
  where dispatching_base_num is not null 
)
SELECT 
    dispatching_base_num,
    pickup_datetime,
    dropoff_datetime,
    EXTRACT(YEAR FROM pickup_datetime) AS year,
    EXTRACT(MONTH FROM pickup_datetime) AS month,
    PULocationID AS pickup_locationid,
    DOLocationID AS dropoff_locationid
from tripdata
where rn = 1
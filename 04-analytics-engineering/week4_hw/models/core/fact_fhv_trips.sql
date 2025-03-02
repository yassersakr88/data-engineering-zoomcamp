{{
    config(
        materialized='table'
    )
}}

WITH fhv_trips AS (
    SELECT 
        dispatching_base_num,
        pickup_datetime,
        dropoff_datetime,
        EXTRACT(YEAR FROM pickup_datetime) AS year,
        EXTRACT(MONTH FROM pickup_datetime) AS month,
        pickup_locationid AS pickup_locationid,
        dropoff_locationid AS dropoff_locationid
    FROM {{ ref('stg_fhv_tripdata') }}
),
zone_mapping AS (
    SELECT 
        locationid,
        borough,
        zone
    FROM {{ ref('dim_zones') }}
)
SELECT 
    f.dispatching_base_num,
    f.pickup_datetime,
    f.dropoff_datetime,
    f.year,
    f.month,
    f.pickup_locationid,
    pz.borough AS pickup_borough,
    pz.zone AS pickup_zone,
    f.dropoff_locationid,
    dz.borough AS dropoff_borough,
    dz.zone AS dropoff_zone
FROM fhv_trips f
LEFT JOIN zone_mapping pz ON f.pickup_locationid = pz.locationid
LEFT JOIN zone_mapping dz ON f.dropoff_locationid = dz.locationid
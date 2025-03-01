WITH fhv_trips AS (
    SELECT 
        year,
        month,
        pickup_locationid,
        dropoff_locationid,
        TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, SECOND) AS trip_duration
    FROM {{ ref('staging', 'stg_fhv_tripdata') }}
),

trip_duration_p90 AS (
    SELECT
        year,
        month,
        pickup_locationid,
        dropoff_locationid,
        APPROX_QUANTILES(trip_duration, 100)[91] AS trip_duration_p90
    FROM fhv_trips
    GROUP BY 1, 2, 3, 4
)

SELECT * FROM trip_duration_p90
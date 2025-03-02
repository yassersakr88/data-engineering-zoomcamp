WITH fhv_trips AS (
    SELECT 
        f.year,
        f.month,
        pz.zone AS pickup_zone, 
        dz.zone AS dropoff_zone, 
        TIMESTAMP_DIFF(f.dropoff_datetime, f.pickup_datetime, SECOND) AS trip_duration
    FROM {{ ref('fact_fhv_trips') }} f
    LEFT JOIN {{ ref('taxi_zone_lookup') }} pz ON f.pickup_locationid = pz.locationid
    LEFT JOIN {{ ref('taxi_zone_lookup') }} dz ON f.dropoff_locationid = dz.locationid
),

trip_duration_p90 AS (
    SELECT
        year,
        month,
        pickup_zone,
        dropoff_zone,
        APPROX_QUANTILES(trip_duration, 100)[91] AS trip_duration_p90
    FROM fhv_trips
    GROUP BY 1, 2, 3, 4
)

SELECT * FROM trip_duration_p90
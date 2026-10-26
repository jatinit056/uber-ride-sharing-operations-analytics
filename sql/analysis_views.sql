/* =====================================================================
   Analysis views - the notebook's feature engineering in SQL.
   Run after load_data.sql:   psql -d uber_db -f sql/analysis_views.sql
   The three materialized views aggregate the 18.8 million pickups once, so the queries in
   analysis_queries.sql run in seconds. Refresh them if the trip tables change:
       REFRESH MATERIALIZED VIEW uber.mv_hourly;   (etc.)
   ===================================================================== */

SET search_path TO uber;

-- Both periods in one shape: 2014 has coordinates, 2015 has a taxi zone
CREATE OR REPLACE VIEW v_pickups AS
SELECT '2014 Apr-Sep'::text AS period, pickup_ts, base_code, NULL::smallint AS location_id
FROM pickups_2014
UNION ALL
SELECT '2015 Jan-Jun'::text, pickup_ts, dispatching_base, location_id
FROM pickups_2015;

-- Service area = borough, except the three airports, which get their own area (same rule as the notebook)
CREATE OR REPLACE VIEW v_zones AS
SELECT location_id, borough, zone,
       location_id IN (1, 132, 138)                                         AS is_airport,
       CASE WHEN location_id IN (1, 132, 138) THEN 'Airports' ELSE borough END AS service_area
FROM taxi_zones;

-- Trips per date and hour, both periods
DROP MATERIALIZED VIEW IF EXISTS mv_hourly CASCADE;
CREATE MATERIALIZED VIEW mv_hourly AS
SELECT period,
       pickup_ts::date                    AS trip_date,
       EXTRACT(HOUR FROM pickup_ts)::int  AS hour,
       COUNT(*)                           AS trips
FROM v_pickups
GROUP BY 1, 2, 3;
CREATE INDEX ON mv_hourly (trip_date);

-- Trips per day with calendar attributes
CREATE OR REPLACE VIEW v_daily AS
SELECT period,
       trip_date,
       SUM(trips)                               AS trips,
       TO_CHAR(trip_date, 'YYYY-MM')            AS month,
       TRIM(TO_CHAR(trip_date, 'Day'))          AS weekday,
       EXTRACT(ISODOW FROM trip_date)::int      AS weekday_num,      -- 1 = Monday ... 7 = Sunday
       EXTRACT(ISODOW FROM trip_date) >= 6      AS is_weekend
FROM mv_hourly
GROUP BY period, trip_date;

-- 2015 trips per zone and day
DROP MATERIALIZED VIEW IF EXISTS mv_zone_daily_2015;
CREATE MATERIALIZED VIEW mv_zone_daily_2015 AS
SELECT pickup_ts::date AS trip_date, location_id, COUNT(*) AS trips
FROM pickups_2015
GROUP BY 1, 2;

-- 2015 trips per service area, date and hour
DROP MATERIALIZED VIEW IF EXISTS mv_area_hourly_2015;
CREATE MATERIALIZED VIEW mv_area_hourly_2015 AS
SELECT p.pickup_ts::date                   AS trip_date,
       EXTRACT(HOUR FROM p.pickup_ts)::int AS hour,
       z.service_area,
       COUNT(*)                            AS trips
FROM pickups_2015 p
JOIN v_zones z USING (location_id)
GROUP BY 1, 2, 3;

ANALYZE mv_hourly;
ANALYZE mv_zone_daily_2015;
ANALYZE mv_area_hourly_2015;

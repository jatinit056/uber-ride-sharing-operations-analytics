/* =====================================================================
   Uber / Ride-Sharing Operations Analytics (NYC 2014-2015) - analysis queries
   Database : PostgreSQL 13+ (tested on PostgreSQL 16)
   Requires : schema.sql -> load_data.sql -> analysis_views.sql
   Run      : psql -d uber_db -f sql/analysis_queries.sql
              python scripts/run_sql_queries.py --db uber_db     (saves every result to sql/results/)
   Definitions:
     trip            = one pickup record (identical rows are real trips - validated against TLC totals)
     avg trips / day = trips / days with data in the period
     service area    = borough, with JFK (132), LaGuardia (138) and Newark (1) as 'Airports'
     trips per active vehicle per day = FOIL trips / FOIL active vehicles (a productivity proxy,
                       NOT driver utilization - the data has no driver hours)
   The business question and the answer for each query are in sql/business_questions.md.
   ===================================================================== */

SET search_path TO uber;

------------------------------------------------------------------------
-- LEVEL 1 - BASICS: volume and growth
------------------------------------------------------------------------

-- Q01: How many trips are in each period, and over how many days?
SELECT period,
       COUNT(*)                                                  AS trips,
       MIN(pickup_ts)                                            AS first_pickup,
       MAX(pickup_ts)                                            AS last_pickup,
       COUNT(DISTINCT pickup_ts::date)                           AS days,
       ROUND(COUNT(*)::numeric / COUNT(DISTINCT pickup_ts::date), 1) AS avg_trips_per_day
FROM v_pickups
GROUP BY period
ORDER BY period;

-- Q02: How did monthly trips grow month over month?
WITH m AS (
    SELECT period, month, SUM(trips) AS trips, COUNT(*) AS days
    FROM v_daily
    GROUP BY period, month
)
SELECT period, month, trips, days,
       ROUND(trips::numeric / days, 1)                                              AS avg_trips_per_day,
       ROUND(100.0 * (trips - LAG(trips) OVER w) / LAG(trips) OVER w, 2)            AS mom_growth_pct,
       ROUND(100.0 * ((trips::numeric / days)
             / ((LAG(trips) OVER w)::numeric / (LAG(days) OVER w)) - 1), 2)         AS mom_growth_per_day_pct
FROM m
WINDOW w AS (PARTITION BY period ORDER BY month)
ORDER BY month;

-- Q03: How much did demand grow year over year (April-June 2014 vs 2015)?
WITH m AS (
    SELECT EXTRACT(YEAR FROM trip_date)::int AS yr, EXTRACT(MONTH FROM trip_date)::int AS mo, SUM(trips) AS trips
    FROM v_daily
    GROUP BY 1, 2
), y AS (
    SELECT a.mo AS sort_key, TO_CHAR(make_date(2015, a.mo, 1), 'Mon') AS month, a.trips AS trips_2014, b.trips AS trips_2015
    FROM m a
    JOIN m b ON b.mo = a.mo AND a.yr = 2014 AND b.yr = 2015
)
SELECT month, trips_2014, trips_2015,
       ROUND(100.0 * (trips_2015 - trips_2014) / trips_2014, 2) AS yoy_growth_pct,
       ROUND(trips_2015::numeric / trips_2014, 2)               AS multiple
FROM (
    SELECT sort_key, month, trips_2014, trips_2015 FROM y
    UNION ALL
    SELECT 99, 'Apr-Jun', SUM(trips_2014), SUM(trips_2015) FROM y
) t
ORDER BY sort_key;

------------------------------------------------------------------------
-- LEVEL 2 - DEMAND PATTERNS: weekdays, hours, special days
------------------------------------------------------------------------

-- Q04: Which weekdays are busiest in 2015?
SELECT weekday,
       COUNT(*)                                       AS days,
       SUM(trips)                                     AS trips,
       ROUND(AVG(trips), 1)                           AS avg_trips_per_day,
       RANK() OVER (ORDER BY AVG(trips) DESC)         AS busiest_rank
FROM v_daily
WHERE period = '2015 Jan-Jun'
GROUP BY weekday, weekday_num
ORDER BY weekday_num;

-- Q05: Which hours are the peak and the trough of the day (2015)?
WITH h AS (
    SELECT hour, AVG(trips) AS avg_trips, SUM(trips) AS trips
    FROM mv_hourly
    WHERE period = '2015 Jan-Jun'
    GROUP BY hour
)
SELECT hour,
       ROUND(avg_trips, 1)                                         AS avg_trips_in_hour,
       ROUND(100.0 * trips / SUM(trips) OVER (), 2)                AS share_of_trips_pct,
       CASE WHEN avg_trips = MAX(avg_trips) OVER () THEN 'peak'
            WHEN avg_trips = MIN(avg_trips) OVER () THEN 'trough' END AS flag,
       ROUND(MAX(avg_trips) OVER () / MIN(avg_trips) OVER (), 2)   AS peak_to_trough_ratio
FROM h
ORDER BY hour;

-- Q06: What does the weekday x hour demand matrix look like (average trips, 2015)?
SELECT hour,
       ROUND(AVG(trips) FILTER (WHERE wd = 1)) AS mon,
       ROUND(AVG(trips) FILTER (WHERE wd = 2)) AS tue,
       ROUND(AVG(trips) FILTER (WHERE wd = 3)) AS wed,
       ROUND(AVG(trips) FILTER (WHERE wd = 4)) AS thu,
       ROUND(AVG(trips) FILTER (WHERE wd = 5)) AS fri,
       ROUND(AVG(trips) FILTER (WHERE wd = 6)) AS sat,
       ROUND(AVG(trips) FILTER (WHERE wd = 7)) AS sun
FROM (SELECT hour, trips, EXTRACT(ISODOW FROM trip_date) AS wd
      FROM mv_hourly
      WHERE period = '2015 Jan-Jun') x
GROUP BY hour
ORDER BY hour;

-- Q07: What is the peak hour of each weekday (2015)?
WITH wh AS (
    SELECT EXTRACT(ISODOW FROM trip_date)::int AS wd, TRIM(TO_CHAR(trip_date, 'Day')) AS weekday,
           hour, AVG(trips) AS avg_trips
    FROM mv_hourly
    WHERE period = '2015 Jan-Jun'
    GROUP BY 1, 2, 3
), ranked AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY wd ORDER BY avg_trips DESC) AS rn
    FROM wh
)
SELECT weekday, hour AS peak_hour, ROUND(avg_trips) AS avg_trips_in_peak_hour
FROM ranked
WHERE rn = 1
ORDER BY wd;

-- Q08: Which days of 2015 were the busiest and the quietest?
WITH d AS (
    SELECT trip_date, weekday, trips,
           RANK() OVER (ORDER BY trips DESC) AS rank_busiest,
           RANK() OVER (ORDER BY trips ASC)  AS rank_quietest
    FROM v_daily
    WHERE period = '2015 Jan-Jun'
)
SELECT d.trip_date, d.weekday, d.trips, d.rank_busiest, d.rank_quietest, h.holiday_name
FROM d
LEFT JOIN holidays h ON h.holiday_date = d.trip_date
WHERE d.rank_busiest <= 10 OR d.rank_quietest <= 5
ORDER BY d.trips DESC;

-- Q09: What is the 7-day moving average, week-over-week change and running total (2015)?
SELECT trip_date, weekday, trips,
       ROUND(AVG(trips) OVER (ORDER BY trip_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 1) AS moving_avg_7d,
       trips - LAG(trips, 7) OVER (ORDER BY trip_date)                                       AS change_vs_same_day_last_week,
       SUM(trips) OVER (ORDER BY trip_date)                                                   AS running_total
FROM v_daily
WHERE period = '2015 Jan-Jun'
ORDER BY trip_date;

-- Q10: How much lower is demand on holidays and storm days than on a normal day of the same weekday?
-- "Normal" = the same weekday 1, 2 and 3 weeks before and after (local baseline, so the growth trend does not
-- distort the comparison). Holidays and the two blizzard days are excluded from every baseline.
WITH special AS (
    SELECT holiday_date AS day, holiday_name AS reason FROM holidays
    UNION ALL
    VALUES (DATE '2015-01-26', 'Blizzard: travel ban from 11 pm (external event)'),
           (DATE '2015-01-27', 'Blizzard: travel ban until the morning (external event)')
)
SELECT s.day, s.reason, d.weekday, d.trips,
       ROUND(AVG(n.trips))                              AS normal_same_weekday,
       COUNT(n.trips)                                   AS baseline_days,
       ROUND(100.0 * (d.trips / AVG(n.trips) - 1), 2)   AS vs_normal_pct
FROM special s
JOIN v_daily d ON d.trip_date = s.day
JOIN v_daily n ON n.trip_date IN (s.day - 21, s.day - 14, s.day - 7, s.day + 7, s.day + 14, s.day + 21)
WHERE n.trip_date NOT IN (SELECT day FROM special)
GROUP BY s.day, s.reason, d.weekday, d.trips
ORDER BY s.day;

------------------------------------------------------------------------
-- LEVEL 3 - GEOGRAPHY (2015 taxi zones)
------------------------------------------------------------------------

-- Q11: How are 2015 pickups split across boroughs and airports?
WITH a AS (
    SELECT z.service_area, SUM(m.trips) AS trips
    FROM mv_zone_daily_2015 m
    JOIN v_zones z USING (location_id)
    GROUP BY z.service_area
)
SELECT service_area, trips,
       ROUND(100.0 * trips / SUM(trips) OVER (), 3) AS share_pct,
       CASE WHEN service_area <> 'Unknown'
            THEN ROUND(100.0 * trips / SUM(trips) FILTER (WHERE service_area <> 'Unknown') OVER (), 3)
       END                                          AS share_of_known_zones_pct
FROM a
ORDER BY trips DESC;

-- Q12: Which areas grew fastest from January to June 2015 (trips per day)?
WITH days AS (
    SELECT month, COUNT(*) AS days FROM v_daily WHERE period = '2015 Jan-Jun' GROUP BY month
), m AS (
    SELECT z.service_area, TO_CHAR(trip_date, 'YYYY-MM') AS month, SUM(trips) AS trips
    FROM mv_zone_daily_2015
    JOIN v_zones z USING (location_id)
    WHERE z.service_area <> 'Unknown'
    GROUP BY 1, 2
), j AS (
    SELECT m.service_area, m.month, m.trips, m.trips::numeric / d.days AS per_day
    FROM m JOIN days d USING (month)
)
SELECT service_area,
       ROUND(SUM(per_day) FILTER (WHERE month = '2015-01'), 1)                                  AS trips_per_day_jan,
       ROUND(SUM(per_day) FILTER (WHERE month = '2015-06'), 1)                                  AS trips_per_day_jun,
       ROUND(100.0 * (SUM(per_day) FILTER (WHERE month = '2015-06')
                      / SUM(per_day) FILTER (WHERE month = '2015-01') - 1), 2)                  AS growth_pct,
       ROUND(100.0 * SUM(trips) FILTER (WHERE month = '2015-01')
             / SUM(SUM(trips) FILTER (WHERE month = '2015-01')) OVER (), 2)                     AS share_jan_pct,
       ROUND(100.0 * SUM(trips) FILTER (WHERE month = '2015-06')
             / SUM(SUM(trips) FILTER (WHERE month = '2015-06')) OVER (), 2)                     AS share_jun_pct
FROM j
GROUP BY service_area
ORDER BY trips_per_day_jun DESC;

-- Q13: What are the top 3 pickup zones in each borough?
WITH z AS (
    SELECT t.borough, t.zone, SUM(m.trips) AS trips
    FROM mv_zone_daily_2015 m
    JOIN taxi_zones t USING (location_id)
    WHERE t.borough <> 'Unknown'
    GROUP BY t.borough, t.zone
), r AS (
    SELECT *, DENSE_RANK() OVER (PARTITION BY borough ORDER BY trips DESC) AS rank_in_borough
    FROM z
)
SELECT borough, rank_in_borough, zone, trips
FROM r
WHERE rank_in_borough <= 3
ORDER BY borough, rank_in_borough;

-- Q14: Which taxi zones had no Uber pickup at all in Jan-Jun 2015?
SELECT t.location_id, t.borough, t.zone
FROM taxi_zones t
LEFT JOIN (SELECT DISTINCT location_id FROM mv_zone_daily_2015) p USING (location_id)
WHERE p.location_id IS NULL
  AND t.borough <> 'Unknown'
ORDER BY t.location_id;

-- Q15: How concentrated is demand - how many zones produce 50% and 80% of trips?
WITH z AS (
    SELECT location_id, SUM(trips) AS trips FROM mv_zone_daily_2015 GROUP BY location_id
), c AS (
    SELECT location_id, trips,
           ROW_NUMBER() OVER (ORDER BY trips DESC, location_id)                                  AS zone_rank,
           SUM(trips) OVER (ORDER BY trips DESC, location_id ROWS UNBOUNDED PRECEDING)::numeric
               / SUM(trips) OVER ()                                                               AS cum_share
    FROM z
)
SELECT MIN(zone_rank) FILTER (WHERE cum_share >= 0.5)                    AS zones_for_50pct,
       MIN(zone_rank) FILTER (WHERE cum_share >= 0.8)                    AS zones_for_80pct,
       ROUND(100.0 * MAX(cum_share) FILTER (WHERE zone_rank = 10), 2)    AS top10_share_pct,
       COUNT(*) FILTER (WHERE location_id NOT IN (264, 265))             AS zones_with_pickups
FROM c;

-- Q16: At which hours do the airports account for the largest share of pickups?
SELECT hour,
       SUM(trips) FILTER (WHERE service_area = 'Airports')                              AS airport_trips,
       SUM(trips)                                                                       AS all_trips,
       ROUND(100.0 * SUM(trips) FILTER (WHERE service_area = 'Airports') / SUM(trips), 2) AS airport_share_pct
FROM mv_area_hourly_2015
GROUP BY hour
ORDER BY hour;

-- Q17: What daily volume should be planned for each weekday (10th, 50th, 90th percentile, 2015)?
WITH d AS (SELECT weekday, weekday_num, trips FROM v_daily WHERE period = '2015 Jan-Jun')
SELECT weekday, days, p10_trips, median_trips, p90_trips
FROM (
    SELECT weekday_num AS sort_key, weekday, COUNT(*) AS days,
           ROUND(PERCENTILE_CONT(0.1) WITHIN GROUP (ORDER BY trips)::numeric) AS p10_trips,
           ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY trips)::numeric) AS median_trips,
           ROUND(PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY trips)::numeric) AS p90_trips
    FROM d GROUP BY weekday_num, weekday
    UNION ALL
    SELECT 8, 'All days', COUNT(*),
           ROUND(PERCENTILE_CONT(0.1) WITHIN GROUP (ORDER BY trips)::numeric),
           ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY trips)::numeric),
           ROUND(PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY trips)::numeric)
    FROM d
) t
ORDER BY sort_key;

------------------------------------------------------------------------
-- LEVEL 4 - BASES AND SUPPLY
------------------------------------------------------------------------

-- Q18: How did the split of trips between dispatching bases change from 2014 to 2015?
WITH b14 AS (SELECT base_code, COUNT(*) AS trips FROM pickups_2014 GROUP BY base_code),
     b15 AS (SELECT dispatching_base AS base_code, COUNT(*) AS trips FROM pickups_2015 GROUP BY dispatching_base)
SELECT COALESCE(b14.base_code, b15.base_code)                     AS base_code,
       b.base_name,
       b14.trips                                                  AS trips_2014,
       ROUND(100.0 * b14.trips / SUM(b14.trips) OVER (), 2)       AS share_2014_pct,
       b15.trips                                                  AS trips_2015,
       ROUND(100.0 * b15.trips / SUM(b15.trips) OVER (), 2)       AS share_2015_pct
FROM b14
FULL OUTER JOIN b15 ON b15.base_code = b14.base_code
JOIN bases b ON b.base_code = COALESCE(b14.base_code, b15.base_code)
ORDER BY trips_2015 DESC NULLS LAST;

-- Q19: How often is the dispatching base also the driver's affiliated base (2015)?
SELECT CASE WHEN affiliated_base = dispatching_base                 THEN 'Same base'
            WHEN affiliated_base = 'Unknown'                         THEN 'Affiliated base missing'
            WHEN affiliated_base IN (SELECT base_code FROM bases)    THEN 'Another Uber base'
            ELSE 'Non-Uber base' END                                 AS affiliation,
       COUNT(*)                                                      AS trips,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)            AS share_pct
FROM pickups_2015
GROUP BY 1
ORDER BY trips DESC;

-- Q20: How many trips does each base's active vehicle do per day (FOIL, Jan-Feb 2015)?
SELECT f.base_code, b.base_name,
       ROUND(AVG(f.active_vehicles), 1)                                           AS avg_active_vehicles,
       SUM(f.trips)                                                               AS trips,
       SUM(f.active_vehicles)                                                     AS vehicle_days,
       ROUND(SUM(f.trips)::numeric / SUM(f.active_vehicles), 3)                   AS trips_per_vehicle_day,
       RANK() OVER (ORDER BY SUM(f.trips)::numeric / SUM(f.active_vehicles) DESC) AS productivity_rank
FROM foil_daily f
JOIN bases b USING (base_code)
GROUP BY f.base_code, b.base_name
ORDER BY productivity_rank;

-- Q21: Do vehicles do more trips at weekends than on weekdays (FOIL)?
SELECT COALESCE(day_type, 'All days')                           AS day_type,
       SUM(trips)                                               AS trips,
       SUM(active_vehicles)                                     AS vehicle_days,
       ROUND(SUM(trips)::numeric / SUM(active_vehicles), 3)     AS trips_per_vehicle_day
FROM (SELECT trips, active_vehicles,
             CASE WHEN EXTRACT(ISODOW FROM trip_date) >= 6 THEN 'Weekend' ELSE 'Weekday' END AS day_type
      FROM foil_daily) x
GROUP BY ROLLUP (day_type)
ORDER BY day_type NULLS LAST;

-- Q22: Do the FOIL trip totals agree with the pickup records (Jan-Feb 2015)?
WITH p AS (
    SELECT dispatching_base AS base_code, COUNT(*) AS pickup_rows
    FROM pickups_2015
    WHERE pickup_ts < '2015-03-01'
    GROUP BY dispatching_base
), f AS (
    SELECT base_code, SUM(trips) AS foil_trips FROM foil_daily GROUP BY base_code
), joined AS (
    SELECT f.base_code, b.base_name, f.foil_trips, COALESCE(p.pickup_rows, 0) AS pickup_rows
    FROM f
    JOIN bases b USING (base_code)
    LEFT JOIN p USING (base_code)
)
SELECT base_code, base_name, foil_trips, pickup_rows,
       pickup_rows - foil_trips                                   AS difference,
       ROUND(100.0 * (pickup_rows - foil_trips) / foil_trips, 2)  AS difference_pct
FROM (
    SELECT * FROM joined
    UNION ALL
    SELECT 'ALL', 'All bases', (SELECT SUM(trips) FROM foil_daily),
           (SELECT COUNT(*) FROM pickups_2015 WHERE pickup_ts < '2015-03-01')
) t
ORDER BY base_code = 'ALL', foil_trips DESC;

-- Q23: How fast did the active fleet grow (average active vehicles per day, full weeks)?
WITH d AS (
    SELECT trip_date, SUM(active_vehicles) AS active_vehicles, SUM(trips) AS trips
    FROM foil_daily
    GROUP BY trip_date
), w AS (
    SELECT DATE_TRUNC('week', trip_date)::date AS week_start, COUNT(*) AS days,
           AVG(active_vehicles) AS avg_active_vehicles, SUM(trips) AS trips
    FROM d
    GROUP BY 1
)
SELECT week_start, days,
       ROUND(avg_active_vehicles, 1)                                                                  AS avg_active_vehicles,
       trips,
       ROUND(100.0 * (avg_active_vehicles / FIRST_VALUE(avg_active_vehicles) OVER (ORDER BY week_start) - 1), 2) AS growth_vs_first_week_pct
FROM w
WHERE days = 7
ORDER BY week_start;

------------------------------------------------------------------------
-- LEVEL 5 - MARKET CONTEXT
------------------------------------------------------------------------

-- Q24: How did Uber compare with Lyft and yellow taxis in Jul-Sep 2014 (TLC summary)?
SELECT TO_CHAR(trip_date, 'YYYY-MM')                                                AS month,
       ROUND(AVG(trips) FILTER (WHERE company = 'Uber'), 1)                         AS uber_trips_per_day,
       ROUND(AVG(trips) FILTER (WHERE company = 'Lyft'), 1)                         AS lyft_trips_per_day,
       ROUND(AVG(trips) FILTER (WHERE company = 'Yellow Taxis'), 1)                 AS yellow_taxi_trips_per_day,
       ROUND(100.0 * AVG(trips) FILTER (WHERE company = 'Uber')
             / AVG(trips) FILTER (WHERE company = 'Yellow Taxis'), 2)               AS uber_vs_yellow_pct,
       MIN(trip_date) FILTER (WHERE company = 'Lyft' AND trips > 0)                 AS first_lyft_day_in_month
FROM market_daily_2014
GROUP BY 1
ORDER BY 1;

-- Q25: Can the TLC base report (other car services, 2015) be used for market share? Check its coverage.
SELECT TO_CHAR(trip_date, 'YYYY-MM')        AS month,
       COUNT(*)                             AS days,
       ROUND(AVG(bases_reporting), 1)       AS avg_bases_reporting_per_day,
       MIN(bases_reporting)                 AS min_bases,
       MAX(bases_reporting)                 AS max_bases,
       ROUND(AVG(trips))                    AS avg_trips_per_day
FROM fhv_other_daily_2015
GROUP BY 1
ORDER BY 1;
-- Answer: no - the number of bases reporting changes from about 59 a day (Jan) to about 200 (Apr-May) and 5 (Aug),
-- so totals mostly reflect reporting coverage. Uber's share of the car-service market is therefore not calculated.

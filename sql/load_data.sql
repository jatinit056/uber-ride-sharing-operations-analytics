/* =====================================================================
   Load the data. Run from the PROJECT ROOT after schema.sql:
       python scripts/download_data.py          (once - downloads and checks the large raw files)
       psql -d uber_db -f sql/load_data.sql
   Raw trip files are loaded as text into staging tables and converted with explicit formats.
   Two small sources are loaded from data/cleaned (created by the notebook):
     market_daily_2014.csv     <- 'Aggregate FHV Data.xlsx' (an Excel file, not loadable with COPY)
     fhv_other_daily_2015.csv  <- 'other-FHV-data-jan-aug-2015.csv' (title lines + text numbers like " 1,137 ")
   ===================================================================== */

SET search_path TO uber;

-- reference: taxi zones (the file uses carriage-return line endings; COPY detects them)
\copy taxi_zones FROM 'data/raw/taxi-zone-lookup.csv' WITH (FORMAT csv, HEADER true)

-- 2014 pickups: six monthly files
\copy stg_pickups_2014 FROM 'data/raw/uber-raw-data-apr14.csv' WITH (FORMAT csv, HEADER true)
\copy stg_pickups_2014 FROM 'data/raw/uber-raw-data-may14.csv' WITH (FORMAT csv, HEADER true)
\copy stg_pickups_2014 FROM 'data/raw/uber-raw-data-jun14.csv' WITH (FORMAT csv, HEADER true)
\copy stg_pickups_2014 FROM 'data/raw/uber-raw-data-jul14.csv' WITH (FORMAT csv, HEADER true)
\copy stg_pickups_2014 FROM 'data/raw/uber-raw-data-aug14.csv' WITH (FORMAT csv, HEADER true)
\copy stg_pickups_2014 FROM 'data/raw/uber-raw-data-sep14.csv' WITH (FORMAT csv, HEADER true)

INSERT INTO pickups_2014 (pickup_ts, lat, lon, base_code)
SELECT to_timestamp(date_time, 'MM/DD/YYYY HH24:MI:SS')::timestamp,      -- e.g. 4/1/2014 0:11:00
       lat::numeric, lon::numeric, base
FROM stg_pickups_2014;

-- 2015 pickups (extracted from the zip by scripts/download_data.py)
\copy stg_pickups_2015 FROM 'data/raw/uber-raw-data-janjune-15.csv' WITH (FORMAT csv, HEADER true)

INSERT INTO pickups_2015 (pickup_ts, dispatching_base, affiliated_base, location_id)
SELECT pickup_date::timestamp,                                            -- e.g. 2015-05-17 09:47:00 (ISO)
       dispatching_base_num,
       COALESCE(NULLIF(TRIM(affiliated_base_num), ''), 'Unknown'),       -- 1.1% missing -> 'Unknown'
       location_id::smallint
FROM stg_pickups_2015;

-- FOIL daily base statistics
\copy stg_foil FROM 'data/raw/Uber-Jan-Feb-FOIL.csv' WITH (FORMAT csv, HEADER true)

INSERT INTO foil_daily (trip_date, base_code, active_vehicles, trips)
SELECT to_date(trip_date, 'MM/DD/YYYY'), dispatching_base_number, active_vehicles::int, trips::int
FROM stg_foil;

-- market context (cleaned by the notebook)
\copy market_daily_2014    FROM 'data/cleaned/market_daily_2014.csv'    WITH (FORMAT csv, HEADER true)
\copy fhv_other_daily_2015 FROM 'data/cleaned/fhv_other_daily_2015.csv' WITH (FORMAT csv, HEADER true)

-- staging tables are no longer needed
TRUNCATE stg_pickups_2014, stg_pickups_2015, stg_foil;

-- foreign keys are added after the bulk insert: one validation pass instead of 18.8 million row-by-row checks
ALTER TABLE pickups_2014 ADD CONSTRAINT fk_p14_base FOREIGN KEY (base_code) REFERENCES bases;
ALTER TABLE pickups_2015 ADD CONSTRAINT fk_p15_base FOREIGN KEY (dispatching_base) REFERENCES bases,
                         ADD CONSTRAINT fk_p15_zone FOREIGN KEY (location_id) REFERENCES taxi_zones;

CREATE INDEX idx_p14_ts   ON pickups_2014 (pickup_ts);
CREATE INDEX idx_p15_ts   ON pickups_2015 (pickup_ts);
CREATE INDEX idx_p15_zone ON pickups_2015 (location_id);
ANALYZE;

-- checks: 4,534,327 + 14,270,479 pickups; 263 zones + 2 unknown; 354 FOIL rows
SELECT (SELECT COUNT(*) FROM pickups_2014)          AS pickups_2014,
       (SELECT COUNT(*) FROM pickups_2015)          AS pickups_2015,
       (SELECT COUNT(*) FROM taxi_zones)            AS taxi_zones,
       (SELECT COUNT(*) FROM foil_daily)            AS foil_rows,
       (SELECT COUNT(*) FROM market_daily_2014)     AS market_rows,
       (SELECT COUNT(*) FROM fhv_other_daily_2015)  AS fhv_days;

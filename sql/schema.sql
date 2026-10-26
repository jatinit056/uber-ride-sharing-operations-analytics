/* =====================================================================
   Uber / Ride-Sharing Operations Analytics (NYC 2014-2015) - schema
   Database : PostgreSQL 13+ (tested on PostgreSQL 16)
   Run      : psql -d uber_db -f sql/schema.sql
   Order    : schema.sql -> load_data.sql -> analysis_views.sql -> analysis_queries.sql
   ===================================================================== */

DROP SCHEMA IF EXISTS uber CASCADE;
CREATE SCHEMA uber;
SET search_path TO uber;

-- ---------------------------------------------------------------- reference tables
CREATE TABLE bases (
    base_code  CHAR(6)     PRIMARY KEY,          -- TLC base licence number
    base_name  VARCHAR(20) NOT NULL
);
-- Uber's NYC bases (names from the README of the source repository)
INSERT INTO bases (base_code, base_name) VALUES
    ('B02512', 'Unter'), ('B02598', 'Hinter'), ('B02617', 'Weiter'), ('B02682', 'Schmecken'),
    ('B02764', 'Danach-NY'), ('B02765', 'Grun'), ('B02835', 'Dreist'), ('B02836', 'Drinnen');

CREATE TABLE taxi_zones (
    location_id SMALLINT    PRIMARY KEY,         -- TLC taxi-zone id (1-265)
    borough     VARCHAR(20) NOT NULL,            -- 264 and 265 = 'Unknown'
    zone        VARCHAR(60) NOT NULL
);

-- US federal holidays inside the two periods (reference data for the holiday analysis)
CREATE TABLE holidays (
    holiday_date DATE        PRIMARY KEY,
    holiday_name VARCHAR(40) NOT NULL
);
INSERT INTO holidays VALUES
    ('2014-05-26', 'Memorial Day'), ('2014-07-04', 'Independence Day'), ('2014-09-01', 'Labor Day'),
    ('2015-01-01', 'New Year''s Day'), ('2015-01-19', 'Martin Luther King Jr. Day'),
    ('2015-02-16', 'Presidents'' Day'), ('2015-05-25', 'Memorial Day');

-- ---------------------------------------------------------------- staging (raw text, exactly as in the files)
CREATE TABLE stg_pickups_2014 (date_time TEXT, lat TEXT, lon TEXT, base TEXT);
CREATE TABLE stg_pickups_2015 (dispatching_base_num TEXT, pickup_date TEXT, affiliated_base_num TEXT, location_id TEXT);
CREATE TABLE stg_foil (dispatching_base_number TEXT, trip_date TEXT, active_vehicles TEXT, trips TEXT);

-- ---------------------------------------------------------------- typed fact tables
CREATE TABLE pickups_2014 (                       -- one row per Uber pickup, Apr-Sep 2014
    pickup_ts  TIMESTAMP    NOT NULL,
    lat        NUMERIC(7,4) NOT NULL,
    lon        NUMERIC(7,4) NOT NULL,
    base_code  CHAR(6)      NOT NULL            -- foreign key added after the bulk load (load_data.sql)
);

CREATE TABLE pickups_2015 (                       -- one row per Uber pickup, Jan-Jun 2015
    pickup_ts        TIMESTAMP   NOT NULL,
    dispatching_base CHAR(6)     NOT NULL,       -- foreign keys added after the bulk load (load_data.sql)
    affiliated_base  VARCHAR(10) NOT NULL,        -- 'Unknown' when missing in the file
    location_id      SMALLINT    NOT NULL
);

CREATE TABLE foil_daily (                         -- Uber FOIL file: per base and day, Jan-Feb 2015
    trip_date       DATE    NOT NULL,
    base_code       CHAR(6) NOT NULL REFERENCES bases,
    active_vehicles INTEGER NOT NULL CHECK (active_vehicles > 0),
    trips           INTEGER NOT NULL CHECK (trips >= 0),
    PRIMARY KEY (trip_date, base_code)
);

CREATE TABLE market_daily_2014 (                  -- TLC summary: trips per day by company, Jul-Sep 2014
    trip_date DATE        NOT NULL,
    company   VARCHAR(20) NOT NULL,
    trips     INTEGER     NOT NULL,
    PRIMARY KEY (trip_date, company)
);

CREATE TABLE fhv_other_daily_2015 (               -- TLC base report: 334 other for-hire bases, summed per day
    trip_date       DATE    PRIMARY KEY,
    bases_reporting INTEGER NOT NULL,
    trips           INTEGER NOT NULL,
    vehicles        INTEGER NOT NULL,                 -- sum over bases that reported a vehicle count
    trips_with_vehicle_count INTEGER NOT NULL         -- trips of those bases (for trips per vehicle)
);

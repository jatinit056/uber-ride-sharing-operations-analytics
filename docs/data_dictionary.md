# Data dictionary

## Raw files (`data/raw/`)

| File | Column | Description | Data Type | Example | Business Meaning |
|---|---|---|---|---|---|
| uber-raw-data-*14.csv | `Date/Time` | Pickup date and time (to the minute) | text → datetime | 4/1/2014 0:11:00 | When demand happens |
| | `Lat`, `Lon` | Pickup coordinates (up to 4 decimals ≈ 10 m) | decimal | 40.769, -73.9549 | Where demand happens |
| | `Base` | TLC code of the Uber base | text | B02512 | Dispatching base |
| uber-raw-data-janjune-15.csv | `Dispatching_base_num` | Base that dispatched the trip | text | B02617 | Dispatching base |
| | `Pickup_date` | Pickup date and time (seconds in Jan–Feb, minutes from March) | text → datetime | 2015-05-17 09:47:00 | When demand happens |
| | `Affiliated_base_num` | Base the driver is affiliated with (1.14% missing) | text | B02617 | Driver affiliation |
| | `locationID` | TLC taxi-zone id | integer | 141 | Where demand happens |
| taxi-zone-lookup.csv | `LocationID`, `Borough`, `Zone` | Zone reference (265 ids) | integer / text | 132, Queens, JFK Airport | Geography |
| Uber-Jan-Feb-FOIL.csv | `dispatching_base_number`, `date`, `active_vehicles`, `trips` | Daily base statistics, Jan–Feb 2015 | text / date / integer | B02764, 1/1/2015, 3427, 29421 | Supply |
| Aggregate FHV Data.xlsx | `Date` + one column per company | Daily trips, Jul–Sep 2014 (sheet *Trips Per Day*) | date / integer | 2014-07-01, Uber 21228 | Market context |
| other-FHV-data-jan-aug-2015.csv | Base Number, Base Name, Pick Up Date, Number of Trips, Number of Vehicles | Daily trips and vehicles of other bases | text | B00013, 01/01/2015, " 26 " | Coverage check |

## Cleaned, analysis-ready tables (`data/cleaned/`)

The trip files (18.8 million rows) are aggregated by the notebook; nothing is invented or estimated.

### `data/cleaned/trips_hourly.csv` — Trips per date and hour, both periods (one row per date-hour with pickups) (8,725 rows)

| Column | Description | Data Type | Example | Business Meaning |
|---|---|---|---|---|
| `date` | Calendar date (YYYY-MM-DD) | date | 2014-04-01 | Time dimension |
| `hour` | Hour of the pickup, 0–23 | integer | 0 | Time-of-day demand |
| `trips` | Number of pickups | integer | 138 | Demand volume |
| `period` | '2014 Apr-Sep' or '2015 Jan-Jun' | text | 2014 Apr-Sep | Separates the two data periods |
| `year` | Calendar year | integer | 2014 | Year-over-year |
| `month` | Month (YYYY-MM) | text | 2014-04 | Monthly trend |
| `weekday` | Day name | text | Tuesday | Weekly pattern |
| `is_weekend` | Saturday or Sunday | boolean | False | Weekday vs weekend |
| `is_holiday` | US federal holiday | boolean | False | Special-day effect |
| `time_band` | Night 0-5, Morning peak 6-9, Midday 10-15, Evening peak 16-19, Late evening 20-23 | text | Night (0-5) | Shift planning |

### `data/cleaned/trips_daily.csv` — Trips per day with calendar attributes (364 rows)

| Column | Description | Data Type | Example | Business Meaning |
|---|---|---|---|---|
| `date` | Calendar date (YYYY-MM-DD) | date | 2014-04-01 | Time dimension |
| `period` | '2014 Apr-Sep' or '2015 Jan-Jun' | text | 2014 Apr-Sep | Separates the two data periods |
| `trips` | Number of pickups | integer | 14546 | Demand volume |
| `year` | Calendar year | integer | 2014 | Year-over-year |
| `month` | Month (YYYY-MM) | text | 2014-04 | Monthly trend |
| `weekday` | Day name | text | Tuesday | Weekly pattern |
| `is_weekend` | Saturday or Sunday | boolean | False | Weekday vs weekend |
| `is_holiday` | US federal holiday | boolean | False | Special-day effect |
| `partial_day` | Day with missing hours (2014-09-30: no data after 22:59) | boolean | False | Data-quality flag |

### `data/cleaned/trips_daily_base.csv` — Trips per base and day (2014: base in the file; 2015: dispatching base) (2,061 rows)

| Column | Description | Data Type | Example | Business Meaning |
|---|---|---|---|---|
| `date` | Calendar date (YYYY-MM-DD) | date | 2014-04-01 | Time dimension |
| `base_code` | TLC base licence number | text | B02512 | Dispatching base |
| `base_name` | Base name | text | Unter | Readable label |
| `trips` | Number of pickups | integer | 1011 | Demand volume |

### `data/cleaned/trips_zone_daily_2015.csv` — 2015 trips per taxi zone and day (44,551 rows)

| Column | Description | Data Type | Example | Business Meaning |
|---|---|---|---|---|
| `date` | Calendar date (YYYY-MM-DD) | date | 2015-01-01 | Time dimension |
| `location_id` | TLC taxi-zone id (1–265) | integer | 1 | Pickup location |
| `trips` | Number of pickups | integer | 1 | Demand volume |

### `data/cleaned/trips_area_hourly_2015.csv` — 2015 trips per service area, date and hour (27,662 rows)

| Column | Description | Data Type | Example | Business Meaning |
|---|---|---|---|---|
| `date` | Calendar date (YYYY-MM-DD) | date | 2015-01-01 | Time dimension |
| `hour` | Hour of the pickup, 0–23 | integer | 0 | Time-of-day demand |
| `service_area` | Borough, or 'Airports' for JFK, LaGuardia, Newark | text | Airports | Geographic segment |
| `trips` | Number of pickups | integer | 20 | Demand volume |

### `data/cleaned/pickup_grid_2014.csv` — 2014 pickups inside the NYC area, counted on a 0.005° grid (for maps) (5,665 rows)

| Column | Description | Data Type | Example | Business Meaning |
|---|---|---|---|---|
| `lat` | Latitude of the cell centre (0.005° grid) | decimal | 40.505 | Map position |
| `lon` | Longitude of the cell centre (0.005° grid) | decimal | -74.265 | Map position |
| `trips` | Number of pickups | integer | 1 | Demand volume |

### `data/cleaned/foil_daily_base.csv` — Uber FOIL file, Jan–Feb 2015: active vehicles and trips per base and day (354 rows)

| Column | Description | Data Type | Example | Business Meaning |
|---|---|---|---|---|
| `date` | Calendar date (YYYY-MM-DD) | date | 2015-01-01 | Time dimension |
| `base_code` | TLC base licence number | text | B02512 | Dispatching base |
| `base_name` | Base name | text | Unter | Readable label |
| `active_vehicles` | Vehicles that worked for the base that day | integer | 190 | Supply |
| `trips` | Number of pickups | integer | 1132 | Demand volume |
| `trips_per_vehicle` | trips ÷ active_vehicles | decimal | 5.957894736842105 | Productivity proxy (not driver utilization) |

### `data/cleaned/market_daily_2014.csv` — TLC summary in long format: trips per company and day, Jul–Sep 2014 (1,104 rows)

| Column | Description | Data Type | Example | Business Meaning |
|---|---|---|---|---|
| `date` | Calendar date (YYYY-MM-DD) | date | 2014-07-01 | Time dimension |
| `company` | Company in the TLC summary (Uber, Lyft, Yellow Taxis, Green Taxis, 8 car services) | text | American | Market context |
| `trips` | Number of pickups | integer | 921 | Demand volume |

### `data/cleaned/fhv_other_daily_2015.csv` — Other for-hire bases (TLC base report) summed per day — used only to show its changing coverage (243 rows)

| Column | Description | Data Type | Example | Business Meaning |
|---|---|---|---|---|
| `date` | Calendar date (YYYY-MM-DD) | date | 2015-01-01 | Time dimension |
| `bases_reporting` | Other for-hire bases with data that day | integer | 57 | Report coverage (changes by month) |
| `trips` | Number of pickups | integer | 25023 | Demand volume |
| `vehicles` | Vehicles of the bases that reported a vehicle count | integer | 3002 | Supply of other bases |
| `trips_with_vehicle_count` | Trips of the bases that reported a vehicle count | integer | 25023 | Denominator match for trips per vehicle |

### `data/cleaned/dim_zone.csv` — Taxi-zone reference table with service area (265 rows)

| Column | Description | Data Type | Example | Business Meaning |
|---|---|---|---|---|
| `location_id` | TLC taxi-zone id (1–265) | integer | 1 | Pickup location |
| `borough` | Borough (EWR = Newark Airport; Unknown for ids 264-265) | text | EWR | Geography |
| `zone` | Taxi-zone name | text | Newark Airport | Geography |
| `is_airport` | JFK (132), LaGuardia (138) or Newark (1) | boolean | True | Airport demand |
| `service_area` | Borough, or 'Airports' for JFK, LaGuardia, Newark | text | Airports | Geographic segment |

### `data/cleaned/dim_base.csv` — Uber base reference table (8 rows)

| Column | Description | Data Type | Example | Business Meaning |
|---|---|---|---|---|
| `base_code` | TLC base licence number | text | B02512 | Dispatching base |
| `base_name` | Base name | text | Unter | Readable label |

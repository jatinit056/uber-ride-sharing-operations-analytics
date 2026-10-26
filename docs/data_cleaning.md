# Data cleaning

All cleaning happens in `notebooks/uber_operations_analysis.ipynb` (sections 5–12). Raw files are never modified; the
notebook writes aggregated tables to `data/cleaned/`. Every step is logged in `reports/cleaning_log.csv` and every check
in `reports/data_quality_checks.csv`. SQL (which reads the raw trip files itself) and Python agree on 148/148 checks.

## Cleaning log

| Step | Table | Rows affected | Action |
|---|---|---|---|
| Parse 'Date/Time' text (M/D/YYYY H:MM:SS) to datetime | pickups_2014 | 4,534,327 | type conversion |
| Flag pickups outside the NYC area (kept in counts, left out of the map) | pickups_2014 | 29,749 | flag |
| Keep identical rows (validated against TLC daily totals) | pickups_2014 | 82,581 | kept + documented |
| Flag 2014-09-30 as partial day (no pickups after 22:59) | pickups_2014 | 33,431 | flag |
| Parse 'Pickup_date' text to datetime | pickups_2015 | 14,270,479 | type conversion |
| Fill missing affiliated base with 'Unknown' | pickups_2015 | 162,195 | fill missing |
| Keep identical rows (minute + zone level data; possible ~2% double records documented) | pickups_2015 | 898,225 | kept + documented |
| Add service area (airports separated from their borough) | taxi_zones | 3 | derived column |
| Parse FOIL dates; add trips per active vehicle | foil_daily | 354 | type conversion + derived |
| Reshape TLC summary from wide (one column per company) to long | market_daily_2014 | 1,104 | reshape |
| Drop empty helper columns and blank trailing line | fhv_other_2015 | 1 | remove empty |
| Convert text numbers with thousands separators (' 1,137 ') to integers | fhv_other_2015 | 26,181 | type conversion |
| Vehicle count shown as '-' on days with trips -> missing (not zero) | fhv_other_2015 | 1,716 | set missing |

## Data-quality checks

| Check | Result | Action |
|---|---|---|
| 2014 timestamps inside the month of their file | 0 mismatches | none needed |
| 2014 date range | 2014-04-01 00:00 to 2014-09-30 22:59 | none |
| 2014-09-30 hours present | 23 of 24 (last pickup 22:59) | flag: last hour of the period missing |
| 2014 pickups outside the NYC area (lat 40.49-40.92, lon -74.27 to -73.68) | 29,749 (0.66%) | kept in trip counts (real trips), excluded from the pickup map |
| 2014 pickups far outside the metro area | 2,561 | kept (included in the row above) |
| 2014 base codes known | 100% known (5 bases) | none |
| 2015 date range | 2015-01-01 00:00 to 2015-06-30 23:59 | none |
| 2015 dispatching bases known | 100% known (8 bases) | none |
| 2015 affiliated base outside Uber's 8 bases | 12.62% of trips (284 affiliated bases) | kept: drivers affiliated with other bases can take Uber trips |
| 2015 locationID found in zone table | 100% | none |
| 2015 pickups in zone 264/265 ('Unknown') | 6,264 (0.04%) | kept as borough 'Unknown' |
| 2015-03-08 (clocks move forward 2:00 -> 3:00) | hour 2 present: False | expected - no action |
| 2015 timestamp precision | seconds present in 98% of Jan-Feb rows, 0% of Mar-Jun rows | precision changed in March 2015; analysis is hourly |
| FOIL rows = 59 days x 6 bases | 354 rows, 6 bases | none |
| FOIL active vehicles / trips > 0 | True | none |
| TLC summary Uber column = 2014 pickup rows per day | 92 of 92 days identical | validation passed |
| Base report: Uber bases included? | 0 rows | report covers other bases only |
| Base report: vehicle count shown as '-' | 1,716 base-days (all with trips > 0) | treated as missing |
| Base report: bases reporting per day, by month | 01: 59, 02: 58, 03: 55, 04: 195, 05: 202, 06: 165, 07: 122, 08: 5 | coverage changes from month to month -> NOT used for market share |

## Key decisions

### 1. Identical rows are kept as trips

| | 2014 | 2015 |
|---|---|---|
| Identical rows | 82,581 (1.82%) | 898,225 (6.29%) |
| Time precision | minute | seconds in Jan–Feb (98% of rows), minute from March |
| Evidence | TLC daily totals = row counts on 92/92 days **only if the rows are kept** | Jan–Feb: rows are +2.1% vs FOIL totals with identical rows, +0.3% without |
| Decision | keep (validated) | keep — minute-level rows in busy zones are often different trips; possible overcount ≈ 1.8% documented |

Removing them would delete real trips in 2014 (the TLC counts them) and create an artificial drop in March 2015, when
timestamps lose their seconds. The possible 2015 overcount does not change any conclusion (year-over-year growth
4.14× → about 4.07× if 2015 were 1.8% lower).

### 2. Other decisions

* **Pickups outside the NYC area** (2014, 29,749 rows, 0.66%) are real trips —
  kept in all counts, left out of the pickup map only.
* **Missing affiliated base** (2015, 162,195 rows) → "Unknown"; the dispatching base is always present.
* **Unknown taxi zone** (ids 264/265, 6,264 rows) → borough "Unknown"; excluded from area shares of known zones.
* **2014-09-30** has no pickups after 22:59 (also missing in the TLC's own total) — kept and flagged as a partial day.
* **2015-03-08** has no 2 am hour because clocks moved forward — expected, no action.
* **Base report vehicle counts shown as "-"** (1,716 base-days that do have trips) → missing, not zero.
* **The 2015 base report of other car services is not used for market share**: bases reporting per day go from about
  59 (January) to 202 (May) and
  5 (August), so its totals mostly reflect reporting coverage.
* **January 2015 blizzard** — the dip on 26–27 January is real (NYC travel ban, external event) and is kept; those two
  days are excluded only from the "normal day" baselines used to measure holiday effects.

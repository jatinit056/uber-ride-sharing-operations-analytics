# Raw data — source and provenance

| Item | Detail |
|---|---|
| Dataset | **Uber TLC FOIL response** — Uber pickups in New York City and related NYC Taxi & Limousine Commission (TLC) files |
| Original source | NYC Taxi & Limousine Commission. FiveThirtyEight requested the data under New York's Freedom of Information Law (FOIL) on 20 July 2015 and received it in batches on 3 Aug, 15 Sep and 22 Sep 2015. |
| Publisher | FiveThirtyEight — https://github.com/fivethirtyeight/uber-tlc-foil-response (files used from commit `63bb878b76f47f69b4527d50af57aac26dead983`) |
| On Kaggle | Republished as *Uber Pickups in New York City* (https://www.kaggle.com/datasets/fivethirtyeight/uber-pickups-in-new-york-city). Kaggle could not be reached from the environment used to build this project, so the files were taken from FiveThirtyEight's own repository (the original publisher). |
| License / terms | The source repository has no license file. The data are public records released by the TLC. FiveThirtyEight's data repository (https://github.com/fivethirtyeight/data) states: "Unless otherwise noted, our data sets are available under the Creative Commons Attribution 4.0 International License". Credit NYC TLC and FiveThirtyEight when you reuse the data. |
| Retrieved | 22 Oct 2026 |
| Stories using this data | FiveThirtyEight (2015): *Uber Is Serving New York's Outer Boroughs More Than Taxis Are*; *Public Transit Should Be Uber's New Best Friend*; *Uber Is Taking Millions Of Manhattan Rides Away From Taxis*; *Is Uber Making NYC Rush-Hour Traffic Worse?* |

## Files and checksums

The 7 large trip files exceed GitHub's 25 MB web-upload limit, so they are **not stored in this repository**.
`python scripts/download_data.py` downloads them from the pinned commit and checks every SHA-256 checksum below
(`SHA256SUMS.txt`). The files are never modified.

| File | Size | Location | SHA-256 |
|---|---|---|---|
| `uber-raw-data-apr14.csv` | 26.1 MB | downloaded by `scripts/download_data.py` | `4c92b95b9918e73a…` |
| `uber-raw-data-may14.csv` | 30.2 MB | downloaded by `scripts/download_data.py` | `3940ebee250998e3…` |
| `uber-raw-data-jun14.csv` | 30.7 MB | downloaded by `scripts/download_data.py` | `ca999fb126a068a4…` |
| `uber-raw-data-jul14.csv` | 36.9 MB | downloaded by `scripts/download_data.py` | `42bc47c906a3d17b…` |
| `uber-raw-data-aug14.csv` | 38.3 MB | downloaded by `scripts/download_data.py` | `710e5766a8f2c13c…` |
| `uber-raw-data-sep14.csv` | 47.5 MB | downloaded by `scripts/download_data.py` | `3c7bda88de4106b5…` |
| `uber-raw-data-janjune-15.csv.zip` | 70.7 MB | downloaded by `scripts/download_data.py` | `b85c7373ce0b0186…` |
| `uber-raw-data-janjune-15.csv` | 551.7 MB | extracted by the download script | `e6bd991a1d8a673e…` |
| `taxi-zone-lookup.csv` | 8 KB | in this folder | `5dc91d7d4eb133ca…` |
| `Uber-Jan-Feb-FOIL.csv` | 10 KB | in this folder | `d76ff1bc09f209d5…` |
| `other-FHV-data-jan-aug-2015.csv` | 1.4 MB | in this folder | `301e64d245da7352…` |
| `Aggregate FHV Data.xlsx` | 30 KB | in this folder | `b71389da39f42c1d…` |

## What each file contains

| File | Rows | Columns |
|---|---|---|
| `uber-raw-data-apr14.csv` … `sep14.csv` | 4,534,327 pickups (Apr–Sep 2014) | `Date/Time` (M/D/YYYY H:MM:SS), `Lat`, `Lon`, `Base` |
| `uber-raw-data-janjune-15.csv.zip` | 14,270,479 pickups (Jan–Jun 2015) | `Dispatching_base_num`, `Pickup_date`, `Affiliated_base_num`, `locationID` |
| `taxi-zone-lookup.csv` | 265 zones | `LocationID`, `Borough`, `Zone` (carriage-return line endings) |
| `Uber-Jan-Feb-FOIL.csv` | 354 base-days | `dispatching_base_number`, `date`, `active_vehicles`, `trips` |
| `Aggregate FHV Data.xlsx` | 4 sheets; sheet *Trips Per Day* = 92 days | Daily trips of 8 car services, Lyft, Uber, yellow and green taxis (Jul–Sep 2014) |
| `other-FHV-data-jan-aug-2015.csv` | 334 bases, 26,181 base-days | Base Number, Base Name, Pick Up Date, Number of Trips, Number of Vehicles (5 title lines) |

Uber base codes (from the source README): B02512 Unter, B02598 Hinter, B02617 Weiter, B02682 Schmecken,
B02764 Danach-NY, B02765 Grun, B02835 Dreist, B02836 Drinnen.

## Validation of the raw data

* The TLC's own daily Uber totals in `Aggregate FHV Data.xlsx` equal the number of 2014 pickup rows on **92 of
  92 days** (Jul–Sep 2014).
* The FOIL daily totals (Jan–Feb 2015) are within 2.1% of the 2015 pickup rows
  (0.3% after removing identical rows) — see `docs/data_cleaning.md`.
* Not used: the trip-level files of 10 other car services in `other-FHV-data/` of the source repository (out of scope).

# Power BI dashboard — Uber / Ride-Sharing Operations Analytics (NYC)

[`Uber_NYC.pbix`](./Uber_NYC.pbix) · built in Power BI Desktop · 3 pages · 44 DAX measures · data imported from
`data/cleaned/` (fact_daily 364 · fact_hourly 8,725 · fact_zone_daily 44,551 · fact_area_hourly 27,662 · fact_base_daily 2,061 · fact_foil 354 · fact_market 1,104 · dim_zone 265 · dim_base 8 rows).

| Page | Screenshot |
|---|---|
| Executive Overview | [`screenshots/powerbi_page1_executive_overview.png`](../screenshots/powerbi_page1_executive_overview.png) |
| Detailed Analysis | [`screenshots/powerbi_page2_detailed_analysis.png`](../screenshots/powerbi_page2_detailed_analysis.png) |
| Business Insights | [`screenshots/powerbi_page3_business_insights.png`](../screenshots/powerbi_page3_business_insights.png) |

## What is on each page

* **Executive Overview** — 7 KPI cards (Trips, Jan–Jun 2015, Avg trips / day, 2015, Growth Apr–Jun, YoY, Peak hour, 2015, Manhattan share, Trips / active vehicle / day, Uber vs yellow taxis, Sep 2014); Column chart — Average trips per day by month; Column chart — Trips by calendar month: 2014 vs 2015; Bar chart — Share of trips by dispatching base; Bar chart — Pickups by service area, Jan–Jun 2015.
* **Detailed Analysis** — Matrix (heat map) — Average trips per hour — weekday × hour of day; Line chart — Share of the day's trips by hour; Bar chart — Top 10 pickup zones, Jan–Jun 2015; Column chart — Airports' share of pickups by hour, 2015.
* **Business Insights** — Line chart — Trips per day in 2015 and 7-day average (blizzard travel ban: 27 Jan); Bar chart — Trips per active vehicle per day (FOIL, Jan–Feb 2015); Line chart — Uber vs Lyft trips per day, Jul–Sep 2014 (TLC); Bar chart — Growth in trips per day, Jan → Jun 2015.

Slicers on every page (synced): Day type, Period.

## Data model (star schema, single-direction many-to-one relationships)

| From (many) | To (one) |
|---|---|
| `fact_daily[date]` | `Date[Date]` |
| `fact_hourly[date]` | `Date[Date]` |
| `fact_base_daily[date]` | `Date[Date]` |
| `fact_zone_daily[date]` | `Date[Date]` |
| `fact_area_hourly[date]` | `Date[Date]` |
| `fact_foil[date]` | `Date[Date]` |
| `fact_market[date]` | `Date[Date]` |
| `fact_zone_daily[location_id]` | `dim_zone[location_id]` |
| `fact_base_daily[base_code]` | `dim_base[base_code]` |
| `fact_foil[base_code]` | `dim_base[base_code]` |

`Date` is built in Power Query and marked as the date table. All measures live in the `_Measures` table:
[`measures.dax`](measures.dax). All queries: [`power_query.m`](power_query.m).

## Open and refresh

1. Open `Uber_NYC.pbix` in Power BI Desktop (free, Windows). The data is already inside the file.
2. To reload from the CSVs: **Home → Transform data → Edit parameters → DataFolder** = the full path of this
   project's `data\cleaned\` folder (ending with `\`), then **Refresh**.

## Numbers to expect (no slicer selected)

| Measure | Value |
|---|---|
| Trips 2015 | 14.27M (14,270,479) |
| Avg Trips per Day 2015 | 78,842 |
| YoY Growth Apr-Jun % | 314.4% |
| Peak Hour 2015 | 19:00 |
| Manhattan Share % | 72.7% |
| Trips per Active Vehicle per Day | 8.92 |
| Uber vs Yellow Sep 2014 | 7.8% |

These match the notebook (`reports/kpi_summary.json`), SQL (`sql/results/`) and the Excel workbook.

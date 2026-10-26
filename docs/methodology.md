# Methodology

## Workflow

```
Raw files (checksummed, read-only) → understanding → data-quality checks → cleaning (logged) → feature engineering
→ aggregated tables (data/cleaned) → EDA → KPIs → trends → segments (time, geography, bases, supply, market)
→ SQL (PostgreSQL, 25 queries on the raw trip tables) → reconciliation (SQL = Python) → Excel workbook → Power BI → insights
```

## KPI definitions (identical in Python, SQL, Excel and Power BI)

| KPI | Definition |
|---|---|
| Trips | Number of pickup records (identical rows kept — see `docs/data_cleaning.md`) |
| Average trips per day | Trips ÷ days with data in the period (month or period) |
| Month-over-month growth | Trips this month ÷ trips last month − 1 (also per day, because months differ in length) |
| Year-over-year growth | Trips Apr–Jun 2015 ÷ trips Apr–Jun 2014 − 1 (the only months in both periods) |
| Peak hour / quietest hour | Hour of the day with the highest / lowest average trips (2015) |
| Peak-to-trough ratio | Average trips in the peak hour ÷ average trips in the quietest hour |
| Hourly share | Trips in an hour ÷ trips of the same day type (weekday or weekend) |
| Service area | Borough, with JFK (132), LaGuardia (138) and Newark (1) as "Airports" |
| Area share | Trips in the area ÷ trips with a known zone (2015) |
| Holiday / storm effect | Trips on the day ÷ average of the same weekday 1–3 weeks before and after (special days excluded) − 1 |
| Trips per active vehicle per day | FOIL trips ÷ FOIL active vehicles over the same base-days — a **productivity proxy**, not driver utilization |
| Fleet growth | Average active vehicles per day, last full week ÷ first full week − 1 (Jan–Feb 2015) |
| Uber vs yellow taxis | Average Uber trips per day ÷ average yellow-taxi trips per day (TLC summary, same days) |

## Why these comparisons are fair

* **Per-day averages** remove the effect of month length (28–31 days).
* **Year over year uses only April–June**, the months present in both periods.
* **Holiday effects use a local baseline** (same weekday a few weeks around the day) because demand grew
  +49% within the first half of 2015 — a period-wide average would distort the comparison.
* **Market comparisons use the TLC summary**, which covers the same 92 days for every company.

## Validation

* Raw files: SHA-256 checksums; the TLC's daily Uber totals match the 2014 pickup rows on 92/92 days.
* SQL vs Python: 148/148 checks match (`reports/sql_python_reconciliation.md`); SQL recomputes everything from the raw trip tables.
* Excel: every analysis formula recalculated and compared with Python (`reports/excel_verification.md`).

## Limitations

* Pickup records only — no fares, revenue, distance, duration, drop-off, cancellations, waiting times or driver hours.
* 2014 (Apr–Sep) and 2015 (Jan–Jun) cover different months; seasonality and growth cannot be fully separated.
* 2015 counts may include about 1.8% double records (see data cleaning).
* The FOIL supply file covers only January–February 2015; "active vehicles" says nothing about hours online.
* External events (blizzard) are used only as context for dips that are visible in the data.

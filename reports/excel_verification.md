# Excel workbook verification

Workbook: [`excel/uber_operations_analysis.xlsx`](../excel/uber_operations_analysis.xlsx) · 59,553 formulas · 9 charts · checked 22 Oct 2026

**Result: 69 of 69 checks passed.**

## How the workbook was checked

1. **Structure** — the file was opened with `openpyxl` to confirm the Excel Tables, named ranges, PivotTables,
   conditional-formatting rules, charts and the Excel functions used.
2. **Full recalculation** — every formula was recalculated from scratch in LibreOffice Calc (headless) and the results
   were compared with the values stored in the file.
3. **Independent numbers** — the recalculated results were compared with values computed separately in pandas from the
   cleaned CSV files, the notebook KPIs (`reports/kpi_summary.json`) and the SQL results (`sql/results/`).

The recalculation was done in **LibreOffice, not Microsoft Excel**. The file is a standard `.xlsx` built for Excel
2019 / 2021 / 365; the PivotTables are set to refresh when the file is opened.

## Checks

| # | Check | Result |
|---|---|---|
| 1 | defined names present | PASS |
| 2 | Excel tables present | PASS |
| 3 | pivot tables parsed by openpyxl | PASS |
| 4 | conditional formatting rules present | PASS |
| 5 | analysis sheets contain formulas | PASS |
| 6 | uses SUMIFS | PASS |
| 7 | uses COUNTIFS | PASS |
| 8 | uses AVERAGEIFS | PASS |
| 9 | uses MINIFS | PASS |
| 10 | uses VLOOKUP | PASS |
| 11 | uses XLOOKUP | PASS |
| 12 | uses INDEX | PASS |
| 13 | uses MATCH | PASS |
| 14 | uses IFS | PASS |
| 15 | uses IF | PASS |
| 16 | uses CHOOSE | PASS |
| 17 | uses WEEKDAY | PASS |
| 18 | uses EDATE | PASS |
| 19 | uses DATE | PASS |
| 20 | uses LARGE | PASS |
| 21 | uses SMALL | PASS |
| 22 | uses RANK.EQ | PASS |
| 23 | uses PERCENTILE.INC | PASS |
| 24 | uses CORREL | PASS |
| 25 | uses IFERROR | PASS |
| 26 | charts present | PASS |
| 27 | all formulas: no errors after LibreOffice recalculation | PASS |
| 28 | all formulas (incl. data-sheet helper columns): recalculated = cached values | PASS |
| 29 | Summary trips 2015 = KPI | PASS |
| 30 | Summary avg trips/day 2015 = KPI | PASS |
| 31 | Summary YoY growth = KPI | PASS |
| 32 | Summary peak hour = KPI | PASS |
| 33 | Summary Manhattan share = KPI | PASS |
| 34 | Summary airport share = KPI | PASS |
| 35 | Summary trips per vehicle-day = KPI | PASS |
| 36 | Summary Uber vs yellow Sep 2014 = KPI | PASS |
| 37 | Summary ✓ checks all pass | PASS |
| 38 | Summary trips by year = KPI | PASS |
| 39 | Summary avg trips/day by year = KPI | PASS |
| 40 | Monthly trips & avg/day = Python (12 months) | PASS |
| 41 | YoY growth by month = Python | PASS |
| 42 | Weekday x hour heat map = SQL Q06 (168 cells, rounded) | PASS |
| 43 | Hourly averages = SQL Q05 | PASS |
| 44 | Peak/quietest hour and ratio = Python | PASS |
| 45 | Busiest/quietest weekday = Python | PASS |
| 46 | Time-band shares = Python | PASS |
| 47 | Top-10 days = pandas | PASS |
| 48 | Quietest day = Python | PASS |
| 49 | Median day 2015 = Python | PASS |
| 50 | Holiday & blizzard effects = SQL Q10 (9 days) | PASS |
| 51 | Area shares of known zones = SQL Q11 | PASS |
| 52 | Area growth Jan->Jun = Python | PASS |
| 53 | Outside-Manhattan share Jan/Jun = Python | PASS |
| 54 | Zones for 50% / 80% = Python | PASS |
| 55 | Known zones without pickup = Python | PASS |
| 56 | Top zone = Python | PASS |
| 57 | Airport trips = Python | PASS |
| 58 | Airport share by hour = Python (24 hours) | PASS |
| 59 | Base shares 2014/2015 = Python | PASS |
| 60 | Trips per vehicle-day by base = Python | PASS |
| 61 | Trips per vehicle-day all/weekend/weekday = Python | PASS |
| 62 | Avg active vehicles per day = Python | PASS |
| 63 | Correlation vehicles vs trips = Python | PASS |
| 64 | Fleet growth (full weeks) = Python | PASS |
| 65 | Uber vs yellow Jul/Sep 2014 = Python | PASS |
| 66 | Lyft Sep trips/day = Python | PASS |
| 67 | First Lyft day = Python | PASS |
| 68 | Pivot 1 trips by hour x period = pandas | PASS |
| 69 | Pivot 2 trips by service area = pandas | PASS |

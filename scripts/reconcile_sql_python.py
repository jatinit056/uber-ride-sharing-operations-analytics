"""Reconcile the SQL results (sql/results/*.csv) with the Python notebook KPIs (reports/kpi_summary.json).

Run after the notebook and scripts/run_sql_queries.py:
    python scripts/reconcile_sql_python.py
Writes reports/sql_python_reconciliation.md; exit code 1 if any check fails.
"""
import json
from pathlib import Path

import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
kpi = json.loads((ROOT / "reports" / "kpi_summary.json").read_text())
q = {f.stem: pd.read_csv(f) for f in sorted((ROOT / "sql" / "results").glob("Q*.csv"))}
checks = []


def check(name, sql_value, python_value, tolerance=0.0):
    if isinstance(python_value, str) or isinstance(sql_value, str):
        ok = str(sql_value) == str(python_value)
        shown = python_value
    else:
        ok = abs(float(sql_value) - float(python_value)) <= tolerance
        shown = round(float(python_value), 4)
    checks.append((name, sql_value, shown, "PASS" if ok else "FAIL"))


# Q01 - volume
q01 = q["Q01"].set_index("period")
for period, year in (("2014 Apr-Sep", "2014"), ("2015 Jan-Jun", "2015")):
    check(f"Trips {year} (Q01)", q01.loc[period, "trips"], kpi[f"trips_{year}"])
    check(f"Days {year} (Q01)", q01.loc[period, "days"], kpi[f"days_{year}"])
    check(f"Avg trips per day {year} (Q01)", q01.loc[period, "avg_trips_per_day"], kpi[f"avg_daily_trips_{year}"], 0.05)

# Q02 - months
q02 = q["Q02"].set_index("month")
for month, v in kpi["monthly_trips"].items():
    check(f"Trips {month} (Q02)", q02.loc[month, "trips"], v)
    check(f"Avg trips per day {month} (Q02)", q02.loc[month, "avg_trips_per_day"], kpi["monthly_avg_trips_per_day"][month], 0.05)

# Q03 - year over year
q03 = q["Q03"].set_index("month")
for month, v in kpi["yoy_growth_by_month_pct"].items():
    check(f"YoY growth {month} % (Q03)", q03.loc[month, "yoy_growth_pct"], v, 0.01)
check("YoY growth Apr-Jun % (Q03)", q03.loc["Apr-Jun", "yoy_growth_pct"], kpi["yoy_growth_apr_jun_pct"], 0.01)

# Q04 / Q05 - weekdays and hours
q04 = q["Q04"].set_index("weekday")
check("Busiest weekday (Q04 rank 1)", q04.index[q04["busiest_rank"] == 1][0], kpi["busiest_weekday_2015"])
check("Busiest weekday avg trips (Q04)", q04.loc[kpi["busiest_weekday_2015"], "avg_trips_per_day"], kpi["busiest_weekday_2015_avg"], 0.05)
check("Quietest weekday avg trips (Q04)", q04.loc[kpi["quietest_weekday_2015"], "avg_trips_per_day"], kpi["quietest_weekday_2015_avg"], 0.05)
q05 = q["Q05"]
check("Peak hour (Q05)", int(q05.loc[q05["flag"] == "peak", "hour"].iloc[0]), kpi["peak_hour_2015"])
check("Quietest hour (Q05)", int(q05.loc[q05["flag"] == "trough", "hour"].iloc[0]), kpi["quietest_hour_2015"])
check("Peak-to-trough ratio (Q05)", q05["peak_to_trough_ratio"].iloc[0], kpi["peak_to_trough_ratio_2015"], 0.005)

# Q08 / Q09 / Q17 - days
q08 = q["Q08"]
top = q08[q08["rank_busiest"] == 1].iloc[0]
low = q08[q08["rank_quietest"] == 1].iloc[0]
check("Busiest day 2015 (Q08)", top["trip_date"], kpi["peak_day_2015"])
check("Busiest day trips (Q08)", top["trips"], kpi["peak_day_2015_trips"])
check("Quietest day 2015 (Q08)", low["trip_date"], kpi["lowest_day_2015"])
check("Quietest day trips (Q08)", low["trips"], kpi["lowest_day_2015_trips"])
check("Running total at 30 Jun 2015 (Q09)", q["Q09"]["running_total"].iloc[-1], kpi["trips_2015"])
q17 = q["Q17"].set_index("weekday")
check("Median trips per day 2015 (Q17)", q17.loc["All days", "median_trips"], kpi["median_daily_trips_2015"], 0.5)

# Q10 - holidays and the blizzard
q10 = q["Q10"].set_index("day")
for day, v in kpi["holiday_effect_pct"].items():
    check(f"Holiday {day} vs normal % (Q10)", q10.loc[day, "vs_normal_pct"], v, 0.01)
check("Blizzard 2015-01-27 vs normal Tuesday % (Q10)", q10.loc["2015-01-27", "vs_normal_pct"], kpi["blizzard_vs_normal_tuesday_pct"], 0.01)

# Q11 / Q12 - areas
q11 = q["Q11"].set_index("service_area")
for area, v in kpi["area_share_2015"].items():
    check(f"Share of pickups {area} % (Q11)", q11.loc[area, "share_pct"], v * 100, 0.001)
check("Manhattan share of known zones % (Q11)", q11.loc["Manhattan", "share_of_known_zones_pct"], kpi["manhattan_share_2015"] * 100, 0.001)
check("Airport share of known zones % (Q11)", q11.loc["Airports", "share_of_known_zones_pct"], kpi["airport_share_2015"] * 100, 0.001)
q12 = q["Q12"].set_index("service_area")
for area, v in kpi["area_growth_jan_jun_2015_pct"].items():
    check(f"Trips/day growth Jan-Jun {area} % (Q12)", q12.loc[area, "growth_pct"], v, 0.01)
check("Outside-Manhattan share Jan % (Q12)", 100 - q12.loc["Manhattan", "share_jan_pct"], kpi["outside_manhattan_share_jan_2015"] * 100, 0.011)
check("Outside-Manhattan share Jun % (Q12)", 100 - q12.loc["Manhattan", "share_jun_pct"], kpi["outside_manhattan_share_jun_2015"] * 100, 0.011)

# Q13 / Q14 / Q15 - zones
q13 = q["Q13"]
top_zone = q13[(q13["borough"] == kpi["top_zone_borough"]) & (q13["rank_in_borough"] == 1)].iloc[0]
check("Top zone (Q13)", top_zone["zone"], kpi["top_zone"])
check("Top zone trips (Q13)", top_zone["trips"], kpi["top_zones"][kpi["top_zone"]])
check("Zones without pickups (Q14)", "; ".join(sorted(q["Q14"]["zone"])), "; ".join(sorted(kpi["zones_without_pickups"])))
q15 = q["Q15"].iloc[0]
check("Zones for 50% of trips (Q15)", q15["zones_for_50pct"], kpi["zones_for_50pct"])
check("Zones for 80% of trips (Q15)", q15["zones_for_80pct"], kpi["zones_for_80pct"])
check("Top-10 zone share % (Q15)", q15["top10_share_pct"], kpi["top10_zone_share"] * 100, 0.01)
check("Zones with pickups (Q15)", q15["zones_with_pickups"], kpi["zones_with_pickups"])

# Q16 - airports by hour
q16 = q["Q16"].set_index("hour")
for hour, v in kpi["airport_share_by_hour"].items():
    check(f"Airport share at hour {hour} % (Q16)", q16.loc[int(hour), "airport_share_pct"], v * 100, 0.01)
check("Hour with highest airport share (Q16)", int(q16["airport_share_pct"].idxmax()), kpi["airport_peak_share_hour"])

# Q18 / Q19 - bases
q18 = q["Q18"].set_index("base_name")
for name, v in kpi["base_share_2014"].items():
    check(f"Base share 2014 {name} % (Q18)", q18.loc[name, "share_2014_pct"], v * 100, 0.01)
for name, v in kpi["base_share_2015"].items():
    check(f"Base share 2015 {name} % (Q18)", q18.loc[name, "share_2015_pct"], v * 100, 0.01)
q19 = q["Q19"].set_index("affiliation")
check("Dispatching = affiliated base % (Q19)", q19.loc["Same base", "share_pct"], kpi["dispatch_equals_affiliated_share"] * 100, 0.01)

# Q20 - Q23 - supply (FOIL)
q20 = q["Q20"].set_index("base_name")
for name, v in kpi["base_trips_per_vehicle"].items():
    check(f"Trips per vehicle-day {name} (Q20)", q20.loc[name, "trips_per_vehicle_day"], v, 0.0005)
    check(f"Avg active vehicles {name} (Q20)", q20.loc[name, "avg_active_vehicles"], kpi["base_avg_active_vehicles"][name], 0.05)
q21 = q["Q21"].set_index("day_type")
check("Trips per vehicle-day, all days (Q21)", q21.loc["All days", "trips_per_vehicle_day"], kpi["trips_per_vehicle_day"], 0.0005)
check("Trips per vehicle-day, weekends (Q21)", q21.loc["Weekend", "trips_per_vehicle_day"], kpi["trips_per_vehicle_weekend"], 0.0005)
check("Trips per vehicle-day, weekdays (Q21)", q21.loc["Weekday", "trips_per_vehicle_day"], kpi["trips_per_vehicle_weekday"], 0.0005)
q22 = q["Q22"].set_index("base_code")
check("Pickup rows vs FOIL trips, all bases % (Q22)", q22.loc["ALL", "difference_pct"], kpi["foil_vs_pickup_rows_pct"], 0.01)
q23 = q["Q23"]
check("First full week (Q23)", q23["week_start"].iloc[0], kpi["fleet_first_full_week"])
check("Last full week (Q23)", q23["week_start"].iloc[-1], kpi["fleet_last_full_week"])
check("Fleet growth first -> last full week % (Q23)", q23["growth_vs_first_week_pct"].iloc[-1], kpi["fleet_growth_pct"], 0.01)

# Q24 / Q25 - market context
q24 = q["Q24"].set_index("month")
check("Uber vs yellow taxi Jul 2014 % (Q24)", q24.loc["2014-07", "uber_vs_yellow_pct"], kpi["uber_vs_yellow_jul_2014"] * 100, 0.01)
check("Uber vs yellow taxi Sep 2014 % (Q24)", q24.loc["2014-09", "uber_vs_yellow_pct"], kpi["uber_vs_yellow_sep_2014"] * 100, 0.01)
check("Lyft trips per day Sep 2014 (Q24)", q24.loc["2014-09", "lyft_trips_per_day"], kpi["lyft_avg_daily_sep_2014"], 0.05)
check("First Lyft day (Q24)", q24.loc["2014-07", "first_lyft_day_in_month"], kpi["lyft_first_day"])
q25 = q["Q25"].set_index("month")
for month, v in kpi["fhv_report_bases_per_day_by_month"].items():
    check(f"Base report: bases per day {month} (Q25)", q25.loc[month, "avg_bases_reporting_per_day"], v, 0.05)

passed = sum(c[3] == "PASS" for c in checks)
report = ["# SQL vs Python reconciliation", "",
          "Each KPI was calculated independently in PostgreSQL (`sql/analysis_queries.sql`, from the raw trip files) and in "
          "pandas (notebook). A check passes when both agree (counts exactly; percentages and averages within the "
          "rounding of the SQL output).", "",
          "| Check | SQL | Python | Result |", "|---|---|---|---|"]
report += [f"| {name} | {s} | {p} | {r} |" for name, s, p, r in checks]
report += ["", f"**{passed} of {len(checks)} checks passed.**"]
(ROOT / "reports" / "sql_python_reconciliation.md").write_text("\n".join(report), encoding="utf-8")
print(f"{passed}/{len(checks)} checks passed")
for c in checks:
    if c[3] == "FAIL":
        print("FAIL:", c)
raise SystemExit(0 if passed == len(checks) else 1)

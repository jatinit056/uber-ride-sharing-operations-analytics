# Business insights — Uber / Ride-Sharing Operations Analytics (NYC 2014–2015)

Scope: 18,804,806 Uber pickups (4,534,327 in Apr–Sep 2014, 14,270,479 in Jan–Jun 2015), FOIL vehicle data (Jan–Feb 2015) and TLC market summaries. Numbers come from `reports/kpi_summary.json` (notebook) and `sql/results/` (PostgreSQL).

## 1. Demand quadrupled in one year

**Insight:** April–June 2015 had 4.1× the pickups of April–June 2014 (+314.4%; April +304%, May +313%, June +324%).

**Business impact:** Supply (drivers and vehicles) has to grow at the same speed or waiting times and lost trips rise.

**Recommendation:** Build a driver-recruiting and onboarding plan sized to the demand trend, reviewed monthly.

## 2. Growth continued inside each period

**Insight:** Average trips per day rose +82.1% from April to September 2014 and +49.0% from January to June 2015, reaching 93,896 per day in June 2015 (busiest day: Saturday 27 June 2015, 136,193 trips).

**Business impact:** Last month's driver supply is not enough for next month.

**Recommendation:** Forecast weekly and add a growth buffer to supply targets.

## 3. Saturday is the busiest day, Monday the quietest

**Insight:** In 2015 Saturdays averaged 92,868 trips and Mondays 65,164 (43% more on Saturdays). Weekends averaged 83,987 trips per day vs 76,768 on weekdays.

**Business impact:** Weekly demand is predictable, so driver schedules can follow it.

**Recommendation:** Plan more driver hours for Friday/Saturday and fewer for Monday.

## 4. Evening peak, early-morning trough

**Insight:** The busiest hour is 7–8 pm (5,566 trips on average) — 5.8× the 4–5 am trough. On weekdays 4–8 pm carries 25.9% of the day's trips and 6–10 am 16.3%.

**Business impact:** Supply needs to swing by almost 6× within a day.

**Recommendation:** Use peak-hour incentives for 4–8 pm and morning commute slots; avoid paying incentives at 3–6 am.

## 5. Weekend nights are a separate market

**Insight:** At weekends 21.4% of trips start between midnight and 6 am (weekdays 8.8%); the busiest weekend hour is midnight–1 am. Weekday and weekend hourly patterns correlate only 0.58 (Monday vs Saturday) vs 0.98 (Tuesday vs Thursday).

**Business impact:** A single daily shift plan does not fit weekends.

**Recommendation:** Create separate weekend night shifts (Fri/Sat 10 pm–3 am) and nightlife-area positioning.

## 6. Holidays and storms cut demand sharply

**Insight:** Against the same weekday 1–3 weeks around them, federal holidays averaged -23% (Memorial Day 2014 -45%, Independence Day 2014 -50%; Presidents' Day 2015 was the exception at +16%). The blizzard travel-ban day, Tuesday 27 January 2015, had 25,954 trips (-60%).

**Business impact:** Paying full peak incentives on these days wastes money.

**Recommendation:** Keep a holiday and severe-weather playbook with lower supply targets and storm safety rules.

## 7. Manhattan dominates, but outer boroughs grow faster

**Insight:** Manhattan had 72.7% of 2015 pickups; the share outside Manhattan rose from 25.3% (January) to 29.1% (June). Trips per day grew +124% in the Bronx, +95% in Queens and +61% in Brooklyn vs +41% in Manhattan.

**Business impact:** A growing share of demand comes from outside Manhattan, where pickups are spread over a much larger area.

**Recommendation:** Add driver incentives and marketing in Brooklyn, Queens and the Bronx.

## 8. Demand is concentrated in a few zones

**Insight:** 25 of 260 zones with pickups produce half of all trips and 56 produce 80%; the top zone, Midtown Center, alone has 3.2%. Only 3 zones (islands) had no pickups.

**Business impact:** Positioning drivers in a small set of zones covers most demand.

**Recommendation:** Use zone-level heat maps for driver positioning and pickup-point design in the top 25 zones.

## 9. Airports are a steady, distinct demand source

**Insight:** JFK (289,169 trips) and LaGuardia (266,119) generated 3.9% of 2015 pickups (3,068 per day); Newark only 105. Most airport pickups happen at 10–11 pm; their share of all pickups peaks at 3–4 pm (5.7%) and is lowest at 4–5 am (0.5%).

**Business impact:** Airport pickups follow their own pattern — the most at 10–11 pm, the largest share of all trips at 3–4 pm — so city-wide supply plans miss them.

**Recommendation:** Run airport queues and positioning by hour, with extra supply in the afternoon and late evening.

## 10. Dispatch concentrated in one base

**Insight:** Danach-NY (B02764) dispatched 40.3% of 2015 trips, up from 5.8% in 2014, while Weiter fell from 32.2% to 14.5% and Hinter from 30.7% to 10.7%.

**Business impact:** Operational risk and reporting now depend heavily on one base.

**Recommendation:** Monitor base-level KPIs (trips, vehicles, productivity) weekly and keep backup dispatch capacity.

## 11. About nine trips per active vehicle per day

**Insight:** In Jan–Feb 2015 an average of 7,845 vehicles were active per day (+15.6% from the first to the last full week). Each did 8.9 trips per day (9.9 at weekends, 8.5 on weekdays); by base from 7.1 (Unter) to 9.3 (Schmecken).

**Business impact:** Vehicle productivity differs by base and day; low-productivity bases may have too many vehicles for their demand.

**Recommendation:** Track trips per active vehicle weekly by base; collect driver online hours to measure true utilization.

## 12. Uber was gaining on taxis and far ahead of Lyft

**Insight:** Uber's trips per day equalled 6.1% of yellow-taxi trips in July 2014 and 7.8% in September (TLC summary). Lyft started on 25 July 2014 and averaged 3,867 trips per day in September; Uber had 8.9× as many.

**Business impact:** Uber's daily trips grew 33% from July to September while yellow-taxi trips grew 5%, and Uber had a large lead over its app-based rival.

**Recommendation:** Protect the lead with reliability (short waits) rather than price; watch Lyft's growth monthly.

## What the data cannot tell us

* **Revenue, fares, surge pricing and profit** — the files contain no prices.
* **Trip distance, duration and drop-off location** — only pickups are recorded.
* **Cancellations, waiting times, ratings** — not in the data.
* **True driver utilization and earnings** — there are no driver hours; trips per active vehicle is only a proxy.
* **Market share against other car services in 2015** — the TLC base report's coverage changes month to month.

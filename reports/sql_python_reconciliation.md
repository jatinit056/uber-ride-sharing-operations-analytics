# SQL vs Python reconciliation

Each KPI was calculated independently in PostgreSQL (`sql/analysis_queries.sql`, from the raw trip files) and in pandas (notebook). A check passes when both agree (counts exactly; percentages and averages within the rounding of the SQL output).

| Check | SQL | Python | Result |
|---|---|---|---|
| Trips 2014 (Q01) | 4534327 | 4534327.0 | PASS |
| Days 2014 (Q01) | 183 | 183.0 | PASS |
| Avg trips per day 2014 (Q01) | 24777.7 | 24777.7432 | PASS |
| Trips 2015 (Q01) | 14270479 | 14270479.0 | PASS |
| Days 2015 (Q01) | 181 | 181.0 | PASS |
| Avg trips per day 2015 (Q01) | 78842.4 | 78842.4254 | PASS |
| Trips 2014-04 (Q02) | 564516 | 564516.0 | PASS |
| Avg trips per day 2014-04 (Q02) | 18817.2 | 18817.2 | PASS |
| Trips 2014-05 (Q02) | 652435 | 652435.0 | PASS |
| Avg trips per day 2014-05 (Q02) | 21046.3 | 21046.2903 | PASS |
| Trips 2014-06 (Q02) | 663844 | 663844.0 | PASS |
| Avg trips per day 2014-06 (Q02) | 22128.1 | 22128.1333 | PASS |
| Trips 2014-07 (Q02) | 796121 | 796121.0 | PASS |
| Avg trips per day 2014-07 (Q02) | 25681.3 | 25681.3226 | PASS |
| Trips 2014-08 (Q02) | 829275 | 829275.0 | PASS |
| Avg trips per day 2014-08 (Q02) | 26750.8 | 26750.8065 | PASS |
| Trips 2014-09 (Q02) | 1028136 | 1028136.0 | PASS |
| Avg trips per day 2014-09 (Q02) | 34271.2 | 34271.2 | PASS |
| Trips 2015-01 (Q02) | 1953801 | 1953801.0 | PASS |
| Avg trips per day 2015-01 (Q02) | 63025.8 | 63025.8387 | PASS |
| Trips 2015-02 (Q02) | 2263620 | 2263620.0 | PASS |
| Avg trips per day 2015-02 (Q02) | 80843.6 | 80843.5714 | PASS |
| Trips 2015-03 (Q02) | 2259773 | 2259773.0 | PASS |
| Avg trips per day 2015-03 (Q02) | 72895.9 | 72895.9032 | PASS |
| Trips 2015-04 (Q02) | 2280837 | 2280837.0 | PASS |
| Avg trips per day 2015-04 (Q02) | 76027.9 | 76027.9 | PASS |
| Trips 2015-05 (Q02) | 2695553 | 2695553.0 | PASS |
| Avg trips per day 2015-05 (Q02) | 86953.3 | 86953.3226 | PASS |
| Trips 2015-06 (Q02) | 2816895 | 2816895.0 | PASS |
| Avg trips per day 2015-06 (Q02) | 93896.5 | 93896.5 | PASS |
| YoY growth Apr % (Q03) | 304.03 | 304.0341 | PASS |
| YoY growth May % (Q03) | 313.15 | 313.1527 | PASS |
| YoY growth Jun % (Q03) | 324.33 | 324.3309 | PASS |
| YoY growth Apr-Jun % (Q03) | 314.36 | 314.3612 | PASS |
| Busiest weekday (Q04 rank 1) | Saturday | Saturday | PASS |
| Busiest weekday avg trips (Q04) | 92867.8 | 92867.8077 | PASS |
| Quietest weekday avg trips (Q04) | 65163.5 | 65163.5385 | PASS |
| Peak hour (Q05) | 19 | 19.0 | PASS |
| Quietest hour (Q05) | 4 | 4.0 | PASS |
| Peak-to-trough ratio (Q05) | 5.79 | 5.79 | PASS |
| Busiest day 2015 (Q08) | 2015-06-27 | 2015-06-27 | PASS |
| Busiest day trips (Q08) | 136193 | 136193.0 | PASS |
| Quietest day 2015 (Q08) | 2015-01-27 | 2015-01-27 | PASS |
| Quietest day trips (Q08) | 25954 | 25954.0 | PASS |
| Running total at 30 Jun 2015 (Q09) | 14270479 | 14270479.0 | PASS |
| Median trips per day 2015 (Q17) | 78343 | 78343.0 | PASS |
| Holiday 2014-05-26 vs normal % (Q10) | -45.43 | -45.4288 | PASS |
| Holiday 2014-07-04 vs normal % (Q10) | -49.76 | -49.7585 | PASS |
| Holiday 2014-09-01 vs normal % (Q10) | -22.64 | -22.6353 | PASS |
| Holiday 2015-01-01 vs normal % (Q10) | -16.3 | -16.2998 | PASS |
| Holiday 2015-01-19 vs normal % (Q10) | -20.35 | -20.3533 | PASS |
| Holiday 2015-02-16 vs normal % (Q10) | 16.07 | 16.0653 | PASS |
| Holiday 2015-05-25 vs normal % (Q10) | -23.47 | -23.4697 | PASS |
| Blizzard 2015-01-27 vs normal Tuesday % (Q10) | -59.67 | -59.6696 | PASS |
| Share of pickups Manhattan % (Q11) | 72.675 | 72.6749 | PASS |
| Share of pickups Brooklyn % (Q11) | 16.271 | 16.2714 | PASS |
| Share of pickups Queens % (Q11) | 5.526 | 5.5265 | PASS |
| Share of pickups Airports % (Q11) | 3.892 | 3.8919 | PASS |
| Share of pickups Bronx % (Q11) | 1.543 | 1.5427 | PASS |
| Share of pickups Staten Island % (Q11) | 0.049 | 0.0488 | PASS |
| Share of pickups Unknown % (Q11) | 0.044 | 0.0439 | PASS |
| Manhattan share of known zones % (Q11) | 72.707 | 72.7068 | PASS |
| Airport share of known zones % (Q11) | 3.894 | 3.8936 | PASS |
| Trips/day growth Jan-Jun Airports % (Q12) | 72.72 | 72.723 | PASS |
| Trips/day growth Jan-Jun Bronx % (Q12) | 124.45 | 124.4523 | PASS |
| Trips/day growth Jan-Jun Brooklyn % (Q12) | 60.72 | 60.7243 | PASS |
| Trips/day growth Jan-Jun Manhattan % (Q12) | 41.28 | 41.2771 | PASS |
| Trips/day growth Jan-Jun Queens % (Q12) | 95.05 | 95.0461 | PASS |
| Trips/day growth Jan-Jun Staten Island % (Q12) | 110.18 | 110.1823 | PASS |
| Outside-Manhattan share Jan % (Q12) | 25.25 | 25.2515 | PASS |
| Outside-Manhattan share Jun % (Q12) | 29.11 | 29.1069 | PASS |
| Top zone (Q13) | Midtown Center | Midtown Center | PASS |
| Top zone trips (Q13) | 460732 | 460732.0 | PASS |
| Zones without pickups (Q14) | Governor's Island/Ellis Island/Liberty Island; Governor's Island/Ellis Island/Liberty Island; Rikers Island | Governor's Island/Ellis Island/Liberty Island; Governor's Island/Ellis Island/Liberty Island; Rikers Island | PASS |
| Zones for 50% of trips (Q15) | 25.0 | 25.0 | PASS |
| Zones for 80% of trips (Q15) | 56.0 | 56.0 | PASS |
| Top-10 zone share % (Q15) | 24.69 | 24.6934 | PASS |
| Zones with pickups (Q15) | 260.0 | 260.0 | PASS |
| Airport share at hour 0 % (Q16) | 4.77 | 4.7723 | PASS |
| Airport share at hour 1 % (Q16) | 2.89 | 2.8871 | PASS |
| Airport share at hour 2 % (Q16) | 1.17 | 1.1696 | PASS |
| Airport share at hour 3 % (Q16) | 0.55 | 0.5543 | PASS |
| Airport share at hour 4 % (Q16) | 0.51 | 0.5138 | PASS |
| Airport share at hour 5 % (Q16) | 4.13 | 4.1339 | PASS |
| Airport share at hour 6 % (Q16) | 4.87 | 4.8712 | PASS |
| Airport share at hour 7 % (Q16) | 3.28 | 3.2768 | PASS |
| Airport share at hour 8 % (Q16) | 2.63 | 2.6303 | PASS |
| Airport share at hour 9 % (Q16) | 2.69 | 2.6931 | PASS |
| Airport share at hour 10 % (Q16) | 3.68 | 3.6786 | PASS |
| Airport share at hour 11 % (Q16) | 3.43 | 3.4295 | PASS |
| Airport share at hour 12 % (Q16) | 3.31 | 3.3083 | PASS |
| Airport share at hour 13 % (Q16) | 3.63 | 3.6346 | PASS |
| Airport share at hour 14 % (Q16) | 4.42 | 4.4164 | PASS |
| Airport share at hour 15 % (Q16) | 5.68 | 5.6787 | PASS |
| Airport share at hour 16 % (Q16) | 4.63 | 4.6299 | PASS |
| Airport share at hour 17 % (Q16) | 4.02 | 4.0209 | PASS |
| Airport share at hour 18 % (Q16) | 3.47 | 3.4677 | PASS |
| Airport share at hour 19 % (Q16) | 3.74 | 3.7391 | PASS |
| Airport share at hour 20 % (Q16) | 4.13 | 4.1313 | PASS |
| Airport share at hour 21 % (Q16) | 4.53 | 4.5345 | PASS |
| Airport share at hour 22 % (Q16) | 4.67 | 4.6684 | PASS |
| Airport share at hour 23 % (Q16) | 4.96 | 4.9621 | PASS |
| Hour with highest airport share (Q16) | 15 | 15.0 | PASS |
| Base share 2014 Unter % (Q18) | 4.54 | 4.5359 | PASS |
| Base share 2014 Hinter % (Q18) | 30.72 | 30.7237 | PASS |
| Base share 2014 Weiter % (Q18) | 32.17 | 32.1735 | PASS |
| Base share 2014 Schmecken % (Q18) | 26.75 | 26.7468 | PASS |
| Base share 2014 Danach-NY % (Q18) | 5.82 | 5.82 | PASS |
| Base share 2015 Drinnen % (Q18) | 0.01 | 0.0139 | PASS |
| Base share 2015 Dreist % (Q18) | 0.19 | 0.1866 | PASS |
| Base share 2015 Unter % (Q18) | 1.79 | 1.7923 | PASS |
| Base share 2015 Grun % (Q18) | 8.08 | 8.0777 | PASS |
| Base share 2015 Hinter % (Q18) | 10.7 | 10.698 | PASS |
| Base share 2015 Weiter % (Q18) | 14.5 | 14.4951 | PASS |
| Base share 2015 Schmecken % (Q18) | 24.42 | 24.4178 | PASS |
| Base share 2015 Danach-NY % (Q18) | 40.32 | 40.3186 | PASS |
| Dispatching = affiliated base % (Q19) | 74.44 | 74.4404 | PASS |
| Trips per vehicle-day Schmecken (Q20) | 9.275 | 9.2748 | PASS |
| Avg active vehicles Schmecken (Q20) | 1210.7 | 1210.6949 | PASS |
| Trips per vehicle-day Hinter (Q20) | 9.22 | 9.2202 | PASS |
| Avg active vehicles Hinter (Q20) | 994.1 | 994.1186 | PASS |
| Trips per vehicle-day Weiter (Q20) | 9.09 | 9.0903 | PASS |
| Avg active vehicles Weiter (Q20) | 1351.8 | 1351.8305 | PASS |
| Trips per vehicle-day Danach-NY (Q20) | 8.811 | 8.8106 | PASS |
| Avg active vehicles Danach-NY (Q20) | 3682.9 | 3682.8814 | PASS |
| Trips per vehicle-day Grun (Q20) | 8.579 | 8.579 | PASS |
| Avg active vehicles Grun (Q20) | 382.6 | 382.6271 | PASS |
| Trips per vehicle-day Unter (Q20) | 7.146 | 7.1456 | PASS |
| Avg active vehicles Unter (Q20) | 222.5 | 222.4576 | PASS |
| Trips per vehicle-day, all days (Q21) | 8.924 | 8.9238 | PASS |
| Trips per vehicle-day, weekends (Q21) | 9.933 | 9.9333 | PASS |
| Trips per vehicle-day, weekdays (Q21) | 8.536 | 8.5363 | PASS |
| Pickup rows vs FOIL trips, all bases % (Q22) | 2.11 | 2.111 | PASS |
| First full week (Q23) | 2015-01-05 | 2015-01-05 | PASS |
| Last full week (Q23) | 2015-02-16 | 2015-02-16 | PASS |
| Fleet growth first -> last full week % (Q23) | 15.57 | 15.5708 | PASS |
| Uber vs yellow taxi Jul 2014 % (Q24) | 6.14 | 6.1382 | PASS |
| Uber vs yellow taxi Sep 2014 % (Q24) | 7.77 | 7.7658 | PASS |
| Lyft trips per day Sep 2014 (Q24) | 3866.6 | 3866.6333 | PASS |
| First Lyft day (Q24) | 2014-07-25 | 2014-07-25 | PASS |
| Base report: bases per day 2015-01 (Q25) | 59.2 | 59.1935 | PASS |
| Base report: bases per day 2015-02 (Q25) | 58.4 | 58.3929 | PASS |
| Base report: bases per day 2015-03 (Q25) | 54.7 | 54.7097 | PASS |
| Base report: bases per day 2015-04 (Q25) | 195.0 | 195.0 | PASS |
| Base report: bases per day 2015-05 (Q25) | 202.2 | 202.2258 | PASS |
| Base report: bases per day 2015-06 (Q25) | 164.9 | 164.9333 | PASS |
| Base report: bases per day 2015-07 (Q25) | 122.4 | 122.3548 | PASS |
| Base report: bases per day 2015-08 (Q25) | 5.0 | 5.0 | PASS |

**148 of 148 checks passed.**
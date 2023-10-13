## Google BigQuery Setup Instructions
### Steps
1. Sign into Google Cloud Console (with personal gmail)
2. Open BigQuery
3. In the explorer, click add data - > explore public datasets - > American Community Survey - > View Dataset.
4. In the explorer, click add data - > explore public datasets - > Chicago Taxi Trips - > View Dataset.
5. bigquery-public-data project will appear in the explorer.
Note: There is no need to set up credit card, you receive 1TB free for querying.

## Problem Statement
Use the age_specific_fertility_rates table in the census_bureau_international Dataset.
For each country, show the top 5 years by total_fertility_rate, in order (first year is the highest):
* If there is a tie in the total fertility rates between years, order them by year descending. This means that if 2000 and 2002 have the same total fertility rates, 2002 will be year_1 and 200 will be year_2
* Filter the results to include countries where the year of the highest fertility rate is later than the year of the 5th highest rate.
* year_1 should have the country's highest total_fertility_rate. <br />

Structure of the answer should be as follows:
* country_name | year_1 | year_2 | year_5
* Example:
Qatar | 1988 | 1986 | 1989 | 1990 | 1987
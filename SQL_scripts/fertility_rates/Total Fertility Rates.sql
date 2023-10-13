-- SQL Query to Select Top 5 Years by Total Fertility Rate for Each Country
-- The query also filters countries where the year of the highest fertility
--     rate is later than the year of the 5th highest rate.

-- Step 1: Rank each year for each country by total_fertility_rate, breaking ties by year in descending order
WITH RankedFertility AS (
    SELECT 
        country_name,
        year,
        total_fertility_rate,
        ROW_NUMBER() OVER (PARTITION BY country_name ORDER BY total_fertility_rate DESC, year DESC) AS rn
    FROM age_specific_fertility_rates
),

-- Step 2: Select the top 5 years for each country and pivot them into separate columns
Top5Years AS (
    SELECT 
        country_name,
        MAX(CASE WHEN rn = 1 THEN year END) AS year_1,
        MAX(CASE WHEN rn = 2 THEN year END) AS year_2,
        MAX(CASE WHEN rn = 3 THEN year END) AS year_3,
        MAX(CASE WHEN rn = 4 THEN year END) AS year_4,
        MAX(CASE WHEN rn = 5 THEN year END) AS year_5
    FROM RankedFertility
    WHERE rn <= 5
    GROUP BY country_name
)

-- Step 3: Filter the results to include only countries where year_1 > year_5
SELECT 
    country_name,
    year_1,
    year_2,
    year_3,
    year_4,
    year_5
FROM Top5Years
WHERE year_1 IS NOT NULL AND year_5 IS NOT NULL AND year_1 > year_5
ORDER BY country_name;
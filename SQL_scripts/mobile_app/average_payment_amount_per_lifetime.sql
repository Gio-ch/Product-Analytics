-- Assumptions:
-- 1. A player's "lifetime" starts on the day they install the game (Day 0).
-- 2. The "first 10 days of a player's lifetime" refers to the first 10 calendar days starting from the
--    installation date, not the first 10 days of activity. 
-- 3. "Next 7/30 days" excludes the current day and includes the subsequent 7 or 30 calendar days.
-- 4. Multiple payments made by a single user on the same day are aggregated.
-- 5. The time component of event_time was assumed not relevant for day calculations; only the date part is used.
-- 6. The dataset is complete, i.e., every 'payment' event has a corresponding 'install' event.
-- 7. All timestamps are in the same time zone.


-- Create and Populate Currency Conversion Table
CREATE TABLE IF NOT EXISTS GameAnalyticsDB.currency_conversion (
    currency_code VARCHAR(3) PRIMARY KEY,
    to_eur_rate FLOAT
);
DELETE FROM GameAnalyticsDB.currency_conversion;  -- Clear existing data
INSERT INTO GameAnalyticsDB.currency_conversion (currency_code, to_eur_rate)
VALUES 
('EUR', 1),
('USD', 0.85),
('GBP', 1.17),
('JPY', 0.0075);

-- Step 1: Create Cohort Table with Install Dates
WITH cohort_table AS (
  SELECT user_id, MIN(event_time) AS install_date
  FROM GameAnalyticsDB.fact_table
  WHERE event_name = 'install'
  GROUP BY user_id
),
-- Step 2: Generate Each Day in Player's Lifetime (0 to 9)
numbers AS (
  SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL
  SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL
  SELECT 8 UNION ALL SELECT 9
),
player_lifetime_days AS (
  SELECT c.user_id, n AS lifetime_day, 
  DATE_ADD(c.install_date, INTERVAL n DAY) AS event_day
  FROM cohort_table c
  CROSS JOIN numbers
),
-- Step 3: Calculate Daily Payments for Each User in EUR
daily_payments AS (
  SELECT 
    user_id, 
    DATE(event_time) AS payment_day, 
    SUM(f.amount * cc.to_eur_rate) AS daily_payment_sum_eur
  FROM GameAnalyticsDB.fact_table f
  JOIN GameAnalyticsDB.currency_conversion cc ON f.currency = cc.currency_code --
  WHERE event_name = 'payment'
  GROUP BY user_id, DATE(event_time)
),
-- Step 4: Calculate Sum of Payments for Next 7 and 30 Days
-- This CTE calculates the sum of payments for the next 7 and 30 days for each user for each day in their lifetime.
payment_sums AS (
  SELECT 
    p.user_id,
    p.lifetime_day,
    SUM(CASE 
          WHEN TIMESTAMPDIFF(DAY, DATE(p.event_day), DATE(d.payment_day)) BETWEEN 1 AND 7 THEN d.daily_payment_sum_eur
          ELSE 0 
        END) AS sum_next_7_days,
    SUM(CASE 
          WHEN TIMESTAMPDIFF(DAY, DATE(p.event_day), DATE(d.payment_day)) BETWEEN 1 AND 30 THEN d.daily_payment_sum_eur 
          ELSE 0 
        END) AS sum_next_30_days
  FROM player_lifetime_days p
  LEFT JOIN daily_payments d ON p.user_id = d.user_id
  WHERE TIMESTAMPDIFF(DAY, DATE(p.event_day), DATE(d.payment_day)) BETWEEN 0 AND 30
  and p.lifetime_day BETWEEN 0 AND 9
  GROUP BY p.user_id, p.lifetime_day, p.event_day
)
-- Step 5: Calculate Averages for All Players within the First 10 Days of a Player's Lifetime
-- This query calculates the average payments for the next 7 and 30 days for all players for each of the first 10 days of their lifetime.
SELECT 
  lifetime_day,
  AVG(sum_next_7_days) AS avg_payment_next_7_days,
  AVG(sum_next_30_days) AS avg_payment_next_30_days
FROM payment_sums
GROUP BY lifetime_day
order by lifetime_day;
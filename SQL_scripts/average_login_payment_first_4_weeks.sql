-- Averages of Login and Payment counts in First 4 Weeks after installation

-- Assumptions:
-- 1. All timestamps are assumed to be in the same time zone.
-- 2. If there's no "install" event for a player, calculations are not possible.
-- 3. It's assumed that 'login' and 'payment' events only occur after an 'install' event for the same user_id.
-- 4. No missing data in the columns that are relevant for this analysis.

-- Optimization Notes:
-- For optimal performance, ensure that the following columns are indexed:
-- 1. user_id: is a strong candidate for indexing.
-- 2. event_name: 
-- 3. event_time:

WITH InstallationTime AS (
    SELECT 
        user_id,
        MIN(event_time) AS install_time
    FROM portfolio.fact_table
    WHERE event_name = 'install'
    GROUP BY user_id
),
-- Step 2 & 3: Filter Events and Count Them for Each User
EventCounts AS (
    SELECT
        a.user_id,
        COUNT( CASE WHEN b.event_name = 'login' THEN 1 ELSE NULL END) AS login_count,
        COUNT( CASE WHEN b.event_name = 'payment' THEN 1 ELSE NULL END) AS payment_count
    FROM InstallationTime AS a
    LEFT JOIN portfolio.fact_table AS b ON a.user_id = b.user_id
        AND b.event_time BETWEEN a.install_time AND DATE_ADD(a.install_time, INTERVAL 28 DAY)
    GROUP BY a.user_id
)
-- Step 4: Calculate Averages
SELECT 
    AVG(login_count) AS avg_logins,
    AVG(payment_count) AS avg_payments
FROM EventCounts;

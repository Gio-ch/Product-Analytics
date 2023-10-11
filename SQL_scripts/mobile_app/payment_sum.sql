-- Assumptions:
-- 1. Payments are ranked based on 'event_time'.
-- 2. There are no missing or NULL values in 'user_id', 'event_time', 'event_name', and 'amount'.
--    - Note: Checks for missing or NULL values were conducted
-- 3. The range from the 2nd to 7th payments is inclusive.

-- CTE to rank payments for each user
WITH RankedPayments AS (
    SELECT 
        user_id,
        amount,
        RANK() OVER (
            PARTITION BY user_id
            ORDER BY event_time ASC
            ) AS payment_rank
    FROM GameAnalyticsDB.fact_table
    WHERE event_name = 'payment'
)
-- Calculate the Total Amount Spent from the 2nd to 7th Payment Across All Users
SELECT 
    SUM(amount) AS total_amount_spent_from_2nd_to_7th
FROM RankedPayments
WHERE payment_rank BETWEEN 2 AND 7;

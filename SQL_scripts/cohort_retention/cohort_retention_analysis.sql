-- This query performs a cohort analysis to calculate the retention rate based on weekly cohorts.
-- The final output is a cohort table with columns representing the number of users retained each week from their first login week.

-- Step 1: Calculate the first login week for each user.
WITH First_Login_Week AS (
    SELECT 
        user_id, 
        MIN(EXTRACT(WEEK FROM login_date)) AS first_week
    FROM 
        metrics.login 
    GROUP BY 
        user_id
),
-- Step 2: Calculate the login week for each user's login event.
Login_Week AS (
    SELECT 
        user_id,
        EXTRACT(WEEK FROM login_date) AS login_week
    FROM 
        metrics.login 
    GROUP BY 
        user_id, login_week
),
-- Step 3: Calculate the relative week number for each login event based on the first login week and create the cohort table.
Cohort_Table AS (
    SELECT 
        flw.user_id,
        lw.login_week,
        flw.first_week,
        lw.login_week - flw.first_week AS week_number
    FROM   
        Login_Week lw
    JOIN 
        First_Login_Week flw
    ON 
        lw.user_id = flw.user_id
)
-- Step 4: Summarize the data to create the cohort table with one row for each first login week and columns representing the retention for each subsequent week.
SELECT 
    first_week AS first,
    SUM(CASE WHEN week_number = 0 THEN 1 ELSE 0 END) AS week_0,
    SUM(CASE WHEN week_number = 1 THEN 1 ELSE 0 END) AS week_1,
    SUM(CASE WHEN week_number = 2 THEN 1 ELSE 0 END) AS week_2,
    SUM(CASE WHEN week_number = 3 THEN 1 ELSE 0 END) AS week_3,
    SUM(CASE WHEN week_number = 4 THEN 1 ELSE 0 END) AS week_4,
    SUM(CASE WHEN week_number = 5 THEN 1 ELSE 0 END) AS week_5,
    SUM(CASE WHEN week_number = 6 THEN 1 ELSE 0 END) AS week_6,
    SUM(CASE WHEN week_number = 7 THEN 1 ELSE 0 END) AS week_7,
    SUM(CASE WHEN week_number = 8 THEN 1 ELSE 0 END) AS week_8,
    SUM(CASE WHEN week_number = 9 THEN 1 ELSE 0 END) AS week_9 
FROM 
    Cohort_Table
GROUP BY 
    first
ORDER BY 
    first;

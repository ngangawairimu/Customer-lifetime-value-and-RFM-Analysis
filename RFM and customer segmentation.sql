WITH registrations AS (
    -- Step 1: Identifying the registration week for each user
    SELECT 
        user_pseudo_id,
        -- Truncate the first visit date to the start of the week for each user
        DATE_TRUNC(PARSE_DATE('%Y%m%d', MIN(event_date)), WEEK) AS registration_week
    FROM 
        turing_data_analytics.raw_events
    -- Group by user to get the first event date as the registration date
    GROUP BY 
        user_pseudo_id
),

first_week_registration_count AS (
    -- Step 2: Count how many users registered in each week
    SELECT 
        COUNT(user_pseudo_id) AS cohort_size,  -- Number of users in each cohort
        registration_week  -- The registration week for each cohort
    FROM 
        registrations
    -- Group by registration week to get the cohort size for each week
    GROUP BY 
        registration_week
),

event_weeks AS (
    -- Step 3: Prepare the event data by calculating the event week and cleaning up revenue data
    SELECT
        user_pseudo_id,
        -- Truncate the event date to the start of the week
        DATE_TRUNC(PARSE_DATE('%Y%m%d', event_date), WEEK) AS event_week,
        -- Use COALESCE to ensure that NULL revenue values are treated as 0
        COALESCE(purchase_revenue_in_usd, 0) AS purchase_revenue_in_usd
    FROM
        turing_data_analytics.raw_events
),

weekly_revenue AS (
    -- Step 4: Calculate the revenue per registration cohort for each week (Week 0 to Week 11)
    SELECT 
        reg.registration_week,  -- Registration week from the first CTE
        fw.cohort_size,  -- Cohort size from the second CTE
        
        -- Revenue for Week 0 (the registration week)
        SUM(CASE WHEN ew.event_week = reg.registration_week THEN ew.purchase_revenue_in_usd ELSE 0 END) / fw.cohort_size AS revenue_week_0,

        -- Revenue for Week 1 (one week after registration)
        SUM(CASE WHEN ew.event_week = reg.registration_week + INTERVAL 1 WEEK THEN ew.purchase_revenue_in_usd ELSE 0 END) / fw.cohort_size AS revenue_week_1,

        -- Revenue for Week 2 (two weeks after registration)
        SUM(CASE WHEN ew.event_week = reg.registration_week + INTERVAL 2 WEEK THEN ew.purchase_revenue_in_usd ELSE 0 END) / fw.cohort_size AS revenue_week_2,

        -- Revenue for Week 3
        SUM(CASE WHEN ew.event_week = reg.registration_week + INTERVAL 3 WEEK THEN ew.purchase_revenue_in_usd ELSE 0 END) / fw.cohort_size AS revenue_week_3,

        -- Revenue for Week 4
        SUM(CASE WHEN ew.event_week = reg.registration_week + INTERVAL 4 WEEK THEN ew.purchase_revenue_in_usd ELSE 0 END) / fw.cohort_size AS revenue_week_4,

        -- Revenue for Week 5
        SUM(CASE WHEN ew.event_week = reg.registration_week + INTERVAL 5 WEEK THEN ew.purchase_revenue_in_usd ELSE 0 END) / fw.cohort_size AS revenue_week_5,

        -- Revenue for Week 6
        SUM(CASE WHEN ew.event_week = reg.registration_week + INTERVAL 6 WEEK THEN ew.purchase_revenue_in_usd ELSE 0 END) / fw.cohort_size AS revenue_week_6,

        -- Revenue for Week 7
        SUM(CASE WHEN ew.event_week = reg.registration_week + INTERVAL 7 WEEK THEN ew.purchase_revenue_in_usd ELSE 0 END) / fw.cohort_size AS revenue_week_7,

        -- Revenue for Week 8
        SUM(CASE WHEN ew.event_week = reg.registration_week + INTERVAL 8 WEEK THEN ew.purchase_revenue_in_usd ELSE 0 END) / fw.cohort_size AS revenue_week_8,

        -- Revenue for Week 9
        SUM(CASE WHEN ew.event_week = reg.registration_week + INTERVAL 9 WEEK THEN ew.purchase_revenue_in_usd ELSE 0 END) / fw.cohort_size AS revenue_week_9,

        -- Revenue for Week 10
        SUM(CASE WHEN ew.event_week = reg.registration_week + INTERVAL 10 WEEK THEN ew.purchase_revenue_in_usd ELSE 0 END) / fw.cohort_size AS revenue_week_10,

        -- Revenue for Week 11
        SUM(CASE WHEN ew.event_week = reg.registration_week + INTERVAL 11 WEEK THEN ew.purchase_revenue_in_usd ELSE 0 END) / fw.cohort_size AS revenue_week_11

    FROM 
        registrations AS reg  -- Using the registration data
    LEFT JOIN 
        event_weeks AS ew  -- Joining with the event data to get weekly revenues
        ON reg.user_pseudo_id = ew.user_pseudo_id
    JOIN 
        first_week_registration_count AS fw  -- Joining with cohort sizes
        ON reg.registration_week = fw.registration_week
    -- Grouping by registration week and cohort size to calculate revenue per cohort
    GROUP BY 
        reg.registration_week, fw.cohort_size
)

-- Final Selection: Output the weekly revenue per registration cohort
SELECT 
    registration_week,  -- The registration week for the cohort
    revenue_week_0,  -- Revenue for the registration week
    revenue_week_1,  -- Revenue for Week 1
    revenue_week_2,  -- Revenue for Week 2
    revenue_week_3,  -- Revenue for Week 3
    revenue_week_4,  -- Revenue for Week 4
    revenue_week_5,  -- Revenue for Week 5
    revenue_week_6,  -- Revenue for Week 6
    revenue_week_7,  -- Revenue for Week 7
    revenue_week_8,  -- Revenue for Week 8
    revenue_week_9,  -- Revenue for Week 9
    revenue_week_10,  -- Revenue for Week 10
    revenue_week_11  -- Revenue for Week 11
FROM 
    weekly_revenue
-- Sorting by the registration week for easy chronological viewing
ORDER BY 
    registration_week;

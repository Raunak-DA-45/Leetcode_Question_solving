/*****************************************************************************************
Purpose:
    This query generates a daily spending summary per platform category:
        - mobile
        - desktop
        - both (users who used both platforms on the same day)

Business Rules Implemented:
    1. A user is categorized as:
        - 'mobile'  ? if they only used mobile that day
        - 'desktop' ? if they only used desktop that day
        - 'both'    ? if they used both mobile and desktop on the same day
    2. The report must show ALL platform categories for every date,
       even if no users exist in that category (show 0 values).
    3. The output must include:
        - spend_date
        - platform category
        - total_amount (sum of spending)
        - total_users (distinct users in that category)

How the Query Works (Step-by-Step):
    Step 1: Aggregate spending per user per day and detect which platforms were used.
    Step 2: Classify users into mobile/desktop/both and aggregate totals.
    Step 3: Generate all combinations of dates × platform categories.
    Step 4: LEFT JOIN actual results to ensure missing combinations return 0.

*****************************************************************************************/


/*****************************************************************************************
    1??  DROP TABLE (Safety Cleanup)
*****************************************************************************************/
IF OBJECT_ID('dbo.Spending', 'U') IS NOT NULL
    DROP TABLE dbo.Spending;
GO


/*****************************************************************************************
    2??  CREATE TABLE
*****************************************************************************************/
-- This table stores how much each user spends per day and platform
CREATE TABLE dbo.Spending (
    user_id INT NOT NULL,              -- Unique identifier of the user
    spend_date DATE NOT NULL,          -- Date of spending
    platform VARCHAR(10) NOT NULL,     -- Platform used: 'mobile' or 'desktop'
    amount INT NOT NULL,               -- Amount spent
    
    -- Enforce valid platform values
    CONSTRAINT CHK_Spending_Platform 
        CHECK (platform IN ('desktop', 'mobile'))
);
GO


/*****************************************************************************************
    3??  INSERT SAMPLE DATA
*****************************************************************************************/
-- Sample dataset explanation:
-- User 1 uses both platforms on 2019-07-01
-- User 2 uses only mobile
-- User 3 uses only desktop

INSERT INTO dbo.Spending (user_id, spend_date, platform, amount)
VALUES 
(1, '2019-07-01', 'mobile', 100),
(1, '2019-07-01', 'desktop', 100),
(2, '2019-07-01', 'mobile', 100),
(2, '2019-07-02', 'mobile', 100),
(3, '2019-07-01', 'desktop', 100),
(3, '2019-07-02', 'desktop', 100);
GO


/*****************************************************************************************
    4??  FINAL QUERY
*****************************************************************************************/

WITH cte_user_day AS (
    -- Step 1:
    -- Aggregate per user per day.
    -- STRING_AGG detects whether user used one or both platforms.
    SELECT
        user_id,
        spend_date,
        STRING_AGG(platform, ',') AS platforms,
        SUM(amount) AS total_amount
    FROM dbo.Spending
    GROUP BY spend_date, user_id
),

cte_classified AS (
    -- Step 2:
    -- Convert platform list into business category:
    -- 'mobile,desktop' ? 'both'
    SELECT
        spend_date,
        IIF(platforms = 'mobile,desktop', 'both', platforms) AS platform,
        SUM(total_amount) AS total_amount,
        COUNT(user_id) AS total_users
    FROM cte_user_day
    GROUP BY 
        spend_date,
        IIF(platforms = 'mobile,desktop', 'both', platforms)
),

cte_all_combinations AS (
    -- Step 3:
    -- Generate all date × platform combinations
    SELECT DISTINCT 
        s.spend_date,
        p.platform
    FROM dbo.Spending s
    CROSS JOIN (
        SELECT 'mobile' AS platform
        UNION ALL 
        SELECT 'desktop'
        UNION ALL
        SELECT 'both'
    ) p
)

-- Step 4:
-- LEFT JOIN ensures missing combinations show 0 instead of NULL
SELECT
    ac.spend_date,
    ac.platform,
    ISNULL(c.total_amount, 0) AS total_amount,
    ISNULL(c.total_users, 0) AS total_users
FROM cte_all_combinations ac
LEFT JOIN cte_classified c
    ON ac.spend_date = c.spend_date
   AND ac.platform = c.platform
ORDER BY 
    ac.spend_date,
    ac.platform;

/**********************************************************************************************
Purpose of this script:
-----------------------
This script identifies all users who made **any two purchases within 7 days of each other**.
It recreates the Purchases table, loads sample data, and runs a query that finds qualifying users.

Business Rules Implemented:
---------------------------
1. A user qualifies if ANY pair of consecutive purchases occurred **within 7 days**.
2. The result should contain **unique user IDs only**.
3. Output must be **ordered by user_id**.

How the Query Works:
--------------------
1. We use a window function (LEAD) to look ahead at the next purchase date for each user,
   sorted by purchase_date.
2. For each purchase, we calculate the number of days between the current purchase and the next one.
3. If the difference is **? 7 days**, that user qualifies.
4. DISTINCT removes duplicates, since a user may have multiple close-together purchase pairs.
**********************************************************************************************/

---------------------------------------------------------
-- Drop table if it exists so the script is re-runnable
---------------------------------------------------------
IF OBJECT_ID('dbo.Purchases', 'U') IS NOT NULL
    DROP TABLE dbo.Purchases;
GO

---------------------------------------------------------
-- Create Purchases table
-- Each row represents a user's purchase on a specific date.
-- purchase_id : unique identifier for each purchase
-- user_id     : identifies who made the purchase
-- purchase_date : date of the purchase
---------------------------------------------------------
CREATE TABLE dbo.Purchases (
    purchase_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    purchase_date DATE NOT NULL
);
GO

---------------------------------------------------------
-- Insert sample data
-- This dataset includes multiple users with multiple purchases.
-- Some purchases from the same user are close enough (? 7 days) to qualify.
---------------------------------------------------------
INSERT INTO dbo.Purchases (purchase_id, user_id, purchase_date) VALUES
(4, 2, '2022-03-13'),
(1, 5, '2022-02-11'),
(3, 7, '2022-06-19'),
(6, 2, '2022-03-20'),
(5, 7, '2022-06-19'),
(2, 2, '2022-06-08');
GO

---------------------------------------------------------
-- View the raw data (helpful for beginners)
---------------------------------------------------------
SELECT * FROM dbo.Purchases;
GO

---------------------------------------------------------
-- Main Query: Find users with two purchases within 7 days
---------------------------------------------------------
SELECT DISTINCT user_id
FROM (
    SELECT
        user_id,
        purchase_date,

        -- LEAD looks ahead to the next purchase made by the same user
        LEAD(purchase_date) OVER(
            PARTITION BY user_id 
            ORDER BY purchase_date           -- ensures purchases are compared in order
        ) AS next_date

    FROM dbo.Purchases
) t
WHERE next_date IS NOT NULL                   -- ignore last row for each user (no next purchase)
  AND DATEDIFF(day, purchase_date, next_date) <= 7  -- check if purchases are within 7 days
ORDER BY user_id;
GO
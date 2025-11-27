/*
==================================================================================
Purpose: 
This script calculates the number of users eligible for a discount based on 
their purchase history within a given date range and a minimum purchase amount.

Business Rules:
1. A user is eligible if they made at least one purchase in the inclusive interval 
   of [startDate, endDate] (dates are treated as the start of the day, i.e., 
   'YYYY-MM-DD 00:00:00').
2. Only purchases with an amount greater than or equal to minAmount are considered.
3. Each user is counted only once regardless of multiple eligible purchases.

How the Query Works:
1. The Purchases table is created with columns for user_id, time_stamp, and amount.
2. Sample data is inserted to illustrate the scenario.
3. A scalar function get_user_id is created, which:
   - Accepts @startDate, @endDate, and @minAmount as input parameters.
   - Counts the distinct user_id values where the purchases meet the date and 
     amount criteria.
   - Returns this count as an integer.
4. The function is called with sample parameters to output the number of eligible users.
==================================================================================
*/

-- ============================================
-- Drop table if it already exists to avoid errors
-- ============================================
IF OBJECT_ID('dbo.Purchases', 'U') IS NOT NULL
    DROP TABLE dbo.Purchases;
GO

-- ============================================
-- Create Purchases table
-- ============================================
CREATE TABLE dbo.Purchases (
    user_id     INT        NOT NULL,  -- Unique ID for each user
    time_stamp  DATETIME   NOT NULL,  -- Timestamp when the purchase was made
    amount      INT        NOT NULL,  -- Amount paid for the purchase
    CONSTRAINT PK_Purchases PRIMARY KEY (user_id, time_stamp) -- Ensures each user's purchase at a timestamp is unique
);
GO

-- ============================================
-- Insert sample data into Purchases table
-- ============================================
INSERT INTO dbo.Purchases (user_id, time_stamp, amount)
VALUES
(1, '2022-04-20 09:03:00', 4416),   -- User 1, single purchase, high amount
(2, '2022-03-19 19:24:02', 678),    -- User 2, below minAmount
(3, '2022-03-18 12:03:09', 4523),   -- User 3, eligible
(3, '2022-03-30 09:43:42', 626);    -- User 3, another purchase but outside date range
GO

-- ============================================
-- Create function to count eligible users
-- ============================================
CREATE OR ALTER FUNCTION dbo.get_user_id
(
    @startDate DATE,   -- Start date for eligibility
    @endDate DATE,     -- End date for eligibility
    @minAmount INT     -- Minimum purchase amount to be eligible
)
RETURNS INT
AS
BEGIN
    DECLARE @result INT;

    -- Count distinct users who have at least one purchase in the given date range
    -- with an amount >= @minAmount
    SELECT @result = COUNT(DISTINCT user_id)
    FROM
    (
        SELECT *
        FROM dbo.Purchases
        WHERE time_stamp BETWEEN CAST(@startDate AS DATETIME) AND CAST(@endDate AS DATETIME)
          AND amount >= @minAmount
    ) t;

    RETURN @result;  -- Return the final count of eligible users
END;
GO

-- ============================================
-- Example usage of the function
-- ============================================
SELECT dbo.get_user_id('2022-03-08', '2022-03-20', 1000) AS id;
-- Expected result: 1 (only user 3 meets the criteria)

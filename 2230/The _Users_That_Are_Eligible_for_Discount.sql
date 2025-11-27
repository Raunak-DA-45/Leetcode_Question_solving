/*
================================================================================
PURPOSE:
    This script identifies users eligible for a discount based on their purchases.

BUSINESS RULES:
    1. A user is eligible if they made a purchase within a specified date range.
    2. The purchase amount must be greater than or equal to a specified minimum.
    3. Dates are inclusive and treated as starting at 00:00:00 on the given day.

HOW THE QUERY WORKS:
    1. Create a table "Purchases" to store user purchase records.
    2. Insert sample data into the Purchases table.
    3. Define a stored procedure "GetUserIds" that:
       a. Accepts @startDate, @endDate, and @minAmount as input parameters.
       b. Selects distinct user IDs from Purchases where:
           - time_stamp is between @startDate and @endDate.
           - amount is greater than or equal to @minAmount.
       c. Returns the eligible user IDs.
================================================================================
*/

-- Drop table if it already exists to avoid errors when running the script multiple times
DROP TABLE IF EXISTS Purchases;

-- Create the Purchases table
CREATE TABLE Purchases (
    user_id INT,           -- Unique ID representing each user
    time_stamp DATETIME,   -- Date and time when the purchase was made
    amount INT,            -- Amount paid in the purchase
    PRIMARY KEY (user_id, time_stamp) -- Ensures a user cannot have duplicate purchases at the same time
);

-- Insert sample data into Purchases table
-- These rows represent example purchases made by users
INSERT INTO Purchases (user_id, time_stamp, amount) VALUES
(1, '2022-04-20 09:03:00', 4416),  -- User 1 purchased $4416 on 2022-04-20
(2, '2022-03-19 19:24:02', 678),   -- User 2 purchased $678 on 2022-03-19
(3, '2022-03-18 12:03:09', 4523),  -- User 3 purchased $4523 on 2022-03-18
(3, '2022-03-30 09:43:42', 626);   -- User 3 purchased $626 on 2022-03-30

/*
================================================================================
Stored Procedure: GetUserIds
Parameters:
    @startDate DATE  - Start of the date range for eligible purchases
    @endDate   DATE  - End of the date range for eligible purchases
    @minAmount INT   - Minimum purchase amount to qualify for discount
================================================================================
*/
GO
CREATE OR ALTER PROCEDURE GetUserIds
(
    @startDate  DATE,
    @endDate    DATE,
    @minAmount  INT
)
AS
BEGIN
    -- Select distinct user IDs that satisfy the eligibility criteria
    SELECT DISTINCT user_id
    FROM Purchases
    WHERE time_stamp BETWEEN CAST(@startDate AS DATETIME) AND CAST(@endDate AS DATETIME)
      AND amount >= @minAmount
    ORDER BY user_id;  -- Optional: Return results ordered by user_id
END;
GO

/*
================================================================================
HOW TO EXECUTE:

Example: Find users with purchases >= $500 between 2022-03-01 and 2022-03-31

EXEC GetUserIds '2022-03-01', '2022-03-31', 500;

Expected Output:
+---------+
| user_id |
+---------+
|    2    |
|    3    |
+---------+
================================================================================
*/
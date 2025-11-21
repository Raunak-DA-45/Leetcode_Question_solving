/********************************************************************************************
Purpose of this Script
----------------------
This full T-SQL script demonstrates how to:
1. Create two tables: Signups and Confirmations.
2. Insert sample data representing user signups and confirmation message requests.
3. Find all users who requested a confirmation message **twice within a 24-hour window**.
   - Two messages exactly 24 hours apart are considered within the window.
   - The 'action' column is ignored; only the timestamp matters.

Business Rules Implemented
--------------------------
• Each user signs up once and has a unique user_id in Signups.
• Users can request confirmation messages multiple times; each request is logged in Confirmations.
• Only users with **at least two requests within 24 hours** are included in the output.
• The result returns **user_id only**, each user appears once.

How the Query Works Step-by-Step
--------------------------------
Method 1 (using LEAD):
1. For each user, order their confirmations by time_stamp.
2. Use LEAD() to get the **next confirmation timestamp**.
3. Compare the current and next timestamps; if the next timestamp is within 24 hours of the current, include the user.

Method 2 (using Self-Join):
1. Join the Confirmations table to itself on user_id.
2. For each pair of timestamps, keep only the pairs where the second timestamp is **after the first** and **within 24 hours**.
3. Use DISTINCT to return each user only once.

Both methods produce the same result and are fully compatible with SQL Server.
********************************************************************************************/


/*****************************
  DROP TABLES IF THEY EXIST
******************************/
IF OBJECT_ID('dbo.Confirmations', 'U') IS NOT NULL
    DROP TABLE dbo.Confirmations;

IF OBJECT_ID('dbo.Signups', 'U') IS NOT NULL
    DROP TABLE dbo.Signups;
GO


/*****************************
  CREATE TABLE: Signups
******************************/
CREATE TABLE dbo.Signups (
    user_id INT PRIMARY KEY,          -- Unique user ID
    time_stamp DATETIME NOT NULL      -- When the user signed up
);
GO


/*****************************
  CREATE TABLE: Confirmations
******************************/
-- SQL Server does not support ENUM, so we use a CHECK constraint for allowed actions.
CREATE TABLE dbo.Confirmations (
    user_id INT NOT NULL,             
    time_stamp DATETIME NOT NULL,     
    action VARCHAR(10) NOT NULL CHECK (action IN ('confirmed', 'timeout')),
    CONSTRAINT PK_Confirmations PRIMARY KEY (user_id, time_stamp),
    CONSTRAINT FK_Confirmations_Signups FOREIGN KEY (user_id)
        REFERENCES dbo.Signups(user_id)
);
GO


/*****************************
  INSERT SAMPLE DATA
******************************/
-- Signups: Each row represents a user and their signup time
INSERT INTO dbo.Signups (user_id, time_stamp) VALUES
(3, '2020-03-21 10:16:13'),
(7, '2020-01-04 13:57:59'),
(2, '2020-07-29 23:09:44'),
(6, '2020-12-09 10:39:37');
GO

-- Confirmations: Each row represents a confirmation request by a user
INSERT INTO dbo.Confirmations (user_id, time_stamp, action) VALUES
(3, '2021-01-06 03:30:46', 'timeout'),
(3, '2021-01-06 03:37:45', 'timeout'),
(7, '2021-06-12 11:57:29', 'confirmed'),
(7, '2021-06-13 11:57:30', 'confirmed'),
(2, '2021-01-22 00:00:00', 'confirmed'),
(2, '2021-01-23 00:00:00', 'timeout'),
(6, '2021-10-23 14:14:14', 'confirmed'),
(6, '2021-10-24 14:14:13', 'timeout');
GO


/*****************************
  CHECK SAMPLE DATA
******************************/
SELECT * FROM dbo.Signups;
SELECT * FROM dbo.Confirmations;


/*****************************
  METHOD 1: Using LEAD()
******************************/
SELECT DISTINCT user_id
FROM (
    SELECT
        user_id,
        time_stamp,
        LEAD(time_stamp) OVER(PARTITION BY user_id ORDER BY time_stamp) AS next_time
    FROM dbo.Confirmations
) AS t
WHERE next_time IS NOT NULL
  AND next_time <= DATEADD(HOUR, 24, time_stamp);  -- Only include next timestamp within 24 hours


/*****************************
  METHOD 2: Using Self-Join
******************************/
SELECT DISTINCT c1.user_id
FROM dbo.Confirmations c1
INNER JOIN dbo.Confirmations c2
    ON c1.user_id = c2.user_id
   AND c2.time_stamp > c1.time_stamp          -- Ensure we compare distinct timestamps
   AND c2.time_stamp <= DATEADD(HOUR, 24, c1.time_stamp);  -- Only within 24-hour window

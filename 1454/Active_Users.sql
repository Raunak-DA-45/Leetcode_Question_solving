/****************************************************************************************
Purpose:
--------
Identify "active users" — users who have logged in for **5 or more consecutive days**.

Business Rules:
---------------
1. A user is considered active if they have logged in on **at least 5 consecutive calendar days**.
2. Multiple logins on the same day count as **one day**.
3. Users must exist in the Accounts table.
4. Output should include:
   - User id
   - User name
5. Results must be ordered by user id.

How the Query Works (Step-by-Step):
----------------------------------
1. Create two tables:
   - Accounts: stores user information.
   - Logins: stores login activity by date.
2. Insert sample data to simulate real usage.
3. Join Accounts with Logins to associate users with their login dates.
4. Use a window function (RANK) to assign a sequence number to each login date per user.
5. Normalize dates using DATEADD to group consecutive login days together.
6. Count consecutive days per group.
7. Return users who have at least 5 consecutive login days.
****************************************************************************************/


/*==========================
  TABLE CLEANUP (SAFE RERUN)
==========================*/
IF OBJECT_ID('dbo.Logins', 'U') IS NOT NULL
    DROP TABLE dbo.Logins;

IF OBJECT_ID('dbo.Accounts', 'U') IS NOT NULL
    DROP TABLE dbo.Accounts;
GO


/*==========================
  TABLE: Accounts
  Stores user master data
==========================*/
CREATE TABLE dbo.Accounts (
    id INT NOT NULL,          -- Unique user identifier
    name VARCHAR(10) NOT NULL -- User's display name
);
GO


/*==========================
  TABLE: Logins
  Stores login activity
==========================*/
CREATE TABLE dbo.Logins (
    id INT NOT NULL,          -- References Accounts.id
    login_date DATE NOT NULL  -- Date when the user logged in
);
GO


/*==========================
  SAMPLE DATA: Accounts
==========================*/
INSERT INTO dbo.Accounts (id, name) VALUES
(1, 'Winston'),
(7, 'Jonathan');
GO


/*==========================
  SAMPLE DATA: Logins
  (Includes duplicate dates to show
   how consecutive logic is handled)
==========================*/
INSERT INTO dbo.Logins (id, login_date) VALUES
(7, '2020-05-30'),
(1, '2020-05-30'),
(7, '2020-05-31'),
(7, '2020-06-01'),
(7, '2020-06-02'),
(7, '2020-06-02'), -- duplicate login on same day
(7, '2020-06-03'),
(1, '2020-06-07'),
(7, '2020-06-10');
GO


/*==========================
  Solutions
==========================*/
WITH LoginSequence AS (
    SELECT
        a.id,
        a.name,
        l.login_date,
        -- Assigns an incremental number per user ordered by login date
        RANK() OVER (
            PARTITION BY a.id
            ORDER BY l.login_date
        ) AS seq
    FROM dbo.Accounts a
    JOIN dbo.Logins l
        ON a.id = l.id
)
SELECT
    id,
    name
FROM LoginSequence
GROUP BY
    id,
    name,
    -- Shifts dates by sequence number to identify consecutive groups
    DATEADD(DAY, -seq, login_date)
HAVING COUNT(*) >= 5 -- Enforces 5 or more consecutive days
ORDER BY id;

/****************************************************************************************************
PURPOSE OF THIS QUERY
-----------------------------------------------------------------------------------------------------
Calculate the daily **cancellation rate** for ride requests between 2013-10-01 and 2013-10-03.

We look only at trips where **both client AND driver are unbanned**, and compute:
    
        cancellation_rate = cancelled_trips / total_trips

Cancellation is defined as status IN ('cancelled_by_client', 'cancelled_by_driver').

-----------------------------------------------------------------------------------------------------
BUSINESS RULES APPLIED
-----------------------------------------------------------------------------------------------------
1. Only include trips where both the **client** and **driver** are NOT banned.
2. A trip counts as cancelled only when:
        • cancelled_by_client
        • cancelled_by_driver
3. Compute cancellation rate for each date (request_at).
4. Include only days that have at least one trip.
5. Return cancellation rate rounded to **two decimals**.

-----------------------------------------------------------------------------------------------------
HOW THE QUERY WORKS (STEP-BY-STEP)
-----------------------------------------------------------------------------------------------------
1. Create the Users and Trips tables (no foreign keys so truncation is safe).
2. Insert sample data provided in the problem.
3. Join Trips ? Users twice:
        • once to fetch client info
        • once to fetch driver info
4. Filter to ensure both are unbanned.
5. For each request date:
        • Count cancelled trips
        • Count total trips
6. Compute cancellation rate and round to 2 decimals.
7. Return one row per day.

****************************************************************************************************/


/*====================================================================================
    SCHEMA + SAMPLE DATA
    These make the script fully runnable for beginners.
====================================================================================*/

-- Drop old tables if they exist
IF OBJECT_ID('dbo.Trips', 'U') IS NOT NULL DROP TABLE dbo.Trips;
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;
GO

/*-----------------------------------------------------------------------------
 USERS TABLE
 - Represents all users in the system (both clients and drivers).
 - banned: 'Yes' or 'No' to indicate whether user is allowed to use the app.
 - role:   identifies whether the user is a client or driver.
-----------------------------------------------------------------------------*/
CREATE TABLE Users (
    users_id INT PRIMARY KEY,
    banned   VARCHAR(50),   -- whether user is banned
    role     VARCHAR(20)    -- 'client' or 'driver'
);
GO

/*-----------------------------------------------------------------------------
 TRIPS TABLE
 - Each row represents a trip request in the system.
 - status shows whether the trip was completed or cancelled.
 - request_at is the request date.
-----------------------------------------------------------------------------*/
CREATE TABLE Trips (
    id         INT PRIMARY KEY,
    client_id  INT,
    driver_id  INT,
    city_id    INT,
    status     VARCHAR(50),
    request_at VARCHAR(50)  -- stored as string for simplicity in this exercise
);
GO

-- Truncate to ensure clean reruns
TRUNCATE TABLE Users;
TRUNCATE TABLE Trips;
GO

-- Insert user data
INSERT INTO Users (users_id, banned, role) VALUES
(1, 'No', 'client'),
(2, 'Yes', 'client'),
(3, 'No', 'client'),
(4, 'No', 'client'),
(10, 'No', 'driver'),
(11, 'No', 'driver'),
(12, 'No', 'driver'),
(13, 'No', 'driver');
GO

-- Insert trips
INSERT INTO Trips (id, client_id, driver_id, city_id, status, request_at) VALUES
(1, 1, 10, 1, 'completed',              '2013-10-01'),
(2, 2, 11, 1, 'cancelled_by_driver',    '2013-10-01'),
(3, 3, 12, 6, 'completed',              '2013-10-01'),
(4, 4, 13, 6, 'cancelled_by_client',    '2013-10-01'),
(5, 1, 10, 1, 'completed',              '2013-10-02'),
(6, 2, 11, 6, 'completed',              '2013-10-02'),
(7, 3, 12, 6, 'completed',              '2013-10-02'),
(8, 2, 12, 12, 'completed',             '2013-10-03'),
(9, 3, 10, 12, 'completed',             '2013-10-03'),
(10, 4, 13, 12, 'cancelled_by_driver',  '2013-10-03');
GO



/*====================================================================================
    FINAL QUERY — DAILY CANCELLATION RATE
====================================================================================*/

SELECT
    t.request_at AS [Day],
    
    -- Cancellation rate = cancelled trips / total trips (rounded to 2 decimals)
    ROUND(
        CAST(
            SUM(CASE 
                    WHEN t.status IN ('cancelled_by_client','cancelled_by_driver')
                    THEN 1 ELSE 0 
                END) 
        AS FLOAT) 
        / COUNT(*)
    , 2) AS [Cancellation Rate]

FROM Trips t
    -- Join client
    INNER JOIN Users u_client 
        ON t.client_id = u_client.users_id
    -- Join driver
    INNER JOIN Users u_driver 
        ON t.driver_id = u_driver.users_id

WHERE 
    u_client.banned = 'No'   -- include only unbanned clients
    AND u_driver.banned = 'No'   -- include only unbanned drivers
    AND t.request_at BETWEEN '2013-10-01' AND '2013-10-03'

GROUP BY t.request_at;

/****************************************************************************************
PURPOSE
-------
This script analyzes trip data to identify the top-performing driver for each fuel type.
The “top driver” is defined as the driver who has driven the greatest total distance
for a given fuel type.

BUSINESS RULES
--------------
1. Each driver may own one vehicle.
2. Each vehicle can have multiple trips.
3. Drivers are evaluated separately for each fuel type.
4. Ranking rules per fuel type:
   a) Highest total distance traveled
   b) Lowest number of accidents (used as a tie-breaker)
5. Only the top-ranked driver per fuel type is returned.

HOW THE QUERY WORKS (STEP-BY-STEP)
----------------------------------
1. Create tables for drivers, vehicles, and trips.
2. Insert sample data to simulate real-world driving activity.
3. Join trips ? vehicles ? drivers to combine all relevant data.
4. Aggregate trip-level data to the driver + fuel type level.
5. Use DENSE_RANK() to rank drivers per fuel type.
6. Select only the top-ranked driver for each fuel type.
****************************************************************************************/


/****************************************************************************************
TABLE: Drivers
--------------
Stores personal and safety-related information about drivers.
****************************************************************************************/

CREATE TABLE Drivers (
    driver_id INT,           -- Unique identifier for each driver
    name VARCHAR(100),       -- Driver name
    age INT,                 -- Driver age
    experience INT,          -- Years of driving experience
    accidents INT            -- Total number of accidents
);


/****************************************************************************************
TABLE: Vehicles
---------------
Stores vehicle information and links each vehicle to a driver.
****************************************************************************************/

CREATE TABLE Vehicles (
    vehicle_id INT,          -- Unique identifier for each vehicle
    driver_id INT,           -- Driver who owns the vehicle
    model VARCHAR(100),      -- Vehicle model (e.g., Sedan, SUV)
    fuel_type VARCHAR(50),   -- Fuel type (Gasoline, Electric, etc.)
    mileage INT              -- Total mileage of the vehicle
);


/****************************************************************************************
TABLE: Trips
------------
Stores individual trip records for vehicles.
****************************************************************************************/

CREATE TABLE Trips (
    trip_id INT,             -- Unique identifier for each trip
    vehicle_id INT,          -- Vehicle used for the trip
    distance INT,            -- Distance traveled (e.g., km or miles)
    duration INT,            -- Duration of the trip (minutes)
    rating INT               -- Trip rating (1–5)
);


/****************************************************************************************
SAMPLE DATA
-----------
Represents a small fleet of drivers, vehicles, and trips.
****************************************************************************************/

TRUNCATE TABLE Drivers;

INSERT INTO Drivers VALUES (1, 'Alice',   34, 10, 1);
INSERT INTO Drivers VALUES (2, 'Bob',     45, 20, 3);
INSERT INTO Drivers VALUES (3, 'Charlie', 28,  5, 0);


TRUNCATE TABLE Vehicles;

INSERT INTO Vehicles VALUES (100, 1, 'Sedan', 'Gasoline', 20000);
INSERT INTO Vehicles VALUES (101, 2, 'SUV',   'Electric', 30000);
INSERT INTO Vehicles VALUES (102, 3, 'Coupe', 'Gasoline', 15000);


TRUNCATE TABLE Trips;

INSERT INTO Trips VALUES (201, 100,  50, 30, 5);
INSERT INTO Trips VALUES (202, 100,  30, 20, 4);
INSERT INTO Trips VALUES (203, 101, 100, 60, 4);
INSERT INTO Trips VALUES (204, 101,  80, 50, 5);
INSERT INTO Trips VALUES (205, 102,  40, 30, 5);
INSERT INTO Trips VALUES (206, 102,  60, 40, 5);


/****************************************************************************************
ANALYTICAL QUERY
----------------
Find the top driver per fuel type based on total distance traveled.
****************************************************************************************/

WITH DriverPerformance AS (
    SELECT
        v.fuel_type,
        d.driver_id,

        -- Total distance driven by the driver for this fuel type
        SUM(t.distance) AS total_distance,

        -- Average trip rating (cast to decimal for accuracy)
        AVG(t.rating * 1.0) AS avg_rating,

        -- Accidents are driver-level; AVG keeps grouping valid
        AVG(d.accidents) AS avg_accidents,

        -- Rank drivers within each fuel type
        DENSE_RANK() OVER (
            PARTITION BY v.fuel_type
            ORDER BY
                SUM(t.distance) DESC,
                AVG(d.accidents) ASC
        ) AS ranking

    FROM Trips t
    LEFT JOIN Vehicles v ON v.vehicle_id = t.vehicle_id
    LEFT JOIN Drivers d  ON d.driver_id  = v.driver_id
    GROUP BY
        v.fuel_type,
        d.driver_id
)

SELECT
    fuel_type,
    driver_id,
    avg_rating AS rating,
    total_distance AS distance
FROM DriverPerformance
WHERE ranking = 1;

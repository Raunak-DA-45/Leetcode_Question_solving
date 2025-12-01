/******************************************************************************************************
Purpose of this script
----------------------
This self-contained script demonstrates **how to calculate the average processing time per machine**
based on start/end activity records.

Business Rules Implemented
--------------------------
1. Each machine runs multiple processes.
2. Each process produces exactly two activity records:
      - A 'start' event with a timestamp.
      - An 'end' event with a timestamp occurring later.
3. Processing time for each process = end_timestamp ? start_timestamp.
4. Final output: **average processing time per machine**.
5. Two equivalent solutions are provided:
      - Method 1: Using window functions (LEAD).
      - Method 2: Using a self-join.

How the Query Works (Step-by-Step)
----------------------------------
1. Create and populate the `Activity` table with sample data.
2. Method 1:
     - Use LEAD() to access the timestamp of the "next" activity (the end event).
     - Calculate duration only where an end timestamp exists.
     - Group by machine to compute the average.
3. Method 2:
     - Self-join start and end activity rows for the same machine/process.
     - Compute durations and average them by machine.
******************************************************************************************************/


/******************************************************************************************************
SCHEMA + SAMPLE DATA
These tables and inserts are fully runnable. Every column has a comment for beginners.
******************************************************************************************************/

IF OBJECT_ID('dbo.Activity', 'U') IS NOT NULL
    DROP TABLE dbo.Activity;
GO

-- Table: Activity
-- Stores start and end timestamps for each process running on each machine.
CREATE TABLE Activity (
    machine_id INT,  -- ID of the machine (e.g., 0, 1, 2)
    process_id INT,  -- ID of the process running on that machine
    activity_type VARCHAR(5) CHECK (activity_type IN ('start', 'end')),  
        -- Indicates whether this row is the start or end of a process
    timestamp FLOAT  -- Wall-clock time when the activity occurred
);
GO

TRUNCATE TABLE Activity;
GO

-- Sample data: each process has exactly one 'start' and one 'end' row.
INSERT INTO Activity (machine_id, process_id, activity_type, timestamp) VALUES (0, 0, 'start', 0.712);
INSERT INTO Activity (machine_id, process_id, activity_type, timestamp) VALUES (0, 0, 'end', 1.52);
INSERT INTO Activity (machine_id, process_id, activity_type, timestamp) VALUES (0, 1, 'start', 3.14);
INSERT INTO Activity (machine_id, process_id, activity_type, timestamp) VALUES (0, 1, 'end', 4.12);

INSERT INTO Activity (machine_id, process_id, activity_type, timestamp) VALUES (1, 0, 'start', 0.55);
INSERT INTO Activity (machine_id, process_id, activity_type, timestamp) VALUES (1, 0, 'end', 1.55);
INSERT INTO Activity (machine_id, process_id, activity_type, timestamp) VALUES (1, 1, 'start', 0.43);
INSERT INTO Activity (machine_id, process_id, activity_type, timestamp) VALUES (1, 1, 'end', 1.42);

INSERT INTO Activity (machine_id, process_id, activity_type, timestamp) VALUES (2, 0, 'start', 4.1);
INSERT INTO Activity (machine_id, process_id, activity_type, timestamp) VALUES (2, 0, 'end', 4.512);
INSERT INTO Activity (machine_id, process_id, activity_type, timestamp) VALUES (2, 1, 'start', 2.5);
INSERT INTO Activity (machine_id, process_id, activity_type, timestamp) VALUES (2, 1, 'end', 5);
GO


------------------------------------------------------------------------------------------------------
-- View raw data
------------------------------------------------------------------------------------------------------
SELECT * FROM Activity;
GO


/******************************************************************************************************
METHOD 1 — Window Function (LEAD)
Uses LEAD to obtain the next timestamp (the 'end' time) for each start row.
******************************************************************************************************/

WITH cte1 AS (
    SELECT
        *,
        LEAD(timestamp) OVER (
            PARTITION BY machine_id, process_id 
            ORDER BY activity_type -- 'start' naturally comes before 'end'
        ) AS end_timestamp
    FROM Activity
)
SELECT
    machine_id,
    ROUND(AVG(end_timestamp - timestamp), 3) AS processing_time
FROM cte1
WHERE end_timestamp IS NOT NULL    -- keep only rows where an end event exists
GROUP BY machine_id;
GO


/******************************************************************************************************
METHOD 2 — Self Join (start joined with end)
Joins the start row with its matching end row for each machine/process.
******************************************************************************************************/

SELECT
    a1.machine_id,
    ROUND(AVG(a2.timestamp - a1.timestamp), 3) AS processing_time
FROM Activity a1
INNER JOIN Activity a2
    ON a1.machine_id = a2.machine_id 
   AND a1.process_id = a2.process_id
WHERE a1.activity_type = 'start' 
  AND a2.activity_type = 'end'
GROUP BY a1.machine_id;
GO
/***************************************************************************************************
PURPOSE:
    Find users whose FIRST session was as a 'Viewer' and then count how many
    'Streamer' sessions they had afterward.

BUSINESS RULES IMPLEMENTED:
    1. Each user can have multiple sessions.
    2. Sessions are ordered by session_start (and session_end for tie-breaking).
    3. Only users whose very first session_type = 'Viewer' qualify.
    4. For those qualified users, count only their 'Streamer' sessions.

HOW THE QUERY WORKS (STEP-BY-STEP):
    Step 1: Create the Sessions table to store session data.
    Step 2: Insert sample session records.
    Step 3: Use ROW_NUMBER() to determine the first session per user.
    Step 4: Identify users whose first session is 'Viewer'.
    Step 5: From those users, count how many 'Streamer' sessions they have.
***************************************************************************************************/


/***************************************************************************************************
SCHEMA CREATION
***************************************************************************************************/

-- Drop table if it already exists (so script can be rerun safely)
IF OBJECT_ID('dbo.Sessions', 'U') IS NOT NULL
    DROP TABLE dbo.Sessions;

-- Create Sessions table
CREATE TABLE Sessions (
    user_id INT,                     -- Unique identifier for each user
    session_start DATETIME,          -- When the session started
    session_end DATETIME,            -- When the session ended
    session_id INT,                  -- Unique session identifier
    session_type VARCHAR(20)         -- Type of session (Viewer or Streamer)
        CHECK (session_type IN ('Viewer','Streamer'))  -- Restrict allowed values
);


/***************************************************************************************************
SAMPLE DATA INSERTION
***************************************************************************************************/

-- User 101: First session is Viewer, then later Streamer sessions
INSERT INTO Sessions VALUES (101, '2023-11-06 13:53:42', '2023-11-06 14:05:42', 375, 'Viewer');
INSERT INTO Sessions VALUES (101, '2023-11-22 16:45:21', '2023-11-22 20:39:21', 594, 'Streamer');
INSERT INTO Sessions VALUES (101, '2023-11-20 07:16:06', '2023-11-20 08:33:06', 315, 'Streamer');

-- User 102: First session is Streamer (should NOT be included in final result)
INSERT INTO Sessions VALUES (102, '2023-11-16 13:23:09', '2023-11-16 16:10:09', 777, 'Streamer');
INSERT INTO Sessions VALUES (102, '2023-11-17 13:23:09', '2023-11-17 16:10:09', 778, 'Streamer');

-- User 104: Only one session and it is Viewer (no Streamer sessions ? not counted)
INSERT INTO Sessions VALUES (104, '2023-11-27 03:10:49', '2023-11-27 03:30:49', 797, 'Viewer');

-- User 103: First session is Streamer (should NOT be included)
INSERT INTO Sessions VALUES (103, '2023-11-27 03:10:49', '2023-11-27 03:30:49', 798, 'Streamer');


/***************************************************************************************************
MAIN QUERY
***************************************************************************************************/

WITH cte_ranked AS (
    SELECT
        user_id,
        session_type,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY session_start, session_end   -- Determines chronological order
        ) AS rn
    FROM Sessions
),
cte_filtered AS (
    SELECT *
    FROM cte_ranked
    WHERE user_id IN (
        -- Identify users whose FIRST session was 'Viewer'
        SELECT user_id
        FROM cte_ranked
        WHERE rn = 1 
          AND session_type = 'Viewer'
    )
    AND session_type = 'Streamer'   -- Count only Streamer sessions
)
SELECT
    user_id,
    COUNT(*) AS session_counts      -- Number of Streamer sessions
FROM cte_filtered
GROUP BY user_id;
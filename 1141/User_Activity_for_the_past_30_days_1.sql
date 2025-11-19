/* ==========================================================================================
   PURPOSE OF THIS SCRIPT
   ------------------------------------------------------------------------------------------
   This script calculates the **daily active user (DAU) count** for each day in the
   30-day period ending on **2019-07-27 (inclusive)**.

   HOW THE QUERY WORKS
   ------------------------------------------------------------------------------------------
   1. Define a date range from:
         2019-07-27 minus 29 days  ?  starting date of the 30-day period.
   2. Filter the Activity table to only include rows within this date window.
   3. Group by activity_date.
   4. Count DISTINCT user_id per day (ensuring a user counts only once per day).
   5. Return the result ordered by date (or any order, as permitted).

   The script below is fully self-contained, includes table creation, constraints,
   sample data, and the final query with clean comments.
============================================================================================== */



/* ==========================================================================================
   SCHEMA AND SAMPLE DATA
============================================================================================== */

----------------------------------------------------------
-- Drop Activity table if it already exists
----------------------------------------------------------
IF OBJECT_ID('dbo.Activity', 'U') IS NOT NULL
    DROP TABLE dbo.Activity;


----------------------------------------------------------
-- Activity table
-- Stores all actions taken by users inside their sessions.
-- user_id       : identifies the user performing the action
-- session_id    : identifies the session the action belongs to
-- activity_date : the calendar day the action occurred
-- activity_type : type of action (e.g., open_session, send_message)
----------------------------------------------------------
CREATE TABLE Activity (
    user_id INT,
    session_id INT,
    activity_date DATE,
    activity_type VARCHAR(20)
);


----------------------------------------------------------
-- Enforce allowed activity types using a CHECK constraint
----------------------------------------------------------
ALTER TABLE Activity
ADD CONSTRAINT chk_activity_type 
CHECK (activity_type IN ('open_session', 'end_session', 'scroll_down', 'send_message'));


----------------------------------------------------------
-- Sample data demonstrating session activity on different dates
-- Some users have multiple activities on the same day
-- ? but should count as active only once per day
----------------------------------------------------------
INSERT INTO Activity (user_id, session_id, activity_date, activity_type) VALUES
(1, 1, '2019-07-20', 'open_session'),
(1, 1, '2019-07-20', 'scroll_down'),
(1, 1, '2019-07-20', 'end_session'),

(2, 4, '2019-07-20', 'open_session'),
(2, 4, '2019-07-21', 'send_message'),
(2, 4, '2019-07-21', 'end_session'),

(3, 2, '2019-07-21', 'open_session'),
(3, 2, '2019-07-21', 'send_message'),
(3, 2, '2019-07-21', 'end_session'),

(4, 3, '2019-06-25', 'open_session'),
(4, 3, '2019-06-25', 'end_session');


----------------------------------------------------------
-- Optional: review the data
----------------------------------------------------------
-- SELECT * FROM Activity;


/* ==========================================================================================
   QUERY: Daily Active Users for the 30-day period ending 2019-07-27
============================================================================================== */

SELECT 
    activity_date AS day,
    COUNT(DISTINCT user_id) AS active_users     -- count each user once per day
FROM Activity
WHERE activity_date BETWEEN DATEADD(DAY, -29, '2019-07-27')  -- start of 30-day window
                        AND '2019-07-27'                     -- end of window
GROUP BY activity_date
HAVING COUNT(user_id) >= 1      -- ensures only days with at least one activity appear
ORDER BY activity_date;          -- optional (any order allowed)

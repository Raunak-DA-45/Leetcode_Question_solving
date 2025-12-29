/*===============================================================================
Purpose:
--------
Calculate the **average daily percentage of posts that were removed after being
reported as spam**, rounded to two decimal places.

Business Rules:
---------------
1. Only actions where:
   - action = 'report'
   - extra  = 'spam'
   are considered spam reports.
2. A post is considered "removed" if it appears in the Removals table.
3. The calculation is done in two stages:
   a) Per day:
      (Number of spam-reported posts that were removed ÷
       Total spam-reported posts that day)
   b) Across all days:
      Average of the daily percentages.
4. The final result is multiplied by 100 and rounded to two decimal places.

Step-by-Step Logic:
-------------------
1. Create tables to store user actions and post removals.
2. Insert sample data that includes spam reports and removals.
3. Filter Actions to only spam reports.
4. LEFT JOIN to Removals to identify which reported posts were removed.
5. Aggregate per day to compute daily ratios.
6. Average those daily ratios to get the final result.

===============================================================================*/


/*===============================================================================
TABLE: Actions
---------------
Stores all user interactions with posts.
===============================================================================*/
CREATE TABLE Actions (
    user_id     INT,          -- ID of the user performing the action
    post_id     INT,          -- ID of the post being acted upon
    action_date DATE,         -- Date of the action
    action      VARCHAR(20),  -- Type of action (view, report, like, etc.)
    extra       VARCHAR(10)   -- Additional info (e.g., report reason)
);


/*===============================================================================
TABLE: Removals
----------------
Stores posts that were removed by moderators.
===============================================================================*/
CREATE TABLE Removals (
    post_id     INT,          -- ID of the removed post
    remove_date DATE          -- Date the post was removed
);


/*===============================================================================
SAMPLE DATA: Actions
--------------------
Simulates user behavior including views, likes, and spam reports.
===============================================================================*/
TRUNCATE TABLE Actions;

INSERT INTO Actions VALUES
(1, 1, '2019-07-01', 'view',   'None'),
(1, 1, '2019-07-01', 'like',   'None'),
(1, 1, '2019-07-01', 'share',  'None'),

(2, 2, '2019-07-04', 'view',   'None'),
(2, 2, '2019-07-04', 'report', 'spam'),

(3, 4, '2019-07-04', 'view',   'None'),
(3, 4, '2019-07-04', 'report', 'spam'),

(4, 3, '2019-07-02', 'view',   'None'),
(4, 3, '2019-07-02', 'report', 'spam'),

(5, 2, '2019-07-03', 'view',   'None'),
(5, 2, '2019-07-03', 'report', 'racism'),

(5, 5, '2019-07-03', 'view',   'None'),
(5, 5, '2019-07-03', 'report', 'racism');


/*===============================================================================
SAMPLE DATA: Removals
---------------------
Indicates which posts were eventually removed.
===============================================================================*/
TRUNCATE TABLE Removals;

INSERT INTO Removals VALUES
(2, '2019-07-20'),
(3, '2019-07-18');


/*===============================================================================
QUERY: Average Daily Percentage of Spam-Reported Posts Removed
===============================================================================*/
WITH DailySpamCounts AS (
    SELECT
        a.action_date,

        -- Total number of spam reports on that day
        COUNT(a.post_id) AS total_post,

        -- Number of those spam-reported posts that were removed
        COUNT(r.remove_date) AS removed_post_count
    FROM Actions a
    LEFT JOIN Removals r
        ON a.post_id = r.post_id   -- Match reports to removals
    WHERE a.action = 'report'
      AND a.extra  = 'spam'        -- Only spam reports
    GROUP BY a.action_date
)

SELECT
    ROUND(
        AVG(removed_post_count * 1.0 / total_post) * 100,
        2
    ) AS average_daily_percent
FROM DailySpamCounts;

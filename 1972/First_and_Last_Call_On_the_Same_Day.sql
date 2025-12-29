/********************************************************************************************
Purpose:
---------
Identify users who had BOTH their first call and their last call of the same day
with the SAME person.

Business Rules:
---------------
1. Calls are directional (caller -> recipient), but for this problem,
   calls are treated as bidirectional (both users participated equally).
2. For each user and each calendar day:
   - Determine the first call of the day.
   - Determine the last call of the day.
3. If both the first and last call were with the same person,
   that user qualifies and should be returned.

How the Query Works (Step-by-Step):
----------------------------------
1. Create and populate a Calls table with sample call data.
2. Normalize the data so each call is represented from both users' perspectives
   (using UNION ALL).
3. For each user and day:
   - Use window functions to find the first and last call recipient.
4. Filter users where the first and last recipient are the same.
5. Return distinct qualifying user IDs.

********************************************************************************************/


/*===========================================================
  TABLE CREATION
===========================================================*/
IF OBJECT_ID('dbo.Calls', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Calls
    (
        caller_id INT,        -- ID of the user who initiated the call
        recipient_id INT,     -- ID of the user who received the call
        call_time DATETIME    -- Date and time when the call occurred
    );
END
ELSE
BEGIN
    TRUNCATE TABLE dbo.Calls; -- Clear existing data to keep script rerunnable
END;


/*===========================================================
  SAMPLE DATA INSERTION
  Each row represents one phone call
===========================================================*/
INSERT INTO dbo.Calls (caller_id, recipient_id, call_time) VALUES
(8,  4,  '2021-08-24 17:46:07'),
(4,  8,  '2021-08-24 19:57:13'),
(5,  1,  '2021-08-11 05:28:44'),
(8,  3,  '2021-08-17 04:04:15'),
(11, 3,  '2021-08-17 13:07:00'),
(8,  11, '2021-08-17 22:22:22');


/*===========================================================
  QUERY LOGIC
===========================================================*/
WITH cte1 AS
(
    -- Convert calls into a bidirectional format
    -- so both caller and recipient are treated as users
    SELECT
        caller_id   AS user_id,
        recipient_id AS other_user_id,
        call_time
    FROM dbo.Calls

    UNION ALL

    SELECT
        recipient_id AS user_id,
        caller_id    AS other_user_id,
        call_time
    FROM dbo.Calls
),
cte2 AS
(
    -- Identify the first and last call partner per user per day
    SELECT
        user_id,
        other_user_id,
        call_time,
        FIRST_VALUE(other_user_id) OVER
            (PARTITION BY user_id, CAST(call_time AS DATE)
             ORDER BY call_time) AS first_call_partner,
        FIRST_VALUE(other_user_id) OVER
            (PARTITION BY user_id, CAST(call_time AS DATE)
             ORDER BY call_time DESC) AS last_call_partner
    FROM cte1
)
SELECT DISTINCT
    user_id
FROM cte2
WHERE first_call_partner = last_call_partner;

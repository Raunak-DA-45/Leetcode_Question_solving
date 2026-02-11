/*****************************************************************************************
PURPOSE OF THE QUERY
--------------------
This query finds pairs of users who are directly friends BUT do NOT share 
any mutual friends.

In simple words:
Return friendships where the two users have no common friend.

------------------------------------------------------------------------------------------
BUSINESS RULES IMPLEMENTED
--------------------------
1. Friendships are stored in one direction only (user_id1 ? user_id2).
2. Friendship should be treated as bidirectional.
   If (1,2) exists, then (2,1) should also be considered.
3. A mutual friend exists if:
      User A is friends with User C
      AND
      User B is friends with the same User C
4. The final result should exclude friendships where at least one mutual friend exists.

------------------------------------------------------------------------------------------
HOW THE QUERY WORKS (STEP-BY-STEP)
-----------------------------------
Step 1: cte1
    - Converts the Friends table into a bidirectional relationship.
    - Uses UNION ALL to add reverse pairs.

Step 2: cte2
    - Checks for mutual friends.
    - For each friendship (A,B):
         Find all friends of A.
         Find all friends of B.
         If both share a common friend ? it is a mutual friend.
    - Returns only friendships that have at least one mutual friend.

Step 3: Final SELECT
    - Returns friendships from the original Friends table
      where NO mutual friend exists.
    - Uses NOT EXISTS to exclude friendships found in cte2.

*****************************************************************************************/


/*****************************************************************************************
TABLE SCHEMA
*****************************************************************************************/

-- This table stores direct friendships between two users.
-- user_id1: First user in the friendship
-- user_id2: Second user in the friendship
-- Each row represents that user_id1 is friends with user_id2.
CREATE TABLE Friends (
    user_id1 INT,
    user_id2 INT
);

-- Remove old data if the table already exists
TRUNCATE TABLE Friends;


/*****************************************************************************************
SAMPLE DATA
*****************************************************************************************/

-- User 1 is friends with User 2
INSERT INTO Friends (user_id1, user_id2) VALUES (1, 2);

-- User 2 is friends with User 3
INSERT INTO Friends (user_id1, user_id2) VALUES (2, 3);

-- User 2 is friends with User 4
INSERT INTO Friends (user_id1, user_id2) VALUES (2, 4);

-- User 1 is friends with User 5
INSERT INTO Friends (user_id1, user_id2) VALUES (1, 5);

-- User 6 is friends with User 7 (separate friend group)
INSERT INTO Friends (user_id1, user_id2) VALUES (6, 7);

-- User 3 is friends with User 4
INSERT INTO Friends (user_id1, user_id2) VALUES (3, 4);

-- User 2 is friends with User 5
INSERT INTO Friends (user_id1, user_id2) VALUES (2, 5);

-- User 8 is friends with User 9 (another isolated group)
INSERT INTO Friends (user_id1, user_id2) VALUES (8, 9);


/*****************************************************************************************
QUERY RESULTS
*****************************************************************************************/

WITH cte1 AS (
    -- Make friendships bidirectional
    SELECT * FROM Friends 
    UNION ALL
    SELECT user_id2, user_id1 FROM Friends
),
cte2 AS (
    SELECT
        t1.*,
        t2.user_id2 AS f1,
        t3.user_id2 AS f2
    FROM cte1 t1
    LEFT JOIN cte1 t2
        ON t1.user_id1 = t2.user_id1   -- Get all friends of user_id1
    LEFT JOIN cte1 t3
        ON t1.user_id2 = t3.user_id1   -- Get all friends of user_id2
    WHERE t2.user_id2 = t3.user_id2    -- Keep only common friends (mutual friends)
)

SELECT
    t1.user_id1,
    t1.user_id2
FROM Friends t1
WHERE NOT EXISTS (
    SELECT 1 
    FROM cte2 t2 
    WHERE t1.user_id1 = t2.user_id1 
      AND t2.user_id2 = t1.user_id2
);
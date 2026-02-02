/* ============================================================
   PURPOSE
   --------
   This query calculates the popularity percentage of each user
   based on how many friends they have compared to all users
   in the system.

   BUSINESS RULES
   --------------
   1. Friendship is bidirectional:
      - If (user1, user2) exists, then user2 is also a friend of user1.
   2. Each user’s popularity is determined by:
      - Number of friends they have
      - Divided by total number of users
      - Expressed as a percentage
   3. All users appearing in the Friends table are included.

   STEP-BY-STEP LOGIC
   ------------------
   1. Create and populate the Friends table with sample data.
   2. Use a CTE to make friendships bidirectional.
   3. Count how many friends each user has.
   4. Calculate popularity as a percentage of total users.
   ============================================================ */


/* ============================================================
   TABLE SCHEMA
   ============================================================ */

-- Friends table represents friendships between users.
-- Each row means: user1 is friends with user2.
CREATE TABLE Friends (
    user1 INT,  -- ID of the first user in the friendship
    user2 INT   -- ID of the second user in the friendship
);


/* ============================================================
   SAMPLE DATA
   ============================================================ */

-- Clear existing data to keep the script rerunnable
TRUNCATE TABLE Friends;

-- Insert sample friendship relationships
INSERT INTO Friends (user1, user2) VALUES (2, 1);
INSERT INTO Friends (user1, user2) VALUES (1, 3);
INSERT INTO Friends (user1, user2) VALUES (4, 1);
INSERT INTO Friends (user1, user2) VALUES (1, 5);
INSERT INTO Friends (user1, user2) VALUES (1, 6);
INSERT INTO Friends (user1, user2) VALUES (2, 6);
INSERT INTO Friends (user1, user2) VALUES (7, 2);
INSERT INTO Friends (user1, user2) VALUES (8, 3);
INSERT INTO Friends (user1, user2) VALUES (3, 9);

-- View raw friendship data
SELECT * FROM Friends;


/* ============================================================
   POPULARITY CALCULATION QUERY
   ============================================================ */

WITH cte_bidirectional_friends AS (
    -- Make friendships bidirectional so each user gets credit
    -- for both sides of the relationship
    SELECT user1, user2 FROM Friends
    UNION ALL
    SELECT user2, user1 FROM Friends
),
cte_friend_count AS (
    -- Count how many friends each user has
    SELECT
        user1,
        COUNT(user2) AS friend_count
    FROM cte_bidirectional_friends
    GROUP BY user1
)

-- Calculate popularity percentage for each user
SELECT
    user1,
    ROUND(
        CAST(friend_count AS FLOAT)
        / (SELECT COUNT(*) FROM cte_friend_count) * 100,
        2
    ) AS percentage_popularity
FROM cte_friend_count
ORDER BY user1;

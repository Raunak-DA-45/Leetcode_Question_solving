/*
==========================================================================================
Purpose:
------------------------------------------------------------------------------------------
This SQL script recommends pages to the user with user_id = 1 based on the pages that their 
friends liked. Recommendations do not include pages that the user has already liked.

Rules Implemented:
1. Identify all friends of user 1 (a friendship is bidirectional).
2. Recommend pages liked by friends.
3. Exclude pages already liked by user 1 to avoid duplicate recommendations.

How the Query Works (Step-by-Step):
1. Create two tables: Friendship and Likes.
2. Populate tables with sample data for demonstration purposes.
3. Use a CTE to extract all friends of user 1 from the Friendship table.
4. Select distinct pages liked by these friends, excluding pages user 1 already liked.
==========================================================================================
*/

------------------------------------------------------------
-- Drop tables if they already exist to avoid conflicts
------------------------------------------------------------
IF OBJECT_ID('dbo.Friendship', 'U') IS NOT NULL
    DROP TABLE dbo.Friendship;
GO

IF OBJECT_ID('dbo.Likes', 'U') IS NOT NULL
    DROP TABLE dbo.Likes;
GO

------------------------------------------------------------
-- Create Friendship table
-- Each row represents a friendship between user1_id and user2_id
-- Friendship is considered bidirectional (both users are friends with each other)
------------------------------------------------------------
CREATE TABLE dbo.Friendship (
    user1_id INT NOT NULL,               -- First user in the friendship
    user2_id INT NOT NULL,               -- Second user in the friendship
    CONSTRAINT PK_Friendship PRIMARY KEY (user1_id, user2_id)
);
GO

------------------------------------------------------------
-- Insert sample friendship data
------------------------------------------------------------
INSERT INTO dbo.Friendship (user1_id, user2_id) VALUES
(1, 2),
(1, 3),
(1, 4),
(2, 3),
(2, 4),
(2, 5),
(6, 1); -- Example of a friendship where user 6 is friends with user 1
GO

------------------------------------------------------------
-- Create Likes table
-- Each row represents that a user likes a page
------------------------------------------------------------
CREATE TABLE dbo.Likes (
    user_id INT NOT NULL,                -- ID of the user liking the page
    page_id INT NOT NULL,                -- ID of the page liked by the user
    CONSTRAINT PK_Likes PRIMARY KEY (user_id, page_id)
);
GO

------------------------------------------------------------
-- Insert sample Likes data
------------------------------------------------------------
INSERT INTO dbo.Likes (user_id, page_id) VALUES
(1, 88),  -- User 1 liked page 88
(2, 23),
(3, 24),
(4, 56),
(5, 11),
(6, 33),
(2, 77),
(3, 77),
(6, 88);
GO

------------------------------------------------------------
-- Optional: Check tables and data
------------------------------------------------------------
SELECT * FROM dbo.Friendship;
SELECT * FROM dbo.Likes;
GO

------------------------------------------------------------
-- Recommend pages to user_id = 1 based on friends' likes
------------------------------------------------------------
WITH FriendsCTE AS (
    -- Identify all friends of user 1
    SELECT 
        CASE 
            WHEN user1_id = 1 THEN user2_id
            WHEN user2_id = 1 THEN user1_id
        END AS friend_id
    FROM dbo.Friendship
    WHERE user1_id = 1 OR user2_id = 1
)
SELECT DISTINCT 
    l.page_id AS recommended_page
FROM dbo.Likes l
WHERE l.user_id IN (SELECT friend_id FROM FriendsCTE)   -- Only consider pages liked by friends
  AND l.page_id NOT IN (                                  -- Exclude pages user 1 already liked
      SELECT page_id 
      FROM dbo.Likes 
      WHERE user_id = 1
  );

/*
================================================================================
SQL Script: Find Topics of Each Post

Purpose:
This query identifies the topics of each social media post based on a predefined 
list of keywords associated with topics.

Business Rules Implemented:
1. Each post may contain zero or more keywords corresponding to one or more topics.
2. If a post contains no keywords for any topic, its topic is labeled 'Ambiguous!'.
3. If a post contains keywords for one or more topics:
   - The topic field should list the topic IDs in ascending order, separated by commas.
   - Each topic ID should appear only once (no duplicates).

How the Query Works Step-by-Step:
1. Two tables are used:
   - Keywords(topic_id, word): mapping of topic IDs to keywords.
   - Posts(post_id, content): social media posts with their content.
2. For each post:
   - Join it with keywords where the keyword appears in the post content (case-insensitive, whole-word match).
   - Use a subquery with DISTINCT to prevent duplicate topic matches.
   - Aggregate all matching topic IDs using STRING_AGG, ordered ascending, separated by commas.
3. If no keywords match for a post, ISNULL replaces NULL with 'Ambiguous!'.
================================================================================
*/

-- Drop tables if they already exist (cleanup)
IF OBJECT_ID('dbo.Keywords', 'U') IS NOT NULL DROP TABLE dbo.Keywords;
IF OBJECT_ID('dbo.Posts', 'U') IS NOT NULL DROP TABLE dbo.Posts;

--------------------------------------------------------------------------------
-- Table: Keywords
-- Purpose: Stores topic IDs and their associated keywords.
-- Columns:
--   topic_id INT       -> ID representing a topic.
--   word NVARCHAR(255) -> Keyword that expresses the topic.
-- Primary Key: (topic_id, word) ensures no duplicate keyword-topic pair.
--------------------------------------------------------------------------------
CREATE TABLE Keywords (
    topic_id INT NOT NULL,
    word NVARCHAR(255) NOT NULL,
    CONSTRAINT PK_Keywords PRIMARY KEY (topic_id, word)
);

--------------------------------------------------------------------------------
-- Table: Posts
-- Purpose: Stores posts with unique IDs and their textual content.
-- Columns:
--   post_id INT        -> Unique identifier for each post.
--   content NVARCHAR(MAX) -> Text content of the post.
-- Primary Key: post_id ensures uniqueness of each post.
--------------------------------------------------------------------------------
CREATE TABLE Posts (
    post_id INT NOT NULL PRIMARY KEY,
    content NVARCHAR(MAX) NOT NULL
);

--------------------------------------------------------------------------------
-- Sample data for Keywords table
-- Each row represents a topic and a keyword expressing that topic
--------------------------------------------------------------------------------
INSERT INTO Keywords (topic_id, word) VALUES
(1, N'handball'),
(1, N'football'),
(3, N'WAR'),
(2, N'Vaccine');

--------------------------------------------------------------------------------
-- Sample data for Posts table
-- Each row represents a post with a unique ID and its content
--------------------------------------------------------------------------------
INSERT INTO Posts (post_id, content) VALUES
(1, N'We call it soccer They call it football hahaha'),
(2, N'Americans prefer basketball while Europeans love handball and football'),
(3, N'stop the war and play handball'),
(4, N'warning I planted some flowers this morning and then got vaccinated');

--------------------------------------------------------------------------------
-- Query: Find the topics of each post
--------------------------------------------------------------------------------
SELECT 
    p.post_id,
    -- Aggregate matching topic IDs into a comma-separated string, sorted ascending.
    -- If no matching topic IDs, replace NULL with 'Ambiguous!'
    ISNULL(
        STRING_AGG(k.topic_id, ',') WITHIN GROUP (ORDER BY k.topic_id),
        'Ambiguous!'
    ) AS topic
FROM posts p
-- Join with keywords to find matches within the post content
LEFT JOIN (
    -- Select distinct topic-word pairs to avoid duplicate matches
    SELECT DISTINCT topic_id, word
    FROM keywords
) k
ON CONCAT(' ', LOWER(p.content), ' ') 
   LIKE CONCAT('% ', LOWER(k.word), ' %')  -- whole-word, case-insensitive match
GROUP BY p.post_id;  -- One row per post

/*
**********************************************************************************
----------------------------------------------------------------------------------
**********************************************************************************
Notes
1.CONCAT(' ', LOWER(p.content), ' ') LIKE CONCAT('% ', LOWER(k.word), ' %')
    -- Adds spaces to ensure whole-word matching (so "war" doesn’t match "warning").
    -- Converts both content and keyword to lowercase for case-insensitive comparison.
2.STRING_AGG(k.topic_id, ',') WITHIN GROUP (ORDER BY k.topic_id)
    --Combines multiple topic IDs into a single comma-separated string sorted ascending.
3.ISNULL(..., 'Ambiguous!')
     -- Replaces NULL for posts that match no keywords.*/
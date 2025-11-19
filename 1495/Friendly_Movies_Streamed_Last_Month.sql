/* ==========================================================================================
   PURPOSE OF THIS SCRIPT
   ------------------------------------------------------------------------------------------
   This script identifies **kid-friendly movies** that were **streamed during June 2020**
   and returns their **distinct titles**.

   HOW THE QUERY WORKS
   ------------------------------------------------------------------------------------------
   1. Create a CTE (cte1) that extracts all distinct content_id values from TVProgram
      that were streamed in June 2020.
   2. Join this list of IDs with the Content table.
   3. Filter to keep only kid-friendly movies.
   4. Select distinct movie titles.

   The script below includes:
   - Fully self-contained table creation
   - Sample data
   - Clear inline comments for beginners
============================================================================================== */



/* ==========================================================================================
   SCHEMA AND SAMPLE DATA
========================================================================================== */

----------------------------------------------------------
-- Drop existing tables so script can run multiple times
----------------------------------------------------------
IF OBJECT_ID('dbo.TVProgram', 'U') IS NOT NULL DROP TABLE dbo.TVProgram;
IF OBJECT_ID('dbo.Content', 'U') IS NOT NULL DROP TABLE dbo.Content;


----------------------------------------------------------
-- TVProgram table
-- Stores scheduled broadcasts of content.
-- program_date : Date & time content was streamed
-- content_id   : Links to Content table
-- channel      : TV channel name
----------------------------------------------------------
CREATE TABLE TVProgram (
    program_date DATETIME,
    content_id INT,
    channel VARCHAR(50),
    CONSTRAINT PK_TVProgram PRIMARY KEY (program_date, content_id)
);


----------------------------------------------------------
-- Sample TVProgram records
-- Includes several June 2020 entries, including kids movies.
----------------------------------------------------------
INSERT INTO TVProgram (program_date, content_id, channel) VALUES
('2020-06-10 08:00', 1, 'LC-Channel'),
('2020-05-11 12:00', 2, 'LC-Channel'),
('2020-05-12 12:00', 3, 'LC-Channel'),
('2020-05-13 14:00', 4, 'Disney Ch'),
('2020-06-18 14:00', 4, 'Disney Ch'),   -- June kid movie (Aladdin)
('2020-07-15 16:00', 5, 'Disney Ch');   -- Outside June


----------------------------------------------------------
-- Content table
-- Stores metadata about each show/movie.
-- Kids_content : 'Y' or 'N'
-- content_type : e.g., Movies, Series
----------------------------------------------------------
CREATE TABLE Content (
    content_id INT PRIMARY KEY,
    title VARCHAR(100),
    Kids_content CHAR(1) CHECK (Kids_content IN ('Y', 'N')),
    content_type VARCHAR(50)
);


----------------------------------------------------------
-- Sample Content records
-- Includes both kid content and non-kid content.
----------------------------------------------------------
INSERT INTO Content (content_id, title, Kids_content, content_type) VALUES
(1, 'Leetcode Movie',  'N', 'Movies'),
(2, 'Alg. for Kids',   'Y', 'Series'),
(3, 'Database Sols',   'N', 'Series'),
(4, 'Aladdin',         'Y', 'Movies'),    -- Kid-friendly movie
(5, 'Cinderella',      'Y', 'Movies');    -- Kid-friendly movie (but streamed in July)



----------------------------------------------------------
-- (Optional) View loaded data
----------------------------------------------------------
-- SELECT * FROM TVProgram;
-- SELECT * FROM Content;


/* ==========================================================================================
   QUERY: Kid-friendly movies streamed in June 2020
========================================================================================== */

WITH cte1 AS (
    SELECT DISTINCT content_id
    FROM TVProgram
    WHERE YEAR(program_date) = 2020
      AND MONTH(program_date) = 6    -- restrict to June
)
SELECT DISTINCT c.title
FROM Content c
INNER JOIN cte1 t
    ON c.content_id = t.content_id
WHERE c.Kids_content = 'Y'
  AND c.content_type = 'Movies';   -- ensures only movies are returned

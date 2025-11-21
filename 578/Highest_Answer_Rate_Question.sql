/********************************************************************************************
  FULL SCHEMA + SAMPLE DATA FOR "survey" TABLE
  LeetCode 578: Get Highest Answer Rate Question
  ------------------------------------------------------------------------------------------
  Purpose:
    - Identify the question(s) with the highest answer rate in a survey dataset.
  
  Business rules implemented:
    - answer_rate = number of 'answer' actions / number of 'show' actions per question.
    - Only the question(s) with the highest answer rate are returned.
    - If multiple questions tie, the one with the lowest question_id is returned (SQL Server TOP 1 behavior).

  How the query works step-by-step:
    1. Aggregate the survey table by question_id to calculate:
       - show_count: total number of 'show' actions per question.
       - answer_count: total number of 'answer' actions per question.
    2. Compute answer_rate for each question using decimal division.
    3. Order the questions by answer_rate descending and question_id ascending.
    4. Return the top 1 question as the one with the highest answer rate.
********************************************************************************************/

-- Drop table if it already exists
IF OBJECT_ID('dbo.survey', 'U') IS NOT NULL
    DROP TABLE dbo.survey;
GO

/*****************************
  CREATE TABLE: survey
******************************/
CREATE TABLE dbo.survey (
    id INT NOT NULL,             -- Unique identifier for the user or survey entry
    action VARCHAR(10) NOT NULL, -- Action type: 'show', 'answer', 'skip'
    question_id INT NOT NULL,    -- ID of the question
    answer_id INT NULL,          -- ID of the answer (nullable if skipped or shown only)
    q_num INT NOT NULL,          -- Sequence number of the question
    timestamp INT NOT NULL       -- Timestamp of the action
);
GO

/*****************************
  INSERT SAMPLE DATA
******************************/
INSERT INTO dbo.survey (id, action, question_id, answer_id, q_num, timestamp) VALUES
(5, 'show', 285, NULL, 1, 123),       -- Question 285 shown to user
(5, 'answer', 285, 124124, 1, 124),   -- User answered question 285
(5, 'show', 369, NULL, 2, 125),       -- Question 369 shown to user
(5, 'skip', 369, NULL, 2, 126);       -- User skipped question 369
GO

/*****************************
  CHECK TABLE CONTENT
******************************/
SELECT * FROM dbo.survey;
GO

/*****************************
  QUERY: Get Highest Answer Rate Question
******************************/
SELECT TOP 1 question_id AS survey_log
FROM (
    SELECT *,
           -- Compute answer_rate using decimal division to avoid integer truncation
           CAST(answer_count AS FLOAT) / show_count AS answer_rate
    FROM (
        -- Aggregate by question_id
        SELECT 
            question_id,
            SUM(CASE WHEN action = 'show' THEN 1 ELSE 0 END) AS show_count,
            SUM(CASE WHEN action = 'answer' THEN 1 ELSE 0 END) AS answer_count
        FROM dbo.survey
        GROUP BY question_id
    ) t
) t1
ORDER BY answer_rate DESC, question_id ASC;  -- Highest answer_rate first; tie-breaker: lowest question_id
GO

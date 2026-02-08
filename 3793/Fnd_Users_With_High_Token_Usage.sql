/* ============================================================
   PURPOSE
   ------------------------------------------------------------
   This query analyzes user prompt activity and returns users
   who:
   1) Have created at least 3 prompts
   2) Have at least one prompt where token usage is greater
      than their own average token usage

   BUSINESS RULES
   ------------------------------------------------------------
   - Each prompt belongs to a user (user_id)
   - Token usage represents the cost/size of a prompt
   - Only users with 3 or more prompts are considered
   - Only prompts with tokens greater than the user's average
     are used to qualify the user
   - Results are sorted by highest average token usage first

   HOW THE QUERY WORKS (STEP-BY-STEP)
   ------------------------------------------------------------
   1) Create a table to store prompt-level data
   2) Insert sample prompt records for multiple users
   3) Use a Common Table Expression (CTE) with window functions
      to calculate:
        - Total prompts per user
        - Average tokens per user
   4) Filter users based on business rules
   5) Return one row per qualifying user with summary metrics
   ============================================================ */


/* ============================================================
   TABLE SCHEMA
   ------------------------------------------------------------
   prompts:
   Stores individual prompt requests made by users
   ============================================================ */

CREATE TABLE prompts (
    user_id INT,           -- Unique identifier for each user
    prompt VARCHAR(255),    -- Description of the prompt requested
    tokens INT              -- Token usage for the prompt
);


/* ============================================================
   SAMPLE DATA
   ------------------------------------------------------------
   Clearing table first to avoid duplicate rows if re-run
   ============================================================ */

TRUNCATE TABLE prompts;


/* Sample prompt data for multiple users */
INSERT INTO prompts (user_id, prompt, tokens) 
VALUES ('1', 'Write a blog outline', '120');

INSERT INTO prompts (user_id, prompt, tokens) 
VALUES ('1', 'Generate SQL query', '80');

INSERT INTO prompts (user_id, prompt, tokens) 
VALUES ('1', 'Summarize an article', '200');

INSERT INTO prompts (user_id, prompt, tokens) 
VALUES ('2', 'Create resume bullet', '60');

INSERT INTO prompts (user_id, prompt, tokens) 
VALUES ('2', 'Improve LinkedIn bio', '70');

INSERT INTO prompts (user_id, prompt, tokens) 
VALUES ('3', 'Explain neural networks', '300');

INSERT INTO prompts (user_id, prompt, tokens) 
VALUES ('3', 'Generate interview Q&A', '250');

INSERT INTO prompts (user_id, prompt, tokens) 
VALUES ('3', 'Write cover letter', '180');

INSERT INTO prompts (user_id, prompt, tokens) 
VALUES ('3', 'Optimize Python code', '220');


/* Verify raw data */
SELECT * FROM prompts;


/* ============================================================
   QUERY SOLUTION(METHOD 1)
   ============================================================ */

WITH cte1 AS (
    SELECT
        *,
        COUNT(*) OVER (PARTITION BY user_id) AS total_no_of_prompts,
        AVG(tokens * 1.0) OVER (PARTITION BY user_id) AS avg_tokens
    FROM prompts
)

SELECT DISTINCT
    user_id,
    total_no_of_prompts AS prompt_count,
    ROUND(avg_tokens, 2) AS avg_tokens
FROM cte1
WHERE total_no_of_prompts >= 3
  AND tokens > avg_tokens   
ORDER BY 3 DESC, 1;
/* ============================================================
   QUERY SOLUTION(METHOD 2-- USING GROUP BY)
   ============================================================ */
with cte1 as(
select
    user_id,
    count(prompt) as prompt_count,
    round(avg(tokens*1.0),2) as avg_tokens
from prompts
group by user_id
having count(prompt)>=3)

select distinct
    t.*
from cte1 t
inner join prompts p
on t.user_id=p.user_id
where p.tokens > t.avg_tokens
order by t.avg_tokens desc,t.user_id
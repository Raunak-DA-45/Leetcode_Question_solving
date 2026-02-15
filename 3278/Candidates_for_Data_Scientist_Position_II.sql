/******************************************************************************************
Purpose:
--------
This query identifies the best candidate for each project based on how well their
skill proficiency matches the project's required skill importance.

Business Rules Implemented:
---------------------------
1. A candidate is evaluated only if they possess ALL skills required by the project.
2. Scoring logic per skill:
      - If candidate proficiency > project importance ? +10 points
      - If candidate proficiency < project importance ? -5 points
      - If equal ? 0 points
3. Every candidate starts with a base score of 100.
4. Total score = 100 + sum of skill-based adjustments.
5. The candidate with the highest total score per project is selected.
   - If tie ? candidate with smaller candidate_id wins (via DENSE_RANK ordering).

How the Query Works (Step-by-Step):
-----------------------------------
1. Create tables: Candidates and Projects.
2. Insert sample data.
3. CTE1:
   - Join Projects with Candidates by skill.
   - Calculate score adjustments.
   - Count how many required skills each candidate matched per project.
4. CTE2:
   - Keep only candidates who matched ALL required skills.
   - Rank candidates per project by total points (highest first).
5. Final SELECT:
   - Return top-ranked candidate(s) per project.
******************************************************************************************/

/******************************************************************************************
TABLE: Candidates
Stores each candidate's skill and proficiency level.

Columns:
- candidate_id : Unique ID of the candidate
- skill        : Skill name
- proficiency  : Skill level (1–5 scale, higher = stronger)
******************************************************************************************/
CREATE TABLE Candidates (
    candidate_id INT,
    skill VARCHAR(50),
    proficiency INT
);

/******************************************************************************************
TABLE: Projects
Stores required skills for each project and their importance level.

Columns:
- project_id : Unique ID of the project
- skill      : Required skill name
- importance : Required importance level (1–5 scale, higher = more critical)
******************************************************************************************/
CREATE TABLE Projects (
    project_id INT,
    skill VARCHAR(50),
    importance INT
);

/******************************************************************************************
Insert Sample Data into Candidates
Each row represents one skill of a candidate.
******************************************************************************************/
TRUNCATE TABLE Candidates;

INSERT INTO Candidates VALUES (101, 'Python', 5);
INSERT INTO Candidates VALUES (101, 'Tableau', 3);
INSERT INTO Candidates VALUES (101, 'PostgreSQL', 4);
INSERT INTO Candidates VALUES (101, 'TensorFlow', 2);

INSERT INTO Candidates VALUES (102, 'Python', 4);
INSERT INTO Candidates VALUES (102, 'Tableau', 5);
INSERT INTO Candidates VALUES (102, 'PostgreSQL', 4);
INSERT INTO Candidates VALUES (102, 'R', 4);

INSERT INTO Candidates VALUES (103, 'Python', 3);
INSERT INTO Candidates VALUES (103, 'Tableau', 5);
INSERT INTO Candidates VALUES (103, 'PostgreSQL', 5);
INSERT INTO Candidates VALUES (103, 'Spark', 4);

/******************************************************************************************
Insert Sample Data into Projects
Each row represents one required skill for a project.
******************************************************************************************/
TRUNCATE TABLE Projects;

INSERT INTO Projects VALUES (501, 'Python', 4);
INSERT INTO Projects VALUES (501, 'Tableau', 3);
INSERT INTO Projects VALUES (501, 'PostgreSQL', 5);

INSERT INTO Projects VALUES (502, 'Python', 3);
INSERT INTO Projects VALUES (502, 'Tableau', 4);
INSERT INTO Projects VALUES (502, 'R', 2);


/******************************************************************************************
Main Query
******************************************************************************************/

WITH cte1 AS (
    SELECT
        p.project_id,
        c.candidate_id,

        -- Base score (100) + skill-based adjustments
        100 + SUM(
            CASE
                WHEN c.proficiency > p.importance THEN 10
                WHEN c.proficiency < p.importance THEN -5
                ELSE 0
            END
        ) AS points,

        -- Count of matched skills per candidate per project
        COUNT(c.skill) AS skills_count

    FROM Projects p
    LEFT JOIN Candidates c
        ON p.skill = c.skill

    GROUP BY
        p.project_id,
        c.candidate_id
),

cte2 AS (
    SELECT
        t1.project_id,
        t1.candidate_id,
        t1.points,

        -- Rank candidates by highest score per project
        DENSE_RANK() OVER (
            PARTITION BY t1.project_id
            ORDER BY t1.points DESC, t1.candidate_id
        ) AS rnk

    FROM cte1 t1

    INNER JOIN (
        -- Count how many skills each project requires
        SELECT
            project_id,
            COUNT(skill) AS cnt
        FROM Projects
        GROUP BY project_id
    ) t
        ON t1.project_id = t.project_id
        AND t1.skills_count = t.cnt   -- Keep only candidates who matched ALL required skills
)

SELECT
    project_id,
    candidate_id,
    points
FROM cte2
WHERE rnk = 1
ORDER BY project_id;

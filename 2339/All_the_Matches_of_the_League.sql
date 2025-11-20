/************************************************************************************************
-- Purpose:
-- This query generates all possible matches of a football league given a list of teams.
-- Business Rules:
-- 1. Every two teams play two matches: once as home team, once as away team.
-- 2. No team plays against itself.
-- How it works step-by-step:
--   a. The Teams table lists all teams in the league.
--   b. Using a CROSS JOIN (or INNER JOIN with inequality), we create all possible pairs of teams.
--   c. The WHERE clause (t1.team_name <> t2.team_name) removes matches where a team would play itself.
--   d. The result shows every possible matchup, accounting for home and away games.
************************************************************************************************/

-- ================================
-- SCHEMA CREATION AND SAMPLE DATA
-- ================================

-- Drop the Teams table if it already exists to avoid errors when re-running the script
IF OBJECT_ID('dbo.Teams', 'U') IS NOT NULL
    DROP TABLE dbo.Teams;

-- Create the Teams table
CREATE TABLE dbo.Teams (
    team_name VARCHAR(100) PRIMARY KEY  -- Name of the team; primary key ensures uniqueness
);

-- Insert sample data into the Teams table
-- Each row represents a team in the league
INSERT INTO dbo.Teams (team_name) VALUES
('Leetcode FC'),   -- Team 1
('Ahly SC'),       -- Team 2
('Real Madrid');   -- Team 3

-- ================================
-- QUERY TO GENERATE ALL MATCHES
-- ================================

-- METHOD 1: Using CROSS JOIN
SELECT
    t1.team_name AS home_team,  -- Home team for the match
    t2.team_name AS away_team   -- Away team for the match
FROM dbo.Teams t1
CROSS JOIN dbo.Teams t2       -- Cartesian product: pairs each team with every other team
WHERE t1.team_name <> t2.team_name;  -- Exclude matches where a team plays itself

-- METHOD 2: Using INNER JOIN with inequality
SELECT
    t1.team_name AS home_team,
    t2.team_name AS away_team
FROM dbo.Teams t1
INNER JOIN dbo.Teams t2
    ON t1.team_name <> t2.team_name;  -- Join only different teams
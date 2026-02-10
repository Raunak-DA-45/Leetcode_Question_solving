/****************************************************************************************
PURPOSE
-------
This script stores football (soccer) season statistics for teams and calculates
their league standings per season based on standard league rules.

BUSINESS RULES
--------------
1. Each team plays a fixed number of matches per season.
2. Points are awarded as:
   - Win  = 3 points
   - Draw = 1 point
   - Loss = 0 points
3. League position is determined by:
   a) Total points (highest first)
   b) Goal difference (goals_for - goals_against)
   c) Team name (alphabetical order as a final tie-breaker)
4. Rankings reset for each season.

HOW THE QUERY WORKS (STEP-BY-STEP)
----------------------------------
1. Create a table to store season-level team statistics.
2. Insert sample data for two different seasons.
3. Calculate:
   - Total points per team
   - Goal difference per team
4. Rank teams within each season using DENSE_RANK().
5. Output the league table ordered by season, position, and team name.
****************************************************************************************/


/****************************************************************************************
TABLE: SeasonStats
------------------
Stores aggregated statistics for each team in a given season.
Each row represents ONE team in ONE season.
****************************************************************************************/

CREATE TABLE SeasonStats (
    season_id INT,            -- Season identifier (e.g., 2021, 2022)
    team_id INT,              -- Unique ID for the team
    team_name VARCHAR(255),   -- Human-readable team name
    matches_played INT,       -- Total matches played in the season
    wins INT,                 -- Matches won
    draws INT,                -- Matches drawn
    losses INT,               -- Matches lost
    goals_for INT,            -- Goals scored by the team
    goals_against INT         -- Goals conceded by the team
);


/****************************************************************************************
SAMPLE DATA
-----------
Premier League-style season summaries for two seasons.
****************************************************************************************/

TRUNCATE TABLE SeasonStats;

-- ===== Season 2021 =====
INSERT INTO SeasonStats VALUES (2021, 1, 'Manchester City', 38, 29, 6, 3, 99, 26);
INSERT INTO SeasonStats VALUES (2021, 2, 'Liverpool',        38, 28, 8, 2, 94, 26);
INSERT INTO SeasonStats VALUES (2021, 3, 'Chelsea',          38, 21, 11, 6, 76, 33);
INSERT INTO SeasonStats VALUES (2021, 4, 'Tottenham',        38, 22, 5, 11, 69, 40);
INSERT INTO SeasonStats VALUES (2021, 5, 'Arsenal',          38, 22, 3, 13, 61, 48);

-- ===== Season 2022 =====
INSERT INTO SeasonStats VALUES (2022, 1, 'Manchester City',  38, 28, 5, 5, 94, 33);
INSERT INTO SeasonStats VALUES (2022, 2, 'Arsenal',          38, 26, 6, 6, 88, 43);
INSERT INTO SeasonStats VALUES (2022, 3, 'Manchester United',38, 23, 6, 9, 58, 43);
INSERT INTO SeasonStats VALUES (2022, 4, 'Newcastle',        38, 19, 14, 5, 68, 33);
INSERT INTO SeasonStats VALUES (2022, 5, 'Liverpool',        38, 19, 10, 9, 75, 47);


/****************************************************************************************
LEAGUE TABLE QUERY
------------------
Calculates points, goal difference, and league position per season.
****************************************************************************************/

SELECT
    season_id,
    team_id,
    team_name,

    -- Points calculation based on league rules
    (wins * 3) + (draws * 1) AS points,

    -- Goal difference is a key tie-breaker
    goals_for - goals_against AS goal_difference,

    -- Rank teams within each season using official tie-breaking rules
    DENSE_RANK() OVER (
        PARTITION BY season_id
        ORDER BY
            (wins * 3) + (draws * 1) DESC,
            (goals_for - goals_against) DESC,
            team_name ASC
    ) AS position

FROM SeasonStats
ORDER BY
    season_id,
    position,
    team_name;

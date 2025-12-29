/*======================================================================================
PURPOSE
-------
Determine the winner in each player group based on total points scored across all matches.

BUSINESS RULES
--------------
1. Each player belongs to exactly one group.
2. Players earn points from matches:
   - If a player appears as first_player, they earn first_score.
   - If a player appears as second_player, they earn second_score.
3. Total points for a player = sum of all points from all their matches.
4. The winner of a group is:
   - The player with the highest total points in that group.
   - If there is a tie, the player with the lowest player_id wins.

HOW THE QUERY WORKS (STEP-BY-STEP)
----------------------------------
1. Create and populate Players and Matches tables with sample data.
2. Join Players with Matches to calculate total points per player.
3. Rank players within each group by total points (descending) and player_id (ascending).
4. Select the top-ranked (winner) player from each group.
======================================================================================*/


/*==========================
  TABLE: Players
  --------------------------
  player_id : Unique identifier for each player
  group_id  : Group to which the player belongs
==========================*/
IF OBJECT_ID('dbo.Players', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Players (
        player_id INT,
        group_id INT
    );
END;


/*==========================
  TABLE: Matches
  --------------------------
  match_id      : Unique match identifier
  first_player  : Player ID of the first player
  second_player : Player ID of the second player
  first_score   : Points scored by first_player
  second_score  : Points scored by second_player
==========================*/
IF OBJECT_ID('dbo.Matches', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Matches (
        match_id INT,
        first_player INT,
        second_player INT,
        first_score INT,
        second_score INT
    );
END;


/* Clear existing data so the script can be re-run safely */
TRUNCATE TABLE dbo.Players;
TRUNCATE TABLE dbo.Matches;


/* Sample data for Players */
INSERT INTO dbo.Players (player_id, group_id) VALUES
(10, 2),
(15, 1),
(20, 3),
(25, 1),
(30, 1),
(35, 2),
(40, 3),
(45, 1),
(50, 2);


/* Sample data for Matches */
INSERT INTO dbo.Matches (match_id, first_player, second_player, first_score, second_score) VALUES
(1, 15, 45, 3, 0),
(2, 30, 25, 1, 2),
(3, 30, 15, 2, 0),
(4, 40, 20, 5, 2),
(5, 35, 50, 1, 1);


/*==============================================================================
  QUERY: Find the winner in each group
==============================================================================*/
WITH PlayerPoints AS (
    SELECT
        p.player_id,
        p.group_id,
        -- Calculate total points earned by each player across all matches
        SUM(
            CASE
                WHEN p.player_id = m.first_player THEN m.first_score
                WHEN p.player_id = m.second_player THEN m.second_score
                ELSE 0
            END
        ) AS total_points
    FROM dbo.Players p
    LEFT JOIN dbo.Matches m
        -- Join condition covers both roles a player can have in a match
        ON p.player_id = m.first_player
        OR p.player_id = m.second_player
    GROUP BY
        p.player_id,
        p.group_id
),
RankedPlayers AS (
    SELECT
        player_id,
        group_id,
        total_points,
        -- Rank players within each group based on business rules
        DENSE_RANK() OVER (
            PARTITION BY group_id
            ORDER BY total_points DESC, player_id ASC
        ) AS ranking
    FROM PlayerPoints
)
SELECT
    group_id,
    player_id AS winner_player_id
FROM RankedPlayers
WHERE ranking = 1
ORDER BY group_id;

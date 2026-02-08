/* ============================================================
   PURPOSE
   ------------------------------------------------------------
   This query aggregates cities by state and counts how many 
   cities in each state start with the same letter as the state.
   It also lists those cities in alphabetical order for states
   with at least 3 cities.

   BUSINESS RULES
   ------------------------------------------------------------
   - For each state, check if the first letter of the state name
     matches the first letter of the city name.
   - List all cities in the state if the state has 3 or more cities
     and at least one city has the same starting letter as the state.
   - Display the cities in alphabetical order within each state.

   HOW THE QUERY WORKS (STEP-BY-STEP)
   ------------------------------------------------------------
   1) The `cities` table stores city and state pairs.
   2) A Common Table Expression (CTE) is used to create a column (`cnt`)
      that checks if the first letter of the state matches the first letter
      of the city.
   3) The main query groups cities by state and:
      - Aggregates the cities alphabetically.
      - Counts how many cities match the first letter of the state.
   4) The query only includes states with at least 3 cities and
      at least one city that matches the state’s first letter.
   5) Results are sorted by the number of matching cities (descending)
      and then by state name.
   ============================================================ */


/* ============================================================
   TABLE SCHEMA
   ------------------------------------------------------------
   cities:
   Stores a list of cities along with their respective state.
   ============================================================ */

CREATE TABLE cities (
    state VARCHAR(100),      -- State in which the city resides
    city VARCHAR(100)        -- Name of the city
);


/* ============================================================
   SAMPLE DATA
   ------------------------------------------------------------
   Inserting cities and states for testing the query.
   ============================================================ */

TRUNCATE TABLE cities;


/* Sample city and state data */
INSERT INTO cities (state, city) VALUES ('New York', 'New York City');
INSERT INTO cities (state, city) VALUES ('New York', 'Newark');
INSERT INTO cities (state, city) VALUES ('New York', 'Buffalo');
INSERT INTO cities (state, city) VALUES ('New York', 'Rochester');
INSERT INTO cities (state, city) VALUES ('California', 'San Francisco');
INSERT INTO cities (state, city) VALUES ('California', 'Sacramento');
INSERT INTO cities (state, city) VALUES ('California', 'San Diego');
INSERT INTO cities (state, city) VALUES ('California', 'Los Angeles');
INSERT INTO cities (state, city) VALUES ('Texas', 'Tyler');
INSERT INTO cities (state, city) VALUES ('Texas', 'Temple');
INSERT INTO cities (state, city) VALUES ('Texas', 'Taylor');
INSERT INTO cities (state, city) VALUES ('Texas', 'Dallas');
INSERT INTO cities (state, city) VALUES ('Pennsylvania', 'Philadelphia');
INSERT INTO cities (state, city) VALUES ('Pennsylvania', 'Pittsburgh');
INSERT INTO cities (state, city) VALUES ('Pennsylvania', 'Pottstown');


/* ============================================================
   QUERY(SOLUTION)
   ------------------------------------------------------------
   The query below counts cities in each state where the first
   letter of the state matches the first letter of at least one city.
   It also aggregates the cities alphabetically within each state.
   ============================================================ */

SELECT * FROM cities;

WITH cte1 AS (
    SELECT
        *,
        CASE WHEN LEFT(LOWER(state), 1) = LEFT(LOWER(city), 1) THEN 1 ELSE 0 END AS cnt
    FROM cities
)

SELECT
    state,
    STRING_AGG(city, ',') WITHIN GROUP (ORDER BY city) AS cities,
    SUM(CASE WHEN LEFT(state, 1) = LEFT(LOWER(city), 1) THEN 1 ELSE 0 END) AS matching_letter_count
FROM cte1
GROUP BY state
HAVING COUNT(city) >= 3
    AND SUM(CASE WHEN LEFT(state, 1) = LEFT(LOWER(city), 1) THEN 1 ELSE 0 END) > 0
ORDER BY 3 DESC, 1;


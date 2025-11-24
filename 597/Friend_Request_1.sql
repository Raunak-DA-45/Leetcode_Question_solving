/****************************************************************************************
-- Purpose:
--   Calculate the acceptance rate of friend requests in a social network.
--
-- Business Rules:
--   1. Each friend request is counted only once (distinct sender_id, send_to_id).
--   2. Each accepted request is counted only once (distinct requester_id, accepter_id).
--   3. Overall acceptance rate = total distinct accepted requests / total distinct requests.
--   4. Monthly acceptance rate = acceptance rate per month.
--   5. Cumulative daily acceptance rate = running sum of accepted requests divided by running sum of requests.
--
-- How the query works:
--   1. Create tables `friend_request` and `request_accepted` with sample data.
--   2. Use CTEs to calculate distinct counts of requests and acceptances.
--   3. Use window functions to compute cumulative sums for daily cumulative acceptance rate.
--   4. Use ROUND and ISNULL to handle formatting and missing data.
****************************************************************************************/

------------------------------------------------------------
-- DROP TABLES IF THEY ALREADY EXIST
------------------------------------------------------------
IF OBJECT_ID('dbo.friend_request', 'U') IS NOT NULL DROP TABLE dbo.friend_request;
IF OBJECT_ID('dbo.request_accepted', 'U') IS NOT NULL DROP TABLE dbo.request_accepted;
GO

------------------------------------------------------------
-- TABLE: friend_request
-- Stores all sent friend requests
------------------------------------------------------------
CREATE TABLE friend_request (
    sender_id    INT NOT NULL,     -- User who sent the request
    send_to_id   INT NOT NULL,     -- User receiving the request
    request_date DATE NOT NULL     -- Date request was sent
);
GO

------------------------------------------------------------
-- TABLE: request_accepted
-- Stores accepted friend requests
------------------------------------------------------------
CREATE TABLE request_accepted (
    requester_id INT NOT NULL,     -- User who originally sent the request
    accepter_id  INT NOT NULL,     -- User who accepted the request
    accept_date  DATE NOT NULL     -- Date request was accepted
);
GO

------------------------------------------------------------
-- INSERT SAMPLE DATA
------------------------------------------------------------
INSERT INTO friend_request (sender_id, send_to_id, request_date) VALUES
(1, 2, '2016-06-01'),
(1, 3, '2016-06-01'),
(1, 4, '2016-06-01'),
(2, 3, '2016-06-02'),
(3, 4, '2016-06-09');
GO

INSERT INTO request_accepted (requester_id, accepter_id, accept_date) VALUES
(1, 2, '2016-06-03'),
(1, 3, '2016-06-08'),
(2, 3, '2016-06-08'),
(3, 4, '2016-06-09'),
(3, 4, '2016-06-10');
GO

------------------------------------------------------------
-- QUERY 1: Overall Acceptance Rate
------------------------------------------------------------
WITH cte1 AS (
    SELECT DISTINCT sender_id, send_to_id
    FROM friend_request
),
cte2 AS (
    SELECT DISTINCT requester_id, accepter_id
    FROM request_accepted
)
SELECT 
    NULLIF(
        ROUND(
            COUNT(*) * 1.0 / (SELECT COUNT(*) FROM cte1),
            2
        ),
        0.00
    ) AS accept_rate
FROM cte2;
GO

------------------------------------------------------------
-- QUERY 2: Monthly Acceptance Rate
------------------------------------------------------------
WITH cte1 AS (
    SELECT DISTINCT sender_id, send_to_id, request_date
    FROM friend_request
),
cte2 AS (
    SELECT DISTINCT requester_id, accepter_id, accept_date
    FROM request_accepted
),
cte3 AS (
    SELECT FORMAT(request_date,'yyyy-MM') AS month,
           COUNT(*) AS request_count
    FROM cte1
    GROUP BY FORMAT(request_date,'yyyy-MM')
),
cte4 AS (
    SELECT FORMAT(accept_date,'yyyy-MM') AS month,
           COUNT(*) AS accepted_count
    FROM cte2
    GROUP BY FORMAT(accept_date,'yyyy-MM')
)
SELECT 
    t1.month,
    ISNULL(
        ROUND(t2.accepted_count * 1.0 / t1.request_count, 2),
        0
    ) AS accept_rate
FROM cte3 t1
LEFT JOIN cte4 t2
    ON t1.month = t2.month
ORDER BY t1.month;
GO

------------------------------------------------------------
-- QUERY 3: Cumulative Daily Acceptance Rate
------------------------------------------------------------
WITH cte1 AS (
    SELECT request_date,
           COUNT(*) AS total_count
    FROM (SELECT DISTINCT sender_id, send_to_id, request_date FROM friend_request) t
    GROUP BY request_date
),
cte2 AS (
    SELECT accept_date,
           COUNT(*) AS accepted
    FROM (SELECT DISTINCT requester_id, accepter_id, accept_date FROM request_accepted) t
    GROUP BY accept_date
),
cte3 AS (
    SELECT request_date AS date FROM cte1
    UNION
    SELECT accept_date AS date FROM cte2
),
cte4 AS (
    SELECT
        t1.date,
        ISNULL(t2.accepted,0) AS accept_count,
        ISNULL(t3.total_count,0) AS request_count
    FROM cte3 t1
    LEFT JOIN cte2 t2
        ON t1.date = t2.accept_date
    LEFT JOIN cte1 t3
        ON t1.date = t3.request_date
)
SELECT 
    date,
    accept_count,
    request_count,
    ROUND(
        SUM(accept_count) OVER(ORDER BY date) * 1.0
        / NULLIF(SUM(request_count) OVER(ORDER BY date),0),
        2
    ) AS cumulative_accept_rate
FROM cte4
ORDER BY date;
GO

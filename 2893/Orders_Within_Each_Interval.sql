/******************************************************************************************
Purpose:
    Aggregate order counts into 6-minute intervals and calculate total orders per interval.

Business Rules:
    1. Each row represents number of orders placed in a specific minute.
    2. Minutes 1–6 belong to interval 1.
    3. Minutes 7–12 belong to interval 2.
    4. Orders are summed per interval to get total orders.

How the query works (step-by-step):
    1. Create an Orders table storing minute-wise order counts.
    2. Insert sample data representing order volume per minute.
    3. Use a CTE (Common Table Expression) to assign each minute to a 6-minute interval.
    4. Group data by interval and sum order counts.
    5. A second approach dynamically calculates intervals using CEILING().
******************************************************************************************/

/******************************************************************************************
SCHEMA CREATION
The Orders table stores order counts per minute.

Columns:
    minute       -> Minute number in sequence (e.g., minute 1, 2, 3...).
    order_count  -> Number of orders placed during that minute.
******************************************************************************************/
CREATE TABLE Orders (
    minute INT,
    order_count INT
);

-- Remove existing data so script can be rerun safely
TRUNCATE TABLE Orders;

/******************************************************************************************
SAMPLE DATA
Each row represents number of orders recorded in a given minute.
******************************************************************************************/
INSERT INTO Orders (minute, order_count) VALUES ('1', '0');   -- No orders at minute 1
INSERT INTO Orders (minute, order_count) VALUES ('2', '2');
INSERT INTO Orders (minute, order_count) VALUES ('3', '4');
INSERT INTO Orders (minute, order_count) VALUES ('4', '6');
INSERT INTO Orders (minute, order_count) VALUES ('5', '1');
INSERT INTO Orders (minute, order_count) VALUES ('6', '4');   -- End of interval 1
INSERT INTO Orders (minute, order_count) VALUES ('7', '1');
INSERT INTO Orders (minute, order_count) VALUES ('8', '2');
INSERT INTO Orders (minute, order_count) VALUES ('9', '4');
INSERT INTO Orders (minute, order_count) VALUES ('10', '1');
INSERT INTO Orders (minute, order_count) VALUES ('11', '4');
INSERT INTO Orders (minute, order_count) VALUES ('12', '6');  -- End of interval 2

-- Verify inserted data
SELECT * FROM Orders;

--------------------------------------------------------------------------------------------
-- METHOD 1: Using CASE to manually define intervals
--------------------------------------------------------------------------------------------
WITH cte1 AS (
    SELECT
        *,
        CASE 
            WHEN minute BETWEEN 1 AND 6 THEN '1'
            WHEN minute BETWEEN 7 AND 12 THEN '2'
        END AS interval
    FROM Orders
)

SELECT
    interval AS interval_no,
    SUM(order_count) AS total_orders
FROM cte1
GROUP BY interval
ORDER BY 1;

--------------------------------------------------------------------------------------------
-- METHOD 2: Dynamically calculate intervals using CEILING
--------------------------------------------------------------------------------------------
WITH cte1 AS (
    SELECT
        *,
        CEILING(CAST(minute AS FLOAT) / 6) AS interval_no
    FROM Orders
)

SELECT
    interval_no,
    SUM(order_count) AS total_orders
FROM cte1
GROUP BY interval_no
ORDER BY 1;

/* 
===============================================================================
PURPOSE:
--------
This query rearranges product names within each category based on a 
custom business-defined order of ProductID.

Instead of sorting normally (ASC/DESC), we:
1. Assign a custom rank (rnk) using CASE logic.
2. Reverse that ranking using another ROW_NUMBER().
3. Join the two rankings to "re-map" product names.

-------------------------------------------------------------------------------
BUSINESS RULES:
---------------
- Each category (Electronics, Accessories) has its own custom order.
- The order is NOT based on ProductID sorting, but predefined business logic.
- Final output keeps ProductID from one order and Product name from reversed order.

-------------------------------------------------------------------------------
HOW IT WORKS (STEP-BY-STEP):
---------------------------
1. Create base table and insert sample data.
2. CTE1:
   - Assigns a custom rank (rnk) per category using CASE.
3. CTE2:
   - Reverses that rank using ROW_NUMBER() over rnk DESC.
4. Final Join:
   - Match original rank (rnk) with reversed rank (rnk2)
   - This swaps product names within each category.
===============================================================================
*/


-- ============================================================================
-- STEP 1: CREATE TABLE
-- ============================================================================

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,       -- Unique identifier for each product
    Product VARCHAR(50),             -- Product name
    Category VARCHAR(50)             -- Category grouping (Electronics / Accessories)
);

-- ============================================================================
-- STEP 2: INSERT SAMPLE DATA
-- ============================================================================

INSERT INTO Products (ProductID, Product, Category) VALUES
-- Electronics category products
(101, 'Gaming Laptop', 'Electronics'),
(102, 'iPhone', 'Electronics'),
(108, 'iPad', 'Electronics'),
(104, 'Scanner', 'Electronics'),

-- Accessories category products
(105, 'Bluetooth Earbuds', 'Accessories'),
(106, 'Fitness Band', 'Accessories'),
(107, 'Mechanical Keyboard', 'Accessories'),
(103, 'Wireless Mouse', 'Accessories'),
(109, 'LED Monitor', 'Accessories');

-- View base data
SELECT * FROM Products;


-- ============================================================================
-- STEP 3: APPLY CUSTOM ORDER + REVERSAL LOGIC
-- ============================================================================

WITH cte1 AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY category 
            ORDER BY 
                CASE
                    -- Custom order for Electronics
                    WHEN productid = 104 AND category='Electronics' THEN 1
                    WHEN productid = 108 AND category='Electronics' THEN 2
                    WHEN productid = 102 AND category='Electronics' THEN 3
                    WHEN productid = 101 AND category='Electronics' THEN 4

                    -- Custom order for Accessories
                    WHEN productid = 109 AND category='Accessories' THEN 1
                    WHEN productid = 103 AND category='Accessories' THEN 2
                    WHEN productid = 107 AND category='Accessories' THEN 3
                    WHEN productid = 106 AND category='Accessories' THEN 4
                    WHEN productid = 105 AND category='Accessories' THEN 5
                END
        ) AS rnk   -- Assign custom rank per category
    FROM products
),

cte2 AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY category 
            ORDER BY rnk DESC   -- Reverse the ranking
        ) AS rnk2
    FROM cte1
)

-- ============================================================================
-- STEP 4: FINAL OUTPUT
-- ============================================================================

SELECT
    t1.productid,     -- Keep original ProductID
    t2.product,       -- Swap product name using reversed rank
    t1.category
FROM cte1 t1
INNER JOIN cte2 t2
    ON t1.category = t2.category
   AND t1.rnk = t2.rnk2   -- Match forward rank with reverse rank
ORDER BY t1.category, t1.rnk;
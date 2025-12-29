/****************************************************************************************
PURPOSE
-------
For each user (seller), determine whether the **2nd item they sold**
matches their **favorite brand**.

OUTPUT
------
One row per user:
- user_id
- 2nd_item_fav_brand ? 'Yes' or 'No'

BUSINESS RULES
--------------
1. Only selling activity (seller_id) is considered.
2. Orders are ordered by order_date (earliest first).
3. If a seller has fewer than 2 sold items ? result = 'No'.
4. If the 2nd sold item’s brand equals the user's favorite brand ? 'Yes'.
5. Otherwise ? 'No'.
6. All users must appear in the final result.

========================================================================================
SCHEMA & SAMPLE DATA
========================================================================================
*/

/* =========================
   USERS TABLE
========================= */
IF OBJECT_ID('dbo.Users', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Users (
        user_id INT,               -- Unique user identifier
        join_date DATE,             -- Date user joined platform
        favorite_brand VARCHAR(10)  -- User's preferred brand
    )
END
GO

TRUNCATE TABLE dbo.Users
GO

INSERT INTO dbo.Users VALUES
(1, '2019-01-01', 'Lenovo'),
(2, '2019-02-09', 'Samsung'),
(3, '2019-01-19', 'LG'),
(4, '2019-05-21', 'HP')
GO


/* =========================
   ORDERS TABLE
========================= */
IF OBJECT_ID('dbo.Orders', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Orders (
        order_id INT,       -- Order identifier
        order_date DATE,    -- Date of order
        item_id INT,        -- Item sold
        buyer_id INT,       -- Buyer user
        seller_id INT       -- Seller user
    )
END
GO

TRUNCATE TABLE dbo.Orders
GO

INSERT INTO dbo.Orders VALUES
(1, '2019-08-01', 4, 1, 2),
(2, '2019-08-02', 2, 1, 3),
(3, '2019-08-03', 3, 2, 3),
(4, '2019-08-04', 1, 4, 2),
(5, '2019-08-04', 1, 3, 4),
(6, '2019-08-05', 2, 2, 4)
GO


/* =========================
   ITEMS TABLE
========================= */
IF OBJECT_ID('dbo.Items', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Items (
        item_id INT,           -- Item identifier
        item_brand VARCHAR(10) -- Brand name
    )
END
GO

TRUNCATE TABLE dbo.Items
GO

INSERT INTO dbo.Items VALUES
(1, 'Samsung'),
(2, 'Lenovo'),
(3, 'LG'),
(4, 'HP')
GO


/****************************************************************************************
METHOD 1
--------
Uses LEAD() window function to directly fetch the second sold item’s brand.

LOGIC
-----
1. Join Users ? Orders ? Items.
2. Partition by seller and order by order_date.
3. LEAD() fetches the next item brand (2nd sale).
4. Compare with favorite_brand.
****************************************************************************************/

WITH cte1 AS (
    SELECT
        u.user_id,
        u.favorite_brand,
        o.order_date,
        i.item_brand,
        COUNT(o.seller_id) OVER (PARTITION BY u.user_id) AS cnt,
        LEAD(i.item_brand) OVER (
            PARTITION BY u.user_id
            ORDER BY o.order_date
        ) AS second_order
    FROM Users u
    LEFT JOIN Orders o
        ON u.user_id = o.seller_id
    LEFT JOIN Items i
        ON o.item_id = i.item_id
),
cte2 AS (
    SELECT
        user_id,
        CASE
            WHEN cnt >= 2
                 AND second_order = favorite_brand
            THEN 'Yes'
            ELSE 'No'
        END AS [2nd_item_fav_brand]
    FROM cte1
    WHERE second_order IS NOT NULL
)
SELECT
    u.user_id,
    ISNULL(t.[2nd_item_fav_brand], 'No') AS [2nd_item_fav_brand]
FROM Users u
LEFT JOIN cte2 t
    ON u.user_id = t.user_id
ORDER BY u.user_id;



/****************************************************************************************
METHOD 2
--------
Uses ROW_NUMBER() to explicitly identify the 2nd sold item.

LOGIC
-----
1. Join Users ? Orders ? Items.
2. Assign sequence number to each sale per seller.
3. Count total sales per seller.
4. Evaluate only the row where rank = 2.
****************************************************************************************/

WITH cte1 AS (
    SELECT
        u.user_id,
        u.favorite_brand,
        o.order_date,
        i.item_brand,
        ROW_NUMBER() OVER (
            PARTITION BY u.user_id
            ORDER BY o.order_date
        ) AS rnk,
        COUNT(*) OVER (
            PARTITION BY u.user_id
        ) AS cnting
    FROM Users u
    LEFT JOIN Orders o
        ON u.user_id = o.seller_id
    LEFT JOIN Items i
        ON o.item_id = i.item_id
),
cte2 AS (
    SELECT
        user_id,
        CASE
            WHEN cnting < 2 THEN 'No'
            WHEN rnk = 2 AND item_brand = favorite_brand THEN 'Yes'
            ELSE 'No'
        END AS [2nd_item_fav_brand]
    FROM cte1
    WHERE rnk = 2 OR cnting < 2
)
SELECT *
FROM cte2
ORDER BY user_id;
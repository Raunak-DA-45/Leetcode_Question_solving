/****************************************************************************************************
Purpose:
    Pivot product prices so that each row represents one product
    and each store’s price appears in its own column (store1, store2, store3).

Business Rules Implemented:
    - Stores are only: 'store1', 'store2', 'store3'.
    - If a product does not exist in a store, the result should show NULL for that store.
    - The output should contain one row per product.

How the Query Works (Step-by-Step):
    1. The Products table lists product-store-price combinations in a vertical format.
    2. The final SELECT uses conditional aggregation:
         • For each product_id, it checks each store.
         • CASE expressions filter rows by store.
         • MAX() is used to transform the filtered values into columns (pivot effect).
    3. GROUP BY product_id ensures one output row per product.

****************************************************************************************************/

----------------------------------------------------------------------------------------------------
-- TABLE SCHEMA: Products
-- Purpose: Stores the price of each product in each store.
-- Columns:
--   product_id INT        -> Unique ID of the product.
--   store NVARCHAR(10)    -> Store name ('store1', 'store2', 'store3').
--   price INT             -> Price of the product in that store.
-- Primary Key: (product_id, store) to prevent duplicate entries.
----------------------------------------------------------------------------------------------------
IF OBJECT_ID('dbo.Products', 'U') IS NOT NULL 
    DROP TABLE dbo.Products;

CREATE TABLE Products (
    product_id INT NOT NULL,
    store NVARCHAR(10) NOT NULL,
    price INT NOT NULL,
    CONSTRAINT PK_Products PRIMARY KEY (product_id, store)
);

----------------------------------------------------------------------------------------------------
-- SAMPLE DATA
-- These rows simulate various price listings for two products across three stores.
-- Some products may not be listed in every store.
----------------------------------------------------------------------------------------------------
INSERT INTO Products (product_id, store, price) VALUES
(0, 'store1', 95),
(0, 'store3', 105),
(0, 'store2', 100),
(1, 'store1', 70),
(1, 'store3', 80);

----------------------------------------------------------------------------------------------------
-- QUERY: Pivot product prices so each store becomes a separate column.
----------------------------------------------------------------------------------------------------
SELECT 
    product_id,
    -- Store-specific columns created via conditional aggregation
    MAX(CASE WHEN store = 'store1' THEN price END) AS store1,
    MAX(CASE WHEN store = 'store2' THEN price END) AS store2,
    MAX(CASE WHEN store = 'store3' THEN price END) AS store3
FROM Products
GROUP BY product_id;   -- Ensures one row per product
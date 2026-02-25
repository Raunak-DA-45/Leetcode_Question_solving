/********************************************************************************************
Purpose:
    Retrieve products whose name contains EXACTLY three consecutive digits.

Business Rules Implemented:
    1. Product name must contain at least one sequence of 3 consecutive digits.
    2. Product name must NOT contain 4 or more consecutive digits.
    3. Digits can appear anywhere in the product name.

How the Query Works:
    Step 1: Create Products table.
    Step 2: Insert sample test data.
    Step 3: Method 1 uses REGEXP_LIKE to filter valid rows.
    Step 4: Method 2 uses LIKE pattern matching (SQL Server style).
********************************************************************************************/

---------------------------------------
-- 1?? TABLE SCHEMA
---------------------------------------

DROP TABLE IF EXISTS products;

CREATE TABLE products (
    product_id INT,           -- Unique product identifier
    name VARCHAR(255)         -- Product name (may contain letters and numbers)
);

---------------------------------------
-- 2?? SAMPLE DATA
---------------------------------------

INSERT INTO products (product_id, name) VALUES (1, 'ABC123XYZ');          
INSERT INTO products (product_id, name) VALUES (2, 'A12B34C');            
INSERT INTO products (product_id, name) VALUES (3, 'Product56789');       
INSERT INTO products (product_id, name) VALUES (4, 'NoDigitsHere');       
INSERT INTO products (product_id, name) VALUES (5, '789Product');         
INSERT INTO products (product_id, name) VALUES (6, 'Item003Description'); 
INSERT INTO products (product_id, name) VALUES (7, 'Product12X34');       

---------------------------------------
-- 3?? METHOD 1 : Using REGEXP_LIKE
---------------------------------------

SELECT *
FROM products
WHERE REGEXP_LIKE(name, '[0-9]{3}')      -- At least 3 consecutive digits
  AND NOT REGEXP_LIKE(name, '[0-9]{4,}') -- Exclude 4+ consecutive digits
ORDER BY product_id;

---------------------------------------
-- ? OUTPUT OF METHOD 1
---------------------------------------
-- product_id | name
-- -----------|----------------------
-- 1          | ABC123XYZ
-- 5          | 789Product
-- 6          | Item003Description



---------------------------------------
-- 4?? METHOD 2 : Using LIKE (SQL Server Pattern)
---------------------------------------

SELECT *
FROM products
WHERE name LIKE '%[0-9][0-9][0-9]%'      -- Contains 3 consecutive digits
  AND name NOT LIKE '%[0-9][0-9][0-9][0-9]%' -- Exclude 4 consecutive digits
ORDER BY product_id;

---------------------------------------
-- ? OUTPUT OF METHOD 2
---------------------------------------
-- product_id | name
-- -----------|----------------------
-- 1          | ABC123XYZ
-- 5          | 789Product
-- 6          | Item003Description
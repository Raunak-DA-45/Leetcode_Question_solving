/*
===============================================================================
QUERY PURPOSE
===============================================================================
This query fills missing product categories by carrying forward the most recent
non-null category value from previous rows.

In this dataset:
- Only the first product of a category contains the category name.
- Remaining products under the same category contain NULL.
- The goal is to populate those NULL values with the latest known category.

===============================================================================
BUSINESS RULES IMPLEMENTED
===============================================================================
1. A category applies to all following products until a new category appears.
2. NULL category values should inherit the previous non-null category.
3. Product order is preserved as inserted in the table.

===============================================================================
HOW THE QUERY WORKS (STEP-BY-STEP)
===============================================================================
Step 1:
Create a products table containing:
- category     -> Product category name
- brand_name   -> Product/brand name

Step 2:
Insert sample records where:
- Some rows contain category names
- Other rows contain NULL values

Step 3:
Use a WINDOW FUNCTION:
    MAX(category) OVER(...)

Step 4:
The window frame:
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
means:
- Start from the first row
- Continue until the current row

Step 5:
MAX() ignores NULL values.
Therefore:
- It keeps returning the latest available category
- Which effectively fills missing categories

===============================================================================
EXPECTED OUTPUT
===============================================================================
brand_name | filled_category
--------------------------------
Coca Cola  | Beverages
Pepsi      | Beverages
Sprite     | Beverages
Fanta      | Beverages
Lays       | Snacks
Doritos    | Snacks
Kurkure    | Snacks
===============================================================================
*/


/*=============================================================================
CREATE TABLE
=============================================================================*/

CREATE TABLE products (

    -- Product category/group name
    category VARCHAR(50),

    -- Individual brand/product name
    brand_name VARCHAR(50)
);


/*=============================================================================
INSERT SAMPLE DATA
=============================================================================*/

INSERT INTO products (category, brand_name)
VALUES

-- First product under "Beverages"
('Beverages', 'Coca Cola'),

-- Remaining beverage products have NULL category
(NULL, 'Pepsi'),
(NULL, 'Sprite'),
(NULL, 'Fanta'),

-- New category starts here
('Snacks', 'Lays'),

-- Remaining snack products have NULL category
(NULL, 'Doritos'),
(NULL, 'Kurkure');


/*=============================================================================
VIEW ORIGINAL DATA
=============================================================================*/

SELECT *
FROM products;


/*=============================================================================
MAIN QUERY
=============================================================================*/

SELECT

    -- Product/brand name
    brand_name,

    /*
       MAX(category) keeps the latest non-null category
       from the beginning of the dataset up to the current row.
    */
    MAX(category) OVER (

        /*
           No specific sorting column is provided.
           Current table order is used.
        */
        ORDER BY (SELECT NULL)

        /*
           Window frame:
           Start from first row and include current row.
        */
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW

    ) AS filled_category

FROM products;
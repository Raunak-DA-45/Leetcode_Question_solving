/****************************************************************************************
PURPOSE
-------
Calculate the final price of each product after applying a category-based discount.
If a product’s category does not have a discount, the original price is retained.

BUSINESS RULES
--------------
1. Each product belongs to a category and has a base price.
2. Discounts are defined at the category level.
3. Discount values represent percentages (e.g., 10 = 10%).
4. Products without a matching discount should receive a 0% discount.
5. Final price is calculated as:
      price * (1 - discount_percentage / 100)

HOW THE QUERY WORKS (HIGH LEVEL)
--------------------------------
Step 1: Join Products with Discounts using category.
Step 2: Use LEFT JOIN so all products are included, even if no discount exists.
Step 3: Replace NULL discounts with 0 using ISNULL.
Step 4: Convert discount to a percentage using CAST.
Step 5: Calculate the final discounted price.
Step 6: Sort results by product_id.
****************************************************************************************/


/****************************************************************************************
TABLE SCHEMAS
-------------
Defines the structure of each table used in the query.
****************************************************************************************/

-- Stores product-level information
Create table Products (
    product_id int,           -- Unique identifier for each product
    category varchar(50),      -- Product category (used to determine discount)
    price int                 -- Original price of the product
);

-- Stores discount rules per category
Create table Discounts (
    category varchar(50),     -- Category eligible for discount
    discount int              -- Discount percentage (e.g., 10 = 10%)
);


/****************************************************************************************
SAMPLE DATA
-----------
The TRUNCATE statements clear existing data.
INSERT statements provide example records for testing.
****************************************************************************************/

-- Clear existing products
Truncate table Products;

-- Sample products
insert into Products (product_id, category, price) values ('1', 'Electronics', '1000');
insert into Products (product_id, category, price) values ('2', 'Clothing', '50');
insert into Products (product_id, category, price) values ('3', 'Electronics', '1200');
insert into Products (product_id, category, price) values ('4', 'Home', '500');

-- Clear existing discounts
Truncate table Discounts;

-- Sample category discounts
insert into Discounts (category, discount) values ('Electronics', '10');
insert into Discounts (category, discount) values ('Clothing', '20');


/****************************************************************************************
DATA VERIFICATION
-----------
Quick checks to confirm the data loaded correctly.
****************************************************************************************/

select * from products;
select * from Discounts;


/****************************************************************************************
ORIGINAL QUERY (UNCHANGED)
-----------
Calculates the final price for each product after applying the category discount.
****************************************************************************************/

select
	p.product_id,
	p.price*(1-cast(isnull(d.discount,0) as float)/100) final_price,
	p.category
from products p
left join discounts d
on p.category=d.category
order by p.product_id
order by 1;
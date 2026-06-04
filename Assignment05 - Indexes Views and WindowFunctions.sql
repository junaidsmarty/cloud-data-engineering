-- ============================================================
--   ASSIGNMENT 05 — INDEXES, VIEWS & WINDOW FUNCTIONS
--   Database  : BikeStores
--   Topics    : Indexes (Clustered & Non-Clustered)
--               Views
--               ROW_NUMBER / RANK / DENSE_RANK
--               LAG / LEAD
--               COALESCE
-- ============================================================


-- ============================================================
--  SECTION A — INDEXES
-- ============================================================

-- Q1.
-- The marketing team frequently runs campaigns filtered by brand.
-- They search products like this:
--
   --SELECT product_id, product_name, list_price
   --FROM production.products
   --WHERE brand_id = 3;
--
CREATE NONCLUSTERED INDEX PRODUCTS_BRANDID
ON PRODUCTION.PRODUCTS(BRAND_ID);
-- This query is slow. Create an appropriate index to fix it.
-- Then run the query to confirm it returns results correctly.



-- Q2.
-- The finance team runs a monthly report that filters orders
-- by a date range, for example:
--
   --SELECT order_id, customer_id, order_date
   --FROM sales.orders
   --WHERE order_date BETWEEN '2018-01-01' AND '2018-06-30';
--
-- Create an index to make this query more efficient.
CREATE NONCLUSTERED INDEX ORDER_DATE
ON SALES.ORDERS(ORDER_DATE)

-- ============================================================
--  SECTION B — VIEWS
-- ============================================================

-- Q3.
-- The customer support team needs a daily list of all
-- pending and processing orders so they can follow up.
-- Create a view that shows:
--   order_id, customer full name, phone, email,
--   order_date, and order status as a readable label
--   (not a number — use 1=Pending, 2=Processing).
-- After creating it, query the view to see today's workload.
CREATE VIEW WORKLOAD AS
SELECT o.order_id, c.first_name+' '+c.last_name as  Customer_Name,c.phone,c.email,o.order_date,
CASE 
WHEN o.order_status=1 then 'PENDING'
WHEN o.order_status=2 then 'PROCESSING'
ELSE 'NONE RL'
End AS Reading_Label
from sales.orders o join sales.customers c on o.customer_id=c.customer_id

SELECT * FROM WORKLOAD



-- Q4.
-- The inventory manager wants a single view to monitor stock
-- across all stores without writing complex joins every time.
-- Create a view that shows:
--   store_name, product_name, brand_name, category_name, quantity
-- After creating it, query the view to find all products
-- that have fewer than 3 units remaining in any store.
SELECT ss.store_name, p.product_name, b.brand_name, c.category_name, s.quantity
FROM PRODUCTION.PRODUCTS P
JOIN PRODUCTION.STOCKS S ON P.product_id=S.product_id
JOIN SALES.STORES SS ON S.STORE_ID=SS.store_id
JOIN PRODUCTION.categories C ON C.category_id=P.category_id
JOIN production.brands B on B.brand_id=P.brand_id
WHERE QUANTITY<3


-- ============================================================
--  SECTION C — ROW_NUMBER, RANK & DENSE_RANK
-- ============================================================

-- Q5.
-- The sales director wants to see the top 2 best-selling products
-- per store based on total quantity sold.
-- Show store_id, product_id, total_quantity, and their rank within the store.
-- Return only rank 1 and rank 2 for each store.
WITH SALES_RANK 
AS (
SELECT
    o.store_id,
    oi.product_id,
    SUM(oi.quantity) AS total_quantity,
    ROW_NUMBER() OVER
    (
        PARTITION BY o.store_id
        ORDER BY SUM(oi.quantity) DESC
    ) AS Store_Rank
FROM sales.order_items oi
JOIN sales.orders o
    ON o.order_id = oi.order_id
	--where rn<=2
GROUP BY
    o.store_id,
    oi.product_id
)
SELECT * FROM  SALES_RANK WHERE Store_Rank<=2

-- Q6.
-- The pricing team wants to find the 2nd most expensive product
-- in each category.
-- Show category_id, product_name, list_price, and their price rank
-- within the category.
-- Return only the products ranked 2nd in their category.

WITH CTE AS(
SELECT P.PRODUCT_NAME,C.CATEGORY_ID,P.LIST_PRICE,
DENSE_RANK() OVER (
PARTITION BY C.CATEGORY_ID
ORDER BY LIST_PRICE DESC
) AS Expensive_Rank
FROM PRODUCTION.PRODUCTS P
JOIN PRODUCTION.CATEGORIES C ON P.CATEGORY_ID=C.CATEGORY_ID
)
SELECT * FROM CTE WHERE Expensive_Rank=2 ORDER BY CATEGORY_ID

-- Q7.
-- The data team suspects there are duplicate customer records.
-- Use the test table below (already has duplicates built in).
-- Write a query to identify the duplicate rows
-- (same first_name, last_name, and phone).
-- Return only the duplicates — not the original/first occurrence.
--
-- Run this setup first:
--
 CREATE TABLE test_customers (
     customer_id  INT,
     first_name   VARCHAR(50),
     last_name    VARCHAR(50),
     phone        VARCHAR(20),
     city         VARCHAR(50)
 );
--
 INSERT INTO test_customers VALUES
     (1,  'Ali',    'Khan',    '0300-1111111', 'Karachi'),
     (2,  'Sara',   'Ahmed',   '0321-2222222', 'Lahore'),
     (3,  'Ali',    'Khan',    '0300-1111111', 'Karachi'),   -- duplicate of 1
     (4,  'Usman',  'Malik',   '0333-3333333', 'Islamabad'),
     (5,  'Sara',   'Ahmed',   '0321-2222222', 'Lahore'),   -- duplicate of 2
     (6,  'Sara',   'Ahmed',   '0321-2222222', 'Lahore'),   -- 3rd copy of 2
     (7,  'Hina',   'Raza',    '0312-4444444', 'Peshawar');
--
-- Now write your query to find the duplicate rows.
WITH CTE 
AS (
SELECT *, row_number() OVER (
partition by
FIRST_NAME,LAST_NAME,PHONE

ORDER BY FIRST_NAME,LAST_NAME,PHONE 
) AS Rededency
FROM test_customers
)

SELECT first_name,last_name,phone
FROM CTE where rededency>1


-- ============================================================
--  SECTION D — LAG, LEAD & COALESCE
-- ============================================================

-- Q8.
-- The finance team wants a month-by-month revenue report for 2017.
-- For each month, show total net sales and how much it grew or
-- dropped compared to the previous month.
-- Show month, net_sales, previous_month_sales, and the difference.
-- Net sales = SUM( quantity * list_price * (1 - discount) )

WITH SALES_COMPARISION
AS(
SELECT MONTH(O.ORDER_DATE) AS MONTH,SUM( OI.quantity * OI.list_price * (1 - OI.discount) ) AS NET_SALES,
LAG(SUM( OI.quantity * OI.list_price * (1 - OI.discount) )) OVER(ORDER BY MONTH(O.ORDER_DATE)) AS PREVIOUS_MONTH_SALES
FROM SALES.ORDERS O
JOIN SALES.ORDER_ITEMS OI ON O.ORDER_ID=OI.ORDER_ID
GROUP BY MONTH(O.ORDER_DATE)
)

SELECT *,NET_SALES-PREVIOUS_MONTH_SALES AS DIFFERENCE_SALES FROM  SALES_COMPARISION 



-- Q9.
-- The product team wants to see each product's price compared to
-- the next cheaper product in the same category.
-- Show product_name, list_price, and the next lower price
-- in the same category.
-- Sort by category_id and list_price descending.

SELECT CATEGORY_ID,PRODUCT_ID,product_name,list_price, 
LEAD(LIST_PRICE) OVER(PARTITION BY CATEGORY_ID ORDER BY LIST_PRICE DESC) AS PRICE_COMPARISION
FROM PRODUCTION.PRODUCTS P
ORDER BY CATEGORY_ID,LIST_PRICE DESC


-- Q10.
-- The CRM team is cleaning up customer records.
-- Some customers have no phone number on file.
-- Show each customer's full name, phone, and email.
-- Replace any missing phone with their email address instead.
-- If both are missing, show 'No Contact Info'.
-- Sort by last_name, first_name.

SELECT FIRST_NAME+' '+LAST_NAME AS FULL_NAME,
COALESCE (PHONE,EMAIL,'NO Contact Info') AS PHONE
,EMAIL
FROM SALES.CUSTOMERS
ORDER BY last_name,first_name





-- ============================================================
--  END OF ASSIGNMENT 05
-- ============================================================

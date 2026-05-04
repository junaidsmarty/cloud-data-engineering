-- ============================================================
--  ASSIGNMENT 02 — Joins
--  Database : BikeStores
-- ============================================================


-- ============================================================
--  Question 1
--  Retrieve the product_name, list_price, and category_name
--  for every product.
--  Use production.products and production.categories.
--  Sort the results by product_name ascending.
-- ============================================================

-- Write your query below:

SELECT P.PRODUCT_NAME,P.LIST_PRICE,C.CATEGORY_NAME FROM PRODUCTION.PRODUCTS P
JOIN PRODUCTION.CATEGORIES C
ON C.category_id=P.category_id 
ORDER BY P.PRODUCT_NAME 


-- ============================================================
--  Question 2
--  Show the customer full name (as full_name), order_id,
--  and order_date for all customers who have placed an order.
--  Use sales.customers and sales.orders.
--  Sort by order_date descending.
-- ============================================================

-- Write your query below:

select c.first_name+' '+c.last_name as Full_Name , o.order_id,o.order_date from sales.customers c
join sales.orders o
on c.customer_id=o.customer_id
order by o.order_date desc


-- ============================================================
--  Question 3
--  Retrieve product_name, list_price, category_name, and
--  brand_name for every product.
--  Use production.products, production.categories,
--  and production.brands.
--  Sort by brand_name then product_name (both ascending).
-- ============================================================

-- Write your query below:
SELECT P.PRODUCT_NAME,P.LIST_PRICE,C.CATEGORY_NAME,B.BRAND_NAME FROM PRODUCTION.PRODUCTS P
JOIN PRODUCTION.CATEGORIES C
ON C.category_id=P.category_id 
JOIN PRODUCTION.BRANDS B
ON B.BRAND_ID=P.BRAND_ID
ORDER BY B.BRAND_NAME,P.PRODUCT_NAME 



-- ============================================================
--  Question 4
--  List all products along with their order_id and item_id.
--  Make sure products that have NEVER been ordered also appear
--  in the result (those rows will have NULL for order_id
--  and item_id).
--  Use production.products and sales.order_items.
--  Sort by order_id ascending.
-- ============================================================

-- Write your query below:
SELECT P.PRODUCT_NAME,OI.ORDER_ID,OI.ITEM_ID FROM PRODUCTION.PRODUCTS P
LEFT JOIN SALES.ORDER_ITEMS OI
ON P.PRODUCT_ID=OI.PRODUCT_ID
ORDER BY OI.order_id 

-- ============================================================
--  Question 5
--  Using your answer from Question 4 as a base, filter the
--  results to show ONLY the products that have never been
--  ordered.
--  Display only product_id and product_name.
-- ============================================================

-- Write your query below:
SELECT P.PRODUCT_NAME,P.PRODUCT_ID FROM PRODUCTION.PRODUCTS P
LEFT JOIN SALES.ORDER_ITEMS OI
ON P.PRODUCT_ID=OI.PRODUCT_ID
WHERE OI.ORDER_ID IS NULL
ORDER BY P.PRODUCT_ID

-- ============================================================
--  Question 6
--  Show all stores along with any orders placed at each store.
--  Display store_name, store_id (from stores), order_id,
--  and order_date.
--  Every store must appear in the result, even if it has
--  no orders yet.
--  Use sales.orders and sales.stores.
-- ============================================================

-- Write your query below:
SELECT S.STORE_NAME,S.store_id,O.order_id,O.order_date FROM SALES.ORDERS O
RIGHT JOIN SALES.STORES S
ON S.store_id=O.STORE_ID

-- ============================================================
--  Question 7
--  List every staff member alongside their manager's name.
--  Display:
--    • staff full name   (as staff_name)
--    • manager full name (as manager_name)
--  Use only the sales.staffs table.
--  Staff who have no manager should NOT appear in the result.
-- ============================================================

-- Write your query below:
SELECT S.FIRST_NAME+' '+S.LAST_NAME AS Staff_Name, s.staff_id,
       M.FIRST_NAME+' '+M.LAST_NAME AS Manager_Name,m.staff_id
FROM SALES.STAFFS S
JOIN SALES.STAFFS M
ON M.STAFF_ID=S.MANAGER_ID


-- ============================================================
--  Question 8
--  Generate every possible combination of store name and
--  brand name.
--  Display store_name and brand_name.
--  Use sales.stores and production.brands.
--  How many total rows do you expect?
--  Write the expected count as a comment next to your query.
-- ============================================================

-- Write your query below:

select s.store_name,b.brand_name,s.store_name+' '+b.brand_name from sales.stores s
join production.stocks st
on s.store_id=st.store_id
join production.products p
on st.product_id=p.product_id
join production.brands b
on b.brand_id=p.brand_id
--Row count:939
--Distinct Combination Row Count : 27


-- ============================================================
--  Question 9
--  Retrieve the customer full name (as full_name), order_id,
--  order_date, product_name, and list_price for every order
--  that has been placed.
--  Use sales.customers, sales.orders, sales.order_items,
--  and production.products.
--  Sort by order_date ascending, then full_name ascending.
-- ============================================================

-- Write your query below:
select c.first_name + ' ' +c.last_name as Full_Name,o.order_id,o.order_date,p.product_name,p.list_price from sales.customers c
join sales.orders o
on o.customer_id=c.customer_id
join sales.order_items oi
on o.order_id=oi.order_id
join production.products p
on oi.product_id=p.product_id
order by o.order_date, full_name
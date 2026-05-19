-- ============================================================
--   ASSIGNMENT 03 — GROUP BY, HAVING & SUBQUERIES
--   Database  : BikeStores
--   Topics    : GROUP BY · Aggregate Functions · HAVING
--               Subqueries · JOINs with GROUP BY
-- ============================================================


-- ============================================================
--  SECTION A — GROUP BY & AGGREGATE FUNCTIONS
-- ============================================================

-- Q1.
-- Count the total number of orders placed by each customer.
-- Show customer_id and order_count.
-- Sort by order_count descending.

SELECT CUSTOMER_ID,COUNT(DISTINCT(ORDER_ID)) FROM SALES.ORDERS
GROUP BY CUSTOMER_ID
ORDER BY COUNT(DISTINCT(ORDER_ID)) DESC

-- Q2.
-- For each store, find the total number of orders placed.
-- Show store_id and total_orders.
SELECT store_ID,COUNT(DISTINCT(ORDER_ID)) FROM SALES.ORDERS
GROUP BY store_ID
ORDER BY COUNT(DISTINCT(ORDER_ID)) DESC


-- Q3.
-- Calculate the net revenue per order.
-- Net revenue formula: SUM( quantity * list_price * (1 - discount) )
-- Show order_id and net_revenue, sorted by net_revenue descending.
-- (Hint: use sales.order_items)
select Order_ID,SUM( quantity * list_price * (1 - discount) ) as Net_Value from sales.order_items
Group by order_id
order by Net_Value desc


-- Q4.
-- Find the average list price of products in each category.
-- Show category_id and avg_price (rounded to 2 decimal places).
-- (Hint: use ROUND())
SELECT category_ID,round(avg(list_price),2) FROM production.products
GROUP BY category_id


-- Q5.
-- Find the total number of orders placed in each year.
-- Show order_year and total_orders, sorted by order_year.
-- (Hint: use YEAR(order_date))
select YEAR(order_date),count(distinct(order_id)) 
from sales.orders
group by YEAR(order_date)


-- ============================================================
--  SECTION B — HAVING CLAUSE
-- ============================================================

-- Q6.
-- Find customers who have placed MORE than 5 orders in total.
-- Show customer_id and order_count.
select customer_id,count(distinct(order_id))
from sales.orders
group by customer_id
having count(distinct(order_id)) >5


-- Q7.
-- Find categories where the AVERAGE list price is greater than $1,500.
-- Show category_id and avg_price.
select category_id,avg(list_price)
from production.products
group by category_id
having avg(list_price)>1500


-- Q8.
-- Find customers who placed at least 2 orders in the year 2017.
-- Show customer_id, order_year, and order_count.
select customer_id,year(order_date),count(distinct(order_Id))
from sales.orders where year(order_date)='2017'
group by customer_id,year(order_date)
having count(distinct(order_Id))>=2


-- ============================================================
--  SECTION C — SUBQUERIES
-- ============================================================

-- Q9.
-- Find all orders placed by customers who live in 'Houston'.
-- Use a subquery to get the customer_ids first.
-- Show all columns from sales.orders.
select * from sales.orders 
where customer_id in (
select customer_id from sales.customers where city='Houston'
)


-- Q10.
-- Find all products whose list_price is greater than the
-- AVERAGE list_price of ALL products.
-- Show product_name and list_price.

select product_name,list_price 
from production.products
where list_price>(select avg(list_price) from production.products)



-- Q11.
-- Find all products that belong to the category 'Mountain Bikes'
-- or 'Road Bikes'. Use a subquery on production.categories.
-- Show product_name and list_price.
select product_name,list_price from production.products
where category_id in (
select category_id from production.categories where category_name in ('Mountain Bikes','Road Bikes')
)

-- Q12.
-- Find all customers who have NEVER placed an order.
-- Show customer_id, first_name, and last_name.
-- (Hint: use NOT IN with a subquery on sales.orders)
select customer_id,first_name,last_name
from sales.customers where customer_id not in(select customer_id from sales.orders group by customer_id having count(Order_id)>=1)


-- ============================================================
--  SECTION D — JOINs WITH GROUP BY
-- ============================================================

-- Q13.
-- Find the total number of orders per city (customer's city).
-- Join sales.orders with sales.customers.
-- Show city and total_orders, sorted by total_orders descending.
select c.city,count(distinct(o.order_id))
from sales.customers c
join sales.orders o
on c.customer_id=o.customer_id
group by c.city


-- Q14.
-- For each staff member, count how many orders they handled.
-- Join sales.orders with sales.staffs.
-- Show staff full name (first_name + ' ' + last_name) as staff_name
-- and order_count, sorted by order_count descending.
select s.first_name+' '+s.last_name as Staff_Name,count(distinct(o.order_id)) as Order_Count
from sales.orders o 
join sales.staffs s
on s.staff_id=o.staff_id
group by s.first_name+' '+s.last_name


-- Q15. (BONUS — Multi-concept)
-- Find customers who have spent more than $10,000 in total.
-- Join sales.customers → sales.orders → sales.order_items.
-- Show customer full name as customer_name and total_spent.
-- Sort by total_spent descending.
-- (Hint: JOIN + GROUP BY + HAVING)

select c.first_name+' '+c.last_name,sum( quantity * list_price * (1 - discount) ) as Net_Value
from sales.orders o
join sales.order_items oi on o.order_id=oi.order_id 
join sales.customers c on c.customer_id=o.customer_id
group by c.first_name+' '+c.last_name
having sum( quantity * list_price * (1 - discount) )>10000
order by net_value desc

-- ============================================================
--  END OF ASSIGNMENT 03
-- ============================================================
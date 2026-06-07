--Q1. List top 5 customers by total order amount.
--Retrieve the top 5 customers who have spent the most across all sales orders. Show CustomerID, CustomerName, and TotalSpent.

Select top 5
so.customerid,c.name,sum(so.customerid) as Total_Spent from salesorder so
Join customer c on so.customerid=c.customerid
group by so.customerid,c.name
order by Total_Spent desc

--Q2. Find the number of products supplied by each supplier.
--Display SupplierID, SupplierName, and ProductCount. Only include suppliers that have more than 10 products.

select po.SupplierID,sp.Name,count(distinct(sd.productid)) as ProductCount from ShipmentDetail sd
join Shipment s on sd.ShipmentID=s.ShipmentID
join purchaseorder po on po.orderid=s.OrderID
join supplier sp on po.SupplierID=sp.SupplierID
group by po.SupplierID,sp.Name
having count(distinct(sd.productid))>10

--Q3. Identify products that have been ordered but never returned.
--Show ProductID, ProductName, and total order quantity.
with cte as
(
select productid,name from product where productid in (
select productid from salesorderdetail
except 
select productid from returndetail
)
) 
select c.ProductID, c.Name,sum(quantity) as TotalOrderQuantity from cte c join salesorderdetail sod on c.productid=sod.productid
group by c.ProductID, c.Name





--Q4. For each category, find the most expensive product.
--Display CategoryID, CategoryName, ProductName, and Price. Use a subquery to get the max price per category.

SELECT 
    c.CategoryID,
    c.Name AS CategoryName,
    p.Name AS ProductName,
    p.Price
FROM category c
JOIN product p 
    ON c.CategoryID = p.CategoryID
WHERE p.Price = (
    SELECT MAX(p2.Price)
    FROM product p2
    WHERE p2.CategoryID = p.CategoryID
)
order by c.categoryid;

--Q5. List all sales orders with customer name, product name, category, and supplier.
--For each sales order, display:
--OrderID, CustomerName, ProductName, CategoryName, SupplierName, and Quantity.

SELECT 
    so.OrderID,
    c.Name AS CustomerName,
    p.Name AS ProductName,
    cat.Name AS CategoryName,
    s.Name AS SupplierName,
    sod.Quantity
FROM salesorder so
JOIN customer c
    ON so.CustomerID = c.CustomerID
JOIN salesorderdetail sod
    ON so.OrderID = sod.OrderID
JOIN product p
    ON sod.ProductID = p.ProductID
JOIN category cat
    ON p.CategoryID = cat.CategoryID
JOIN purchaseorderdetail pod
    ON p.ProductID = pod.ProductID
JOIN purchaseorder po
    ON pod.OrderID = po.OrderID
JOIN supplier s
    ON po.SupplierID = s.SupplierID;


--Q6. Find all shipments with details of warehouse, manager, and products shipped.
--Display:
--ShipmentID, WarehouseName, ManagerName, ProductName, QuantityShipped, and TrackingNumber.

SELECT
    s.ShipmentID,
    l.Name AS WarehouseName,
    e.Name AS ManagerName,
    p.Name AS ProductName,
    sd.Quantity AS QuantityShipped,
    s.TrackingNumber
FROM shipment s
INNER JOIN warehouse w
    ON s.WarehouseID = w.WarehouseID
INNER JOIN employee e
    ON w.ManagerID = e.EmployeeID
INNER JOIN location l
    ON w.LocationID = l.LocationID
INNER JOIN shipmentdetail sd
    ON s.ShipmentID = sd.ShipmentID
INNER JOIN product p
    ON sd.ProductID = p.ProductID
ORDER BY s.ShipmentID, p.Name;


--Q7. Find the top 3 highest-value orders per customer using RANK(). Display CustomerID, CustomerName, OrderID, and TotalAmount.
with cte as(
select so.customerid,c.name,so.orderid,so.totalamount,
rank() over (partition by so.customerid order by so.totalamount desc) as Ranking
from salesorder so
join customer c on so.customerid=c.customerid
)
select customerid,name,orderid,totalamount from cte
where ranking<=3
order by customerid,ranking

--Q8. For each product, show its sales history with the previous and next sales quantities (based on order date). 
--Display ProductID, ProductName, OrderID, OrderDate, Quantity, PrevQuantity, and NextQuantity.
select  sod.productid,p.name,sod.orderid,so.orderdate,sod.quantity,
LAG(sod.quantity) OVER
    (
        partition by sod.productid ORDER BY sod.productid,so.orderdate
    ) AS PrevQuantity,
LEAD(sod.quantity) OVER
    (
        partition by sod.productid ORDER BY sod.productid,so.orderdate
    ) AS NextQuantity
from salesorderdetail sod 
join salesorder so on sod.orderid=so.orderid
join product p on sod.productid=p.productid
order by sod.productid,p.name,orderdate


--Q9. Create a view named vw_CustomerOrderSummary that shows for each customer:
--CustomerID, CustomerName, TotalOrders, TotalAmountSpent, and LastOrderDate.

Create view vw_CustomerOrderSummary as(
select c.customerid,c.name as CustomerName,count(distinct(so.orderid)) as TotalOrders,sum(so.totalamount) as TotalAmountSpent,max(so.orderdate) as LastOrderDate  from customer c
left join salesorder so on so.customerid=c.customerid
group by c.customerid,c.name)

select * from vw_CustomerOrderSummary

--Q10. Write a stored procedure sp_GetSupplierSales that takes a SupplierID as input and returns the total sales amount for all products supplied by that supplier.

CREATE PROCEDURE sp_GetSupplierSales
    @SupplierID INT
AS
BEGIN
    SELECT
        @SupplierID AS SupplierID,
        COALESCE(SUM(sod.TotalAmount), 0) AS TotalSalesAmount
    FROM product p
    INNER JOIN salesorderdetail sod
        ON p.ProductID = sod.ProductID
    WHERE p.ManufacturerID = @SupplierID;
END;

EXEC sp_GetSupplierSales @SupplierID = 1;


SELECT * FROM vw_CustomerOrderSummary
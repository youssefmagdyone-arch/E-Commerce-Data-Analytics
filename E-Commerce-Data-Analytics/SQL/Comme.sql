create database Ecomm
use Ecomm


SELECT name
FROM sys.databases
WHERE name = 'Ecomm';


SELECT 'Customers' AS TableName, COUNT(*) AS TotalRows FROM dbo.Customers
UNION ALL
SELECT 'OrderItems', COUNT(*) FROM dbo.OrderItems
UNION ALL
SELECT 'Orders', COUNT(*) FROM dbo.Orders
UNION ALL
SELECT 'Payments', COUNT(*) FROM dbo.Payments
UNION ALL
SELECT 'Products', COUNT(*) FROM dbo.Products
UNION ALL
SELECT 'Promotions', COUNT(*) FROM dbo.Promotions
UNION ALL
SELECT 'Returns', COUNT(*) FROM dbo.Returns;
GO





-- Customers → Orders
SELECT COUNT(*) AS Invalid_Customers
FROM Orders O
LEFT JOIN Customers C
    ON O.CustomerID = C.CustomerID
WHERE C.CustomerID IS NULL;


-- Orders → OrderItems
SELECT COUNT(*) AS Invalid_Orders
FROM OrderItems OI
LEFT JOIN Orders O
    ON OI.OrderID = O.OrderID
WHERE O.OrderID IS NULL;





-- Products → OrderItems
SELECT COUNT(*) AS Invalid_Products
FROM OrderItems OI
LEFT JOIN Products P
    ON OI.ProductID = P.ProductID
WHERE P.ProductID IS NULL;


-- Orders → Payments
SELECT COUNT(*) AS Invalid_Payments
FROM Payments P
LEFT JOIN Orders O
    ON P.OrderID = O.OrderID
WHERE O.OrderID IS NULL;


-- Orders → Returns
SELECT COUNT(*) AS Invalid_Returns
FROM Returns R
LEFT JOIN Orders O
    ON R.OrderID = O.OrderID
WHERE O.OrderID IS NULL;


-- Products → Returns
SELECT COUNT(*) AS Invalid_Return_Products
FROM Returns R
LEFT JOIN Products P
    ON R.ProductID = P.ProductID
WHERE P.ProductID IS NULL;


-- Orders → Promotions
SELECT COUNT(*) AS Invalid_Promotions
FROM Orders O
LEFT JOIN Promotions PR
    ON O.PromotionID = PR.PromotionID
WHERE O.PromotionID IS NOT NULL
AND PR.PromotionID IS NULL;
GO



--Overall Sales Performance
SELECT
    COUNT(OrderID) AS TotalOrders,
    SUM(OrderTotal) AS TotalRevenue,
    AVG(OrderTotal) AS AverageOrderValue,
    MAX(OrderTotal) AS HighestOrderValue,
    MIN(OrderTotal) AS LowestOrderValue,
    SUM(ShippingFee) AS TotalShippingFees,
    SUM(TaxAmount) AS TotalTax
FROM Orders;

--Overall Sales Performance     
SELECT
    YEAR(OrderDate) AS SalesYear,
    MONTH(OrderDate) AS SalesMonth,
    COUNT(OrderID) AS TotalOrders,
    SUM(OrderTotal) AS TotalRevenue,
    AVG(OrderTotal) AS AverageOrderValue
FROM Orders
GROUP BY
    YEAR(OrderDate),
    MONTH(OrderDate)
ORDER BY
    SalesYear,
    SalesMonth;

--Yearly Sales Performance
SELECT
    YEAR(OrderDate) AS SalesYear,
    COUNT(OrderID) AS TotalOrders,
    SUM(OrderTotal) AS TotalRevenue,
    AVG(OrderTotal) AS AverageOrderValue
FROM Orders
GROUP BY YEAR(OrderDate)
ORDER BY SalesYear;

--Revenue Growth Rate (YoY)
WITH YearlySales AS
(
    SELECT
        YEAR(OrderDate) AS SalesYear,
        SUM(OrderTotal) AS TotalRevenue
    FROM Orders
    GROUP BY YEAR(OrderDate)
)

SELECT
    SalesYear,
    TotalRevenue,
    LAG(TotalRevenue) OVER (ORDER BY SalesYear) AS PreviousYearRevenue,

    ROUND(
        (TotalRevenue - LAG(TotalRevenue) OVER (ORDER BY SalesYear))
        * 100.0
        / LAG(TotalRevenue) OVER (ORDER BY SalesYear),
        2
    ) AS RevenueGrowthPercentage

FROM YearlySales
ORDER BY SalesYear;

--Order Status Analysis

SELECT
    OrderStatus,
    COUNT(OrderID) AS TotalOrders,
    SUM(OrderTotal) AS TotalRevenue,
    AVG(OrderTotal) AS AverageOrderValue,
    ROUND(
        COUNT(OrderID) * 100.0 /
        (SELECT COUNT(*) FROM Orders),
        2
    ) AS OrderPercentage
FROM Orders
GROUP BY OrderStatus
ORDER BY TotalOrders DESC;



--Sales Channel Analysis
SELECT
    SalesChannel,
    COUNT(OrderID) AS TotalOrders,
    SUM(OrderTotal) AS TotalRevenue,
    AVG(OrderTotal) AS AverageOrderValue,
    ROUND(
        COUNT(OrderID) * 100.0 /
        (SELECT COUNT(*) FROM Orders),
        2
    ) AS OrderPercentage
FROM Orders
GROUP BY SalesChannel
ORDER BY TotalRevenue DESC;




--Order Size Analysis
SELECT
    CASE
        WHEN OrderTotal < 1000 THEN 'Small Order'
        WHEN OrderTotal < 5000 THEN 'Medium Order'
        WHEN OrderTotal < 10000 THEN 'Large Order'
        ELSE 'Very Large Order'
    END AS OrderSizeCategory,

    COUNT(OrderID) AS TotalOrders,
    SUM(OrderTotal) AS TotalRevenue,
    AVG(OrderTotal) AS AverageOrderValue,

    ROUND(
        COUNT(OrderID) * 100.0 /
        (SELECT COUNT(*) FROM Orders),
        2
    ) AS OrderPercentage

FROM Orders
GROUP BY
    CASE
        WHEN OrderTotal < 1000 THEN 'Small Order'
        WHEN OrderTotal < 5000 THEN 'Medium Order'
        WHEN OrderTotal < 10000 THEN 'Large Order'
        ELSE 'Very Large Order'
    END

ORDER BY TotalOrders DESC;

--Shipping Analysis

SELECT
    COUNT(OrderID) AS TotalOrders,
    SUM(ShippingFee) AS TotalShippingFees,
    AVG(ShippingFee) AS AverageShippingFee,
    MIN(ShippingFee) AS MinimumShippingFee,
    MAX(ShippingFee) AS MaximumShippingFee,

    SUM(OrderTotal) AS TotalRevenue,

    ROUND(
        SUM(ShippingFee) * 100.0 / SUM(OrderTotal),
        2
    ) AS ShippingPercentageOfRevenue

FROM Orders;


--Customer Order Frequency

WITH CustomerOrders AS
(
    SELECT
        CustomerID,
        COUNT(OrderID) AS OrderCount,
        SUM(OrderTotal) AS TotalSpent
    FROM Orders
    GROUP BY CustomerID
)

SELECT
    CASE
        WHEN OrderCount = 1 THEN 'One-Time Customer'
        WHEN OrderCount BETWEEN 2 AND 5 THEN 'Regular Customer'
        WHEN OrderCount BETWEEN 6 AND 10 THEN 'Frequent Customer'
        ELSE 'VIP Customer'
    END AS CustomerType,

    COUNT(CustomerID) AS TotalCustomers,
    SUM(OrderCount) AS TotalOrders,
    SUM(TotalSpent) AS TotalRevenue,
    AVG(TotalSpent) AS AverageCustomerSpending

FROM CustomerOrders

GROUP BY
    CASE
        WHEN OrderCount = 1 THEN 'One-Time Customer'
        WHEN OrderCount BETWEEN 2 AND 5 THEN 'Regular Customer'
        WHEN OrderCount BETWEEN 6 AND 10 THEN 'Frequent Customer'
        ELSE 'VIP Customer'
    END

ORDER BY TotalCustomers DESC;

--Order Time Analysis
SELECT
    DATENAME(WEEKDAY, OrderDate) AS DayOfWeek,
    COUNT(OrderID) AS TotalOrders,
    SUM(OrderTotal) AS TotalRevenue,
    AVG(OrderTotal) AS AverageOrderValue

FROM Orders

GROUP BY DATENAME(WEEKDAY, OrderDate)

ORDER BY TotalOrders DESC;

--Customers + Orders
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    c.City,
    c.CustomerSegment,
    o.OrderID,
    o.OrderDate,
    o.OrderStatus,
    o.OrderTotal
FROM Customers c
INNER JOIN Orders o
    ON c.CustomerID = o.CustomerID;


    --Orders + OrderItems
SELECT
    o.OrderID,
    o.CustomerID,
    o.OrderDate,
    o.OrderStatus,
    oi.OrderItemID,
    oi.ProductID,
    oi.Quantity,
    oi.UnitPrice,
    oi.DiscountPercent,
    oi.LineTotal
FROM Orders o
INNER JOIN OrderItems oi
    ON o.OrderID = oi.OrderID;



    --OrderItems + Products
SELECT
    oi.OrderItemID,
    oi.OrderID,
    p.ProductID,
    p.ProductName,
    p.Category,
    p.SubCategory,
    p.Brand,
    oi.Quantity,
    oi.UnitPrice,
    oi.DiscountPercent,
    oi.LineTotal
FROM OrderItems oi
INNER JOIN Products p
    ON oi.ProductID = p.ProductID;


    --Orders + Payments
SELECT
    o.OrderID,
    o.CustomerID,
    o.OrderDate,
    o.OrderTotal,
    p.PaymentID,
    p.PaymentDate,
    p.PaymentMethod,
    p.PaymentStatus,
    p.AmountPaid
FROM Orders o
INNER JOIN Payments p
    ON o.OrderID = p.OrderID;


    --Orders + Promotions
SELECT
    o.OrderID,
    o.OrderDate,
    o.OrderTotal,
    o.PromotionID,
    p.PromotionName,
    p.PromotionType,
    p.DiscountValue,
    p.StartDate,
    p.EndDate
FROM Orders o
LEFT JOIN Promotions p
    ON o.PromotionID = p.PromotionID;


    --Returns + Orders
    SELECT
    r.ReturnID,
    r.OrderID,
    o.CustomerID,
    o.OrderDate,
    o.OrderStatus,
    r.ProductID,
    r.ReturnDate,
    r.ReturnReason,
    r.ReturnQuantity,
    r.RefundAmount,
    r.ReturnStatus
FROM Returns r
INNER JOIN Orders o
    ON r.OrderID = o.OrderID;



    --Returns + Products
    SELECT
    r.ReturnID,
    r.OrderID,
    r.ProductID,
    p.ProductName,
    p.Category,
    p.SubCategory,
    p.Brand,
    r.ReturnDate,
    r.ReturnReason,
    r.ReturnQuantity,
    r.RefundAmount,
    r.ReturnStatus
FROM Returns r
INNER JOIN Products p
    ON r.ProductID = p.ProductID;


    --all tables

    SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    c.CustomerSegment,

    o.OrderID,
    o.OrderDate,
    o.OrderStatus,
    o.SalesChannel,
    o.OrderTotal,

    oi.OrderItemID,
    oi.ProductID,
    oi.Quantity,
    oi.UnitPrice,
    oi.DiscountPercent,
    oi.LineTotal,

    pr.ProductName,
    pr.Category,
    pr.SubCategory,
    pr.Brand,

    pay.PaymentID,
    pay.PaymentMethod,
    pay.PaymentStatus,
    pay.AmountPaid,

    promo.PromotionName,
    promo.PromotionType,

    r.ReturnID,
    r.ReturnReason,
    r.ReturnQuantity,
    r.RefundAmount,
    r.ReturnStatus

FROM Orders o

INNER JOIN Customers c
    ON o.CustomerID = c.CustomerID

INNER JOIN OrderItems oi
    ON o.OrderID = oi.OrderID

INNER JOIN Products pr
    ON oi.ProductID = pr.ProductID

LEFT JOIN Payments pay
    ON o.OrderID = pay.OrderID

LEFT JOIN Promotions promo
    ON o.PromotionID = promo.PromotionID

LEFT JOIN Returns r
    ON o.OrderID = r.OrderID;




SELECT
    p.ProductID,
    p.ProductName,
    p.Category,
    p.SubCategory,
    p.Brand,

    SUM(oi.Quantity) AS TotalUnitsSold,
    COUNT(DISTINCT oi.OrderID) AS TotalOrders,
    SUM(oi.LineTotal) AS TotalRevenue

FROM OrderItems oi

INNER JOIN Products p
    ON oi.ProductID = p.ProductID

GROUP BY
    p.ProductID,
    p.ProductName,
    p.Category,
    p.SubCategory,
    p.Brand

ORDER BY TotalRevenue DESC;







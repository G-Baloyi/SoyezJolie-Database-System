SELECT p.ProductName,
       SUM(ps.Quantity) AS TotalSold,
       SUM(ps.AmountPaid) AS TotalRevenue
FROM ProductSales ps
JOIN Products p ON ps.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY TotalRevenue DESC;

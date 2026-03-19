CREATE TRIGGER trg_DecreaseStockAfterSale
ON ProductSales
AFTER INSERT
AS
BEGIN
    UPDATE Products
    SET StockQuantity = StockQuantity - i.Quantity
    FROM Products p
    JOIN inserted i ON p.ProductID = i.ProductID;
END;

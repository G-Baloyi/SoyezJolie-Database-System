-- =============================================
-- Author:      Your Name
-- Create date: 2026-03-19
-- Description: Updates product stock after a sale
-- =============================================
CREATE OR ALTER PROCEDURE sp_UpdateStock
    @ProductID INT,
    @QuantitySold INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check if product exists
        IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductID = @ProductID)
        BEGIN
            THROW 50001, 'Product does not exist.', 1;
        END

        -- Update stock quantity
        UPDATE Products
        SET StockQuantity = StockQuantity - @QuantitySold
        WHERE ProductID = @ProductID;

        -- Check for negative stock
        IF (SELECT StockQuantity FROM Products WHERE ProductID = @ProductID) < 0
        BEGIN
            THROW 50002, 'Stock quantity cannot be negative.', 1;
        END
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();
        THROW @ErrorMessage, @ErrorSeverity, @ErrorState;
    END CATCH
END;
GO

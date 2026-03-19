/* =========================================
   SOYEZ JOLIE DATABASE SYSTEM
   FULL DATABASE SCRIPT
   ========================================= */

-- 1. CREATE DATABASE
IF DB_ID('SoyezJolie') IS NOT NULL
BEGIN
    DROP DATABASE SoyezJolie;
END;
GO

CREATE DATABASE SoyezJolie;
GO
USE SoyezJolie;
GO

-- 2. CREATE LOGIN AND USER (SECURITY)
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'SoyezJolieLogin')
BEGIN
    CREATE LOGIN SoyezJolieLogin WITH PASSWORD = 'StrongPassword123!';
END;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'SoyezJolieUser')
BEGIN
    CREATE USER SoyezJolieUser FOR LOGIN SoyezJolieLogin;
    ALTER ROLE db_datareader ADD MEMBER SoyezJolieUser;
    ALTER ROLE db_datawriter ADD MEMBER SoyezJolieUser;
END;
GO

-- 3. TABLES
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FullName VARCHAR(50) NOT NULL,
    ContactNumber VARCHAR(15) NOT NULL UNIQUE,
    EmailAddress VARCHAR(50) UNIQUE,
    POPIAcceptance BIT NOT NULL DEFAULT 0
);
GO

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    FullName VARCHAR(50) NOT NULL,
    Role VARCHAR(50) NOT NULL,
    Certification BIT DEFAULT 0
);
GO

CREATE TABLE Services (
    ServiceID INT PRIMARY KEY IDENTITY(1,1),
    ServiceName VARCHAR(50) NOT NULL,
    Category VARCHAR(50) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Duration INT NOT NULL
);
GO

CREATE TABLE Treatments (
    TreatmentID INT PRIMARY KEY IDENTITY(1,1),
    ServiceID INT NOT NULL,
    TreatmentType VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Duration INT NOT NULL,
    FOREIGN KEY (ServiceID) REFERENCES Services(ServiceID)
);
GO

CREATE TABLE EmployeeServices (
    EmployeeID INT NOT NULL,
    ServiceID INT NOT NULL,
    PRIMARY KEY (EmployeeID, ServiceID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    FOREIGN KEY (ServiceID) REFERENCES Services(ServiceID)
);
GO

CREATE TABLE Appointments (
    AppointmentID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL,
    EmployeeID INT NOT NULL,
    AppointmentDateTime DATETIME NOT NULL,
    AppointmentStatus VARCHAR(50) NOT NULL CHECK (AppointmentStatus IN ('Scheduled','Completed','Cancelled')),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);
GO

CREATE TABLE AppointmentServices (
    AppointmentID INT NOT NULL,
    ServiceID INT NOT NULL,
    TreatmentID INT NOT NULL,
    EmployeeID INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    AmountPaid DECIMAL(10,2) NOT NULL,
    Discount DECIMAL(10,2) DEFAULT 0,
    PaymentMethod VARCHAR(20) CHECK (PaymentMethod IN ('Cash','Card','Voucher')),
    PRIMARY KEY (AppointmentID, ServiceID, TreatmentID),
    FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID),
    FOREIGN KEY (ServiceID) REFERENCES Services(ServiceID),
    FOREIGN KEY (TreatmentID) REFERENCES Treatments(TreatmentID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);
GO

CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    AppointmentID INT NOT NULL,
    PaymentMethod VARCHAR(20) NOT NULL,
    AmountPaid DECIMAL(10,2) NOT NULL,
    TipAmount DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID)
);
GO

CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName VARCHAR(50) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    StockQuantity INT DEFAULT 0,
    Category VARCHAR(50) NOT NULL
);
GO

CREATE TABLE ProductSales (
    ProductSaleID INT PRIMARY KEY IDENTITY(1,1),
    ProductID INT NOT NULL,
    CustomerID INT NOT NULL,
    EmployeeID INT NOT NULL,
    Quantity INT NOT NULL,
    AmountPaid DECIMAL(10,2) NOT NULL,
    SaleDate DATETIME NOT NULL,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);
GO

CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY IDENTITY(1,1),
    SupplierName VARCHAR(50) NOT NULL,
    ContactNumber VARCHAR(15) NOT NULL
);
GO

CREATE TABLE Promotions (
    PromotionID INT PRIMARY KEY IDENTITY(1,1),
    Description VARCHAR(100) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL
);
GO

CREATE TABLE Feedback (
    FeedbackID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL,
    CustomerComment VARCHAR(255) NOT NULL,
    CustomerRating INT CHECK (CustomerRating BETWEEN 1 AND 5),
    Date DATE DEFAULT GETDATE(),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
GO

-- 4. INDEXES
CREATE INDEX idx_AppointmentDateTime ON Appointments(AppointmentDateTime);
CREATE INDEX idx_ProductSalesDate ON ProductSales(SaleDate);

-- 5. SAMPLE DATA
INSERT INTO Customers (FullName, ContactNumber, EmailAddress, POPIAcceptance)
VALUES ('Jane Doe','0712345678','jane@example.com',1),
       ('John Smith','0723456789','john@example.com',1);
       
INSERT INTO Employees (FullName, Role, Certification)
VALUES ('Alice Brown','Stylist',1),
       ('Bob White','Nail Technician',0);

INSERT INTO Services (ServiceName, Category, Price, Duration)
VALUES ('Haircut','Hair',150.00,45),
       ('Manicure','Nails',200.00,60);

INSERT INTO Treatments (ServiceID, TreatmentType, Price, Duration)
VALUES (1,'Basic Haircut',120.00,30),
       (2,'Gel Manicure',180.00,50);

-- 6. VIEWS
CREATE VIEW View_UpcomingAppointments AS
SELECT a.AppointmentID, a.AppointmentDateTime, c.FullName AS Customer, e.FullName AS Employee
FROM Appointments a
JOIN Customers c ON a.CustomerID = c.CustomerID
JOIN Employees e ON a.EmployeeID = e.EmployeeID
WHERE a.AppointmentStatus = 'Scheduled';
GO

CREATE VIEW View_ProductSalesSummary AS
SELECT p.ProductName, SUM(ps.Quantity) AS TotalSold, SUM(ps.AmountPaid) AS Revenue
FROM ProductSales ps
JOIN Products p ON ps.ProductID = p.ProductID
GROUP BY p.ProductName;
GO

-- 7. STORED PROCEDURES
CREATE PROCEDURE sp_BookAppointment
    @CustomerID INT,
    @EmployeeID INT,
    @DateTime DATETIME
AS
BEGIN
    BEGIN TRY
        INSERT INTO Appointments (CustomerID, EmployeeID, AppointmentDateTime, AppointmentStatus)
        VALUES (@CustomerID, @EmployeeID, @DateTime, 'Scheduled');
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE sp_RecordProductSale
    @ProductID INT,
    @CustomerID INT,
    @EmployeeID INT,
    @Quantity INT,
    @AmountPaid DECIMAL(10,2)
AS
BEGIN
    BEGIN TRY
        INSERT INTO ProductSales(ProductID, CustomerID, EmployeeID, Quantity, AmountPaid, SaleDate)
        VALUES (@ProductID, @CustomerID, @EmployeeID, @Quantity, @AmountPaid, GETDATE());
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- 8. TRIGGERS
-- Decrease stock
CREATE TRIGGER trg_DecreaseStockAfterSale
ON ProductSales
AFTER INSERT
AS
BEGIN
    UPDATE p
    SET p.StockQuantity = p.StockQuantity - i.Quantity
    FROM Products p
    JOIN inserted i ON p.ProductID = i.ProductID;
END;
GO

-- Audit/Logging Trigger
CREATE TABLE AuditLog (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    EventTime DATETIME DEFAULT GETDATE(),
    EventType VARCHAR(50),
    TableName VARCHAR(50),
    Description VARCHAR(255)
);

CREATE TRIGGER trg_AuditAppointments
ON Appointments
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @Action VARCHAR(50) = CASE 
        WHEN EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted) THEN 'UPDATE'
        WHEN EXISTS(SELECT * FROM inserted) THEN 'INSERT'
        ELSE 'DELETE' END;

    INSERT INTO AuditLog(EventType, TableName, Description)
    VALUES (@Action, 'Appointments', 'Appointment table changed');
END;
GO

-- 9. BACKUP
BACKUP DATABASE SoyezJolie
TO DISK = 'C:\SQLBackups\SoyezJolie.bak'
WITH FORMAT,
     MEDIANAME = 'SoyezJolieBackup',
     NAME = 'Full Backup of SoyezJolie Database';
GO

CREATE PROCEDURE sp_BookAppointment
    @CustomerID INT,
    @EmployeeID INT,
    @AppointmentDateTime DATETIME
AS
BEGIN
    BEGIN TRY
        IF EXISTS (
            SELECT 1 FROM Appointments
            WHERE EmployeeID = @EmployeeID
            AND AppointmentDateTime = @AppointmentDateTime
        )
        BEGIN
            THROW 50000, 'Employee already booked for this time', 1;
        END
        INSERT INTO Appointments (CustomerID, EmployeeID, AppointmentDateTime, AppointmentStatus)
        VALUES (@CustomerID, @EmployeeID, @AppointmentDateTime, 'Scheduled');
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;

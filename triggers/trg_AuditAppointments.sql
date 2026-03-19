CREATE TABLE Audit_Appointments (
    AuditID INT PRIMARY KEY IDENTITY,
    AppointmentID INT,
    ActionType VARCHAR(50),
    ActionDate DATETIME DEFAULT GETDATE()
);

CREATE TRIGGER trg_AuditAppointments
ON Appointments
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    INSERT INTO Audit_Appointments(AppointmentID, ActionType)
    SELECT AppointmentID, 'INSERT' FROM inserted;
    
    INSERT INTO Audit_Appointments(AppointmentID, ActionType)
    SELECT AppointmentID, 'DELETE' FROM deleted;
END;

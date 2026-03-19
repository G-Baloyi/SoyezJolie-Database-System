SELECT a.AppointmentID,
       c.FullName AS CustomerName,
       e.FullName AS EmployeeName,
       a.AppointmentDateTime
FROM Appointments a
JOIN Customers c ON a.CustomerID = c.CustomerID
JOIN Employees e ON a.EmployeeID = e.EmployeeID
WHERE a.AppointmentStatus = 'Scheduled'
ORDER BY a.AppointmentDateTime;

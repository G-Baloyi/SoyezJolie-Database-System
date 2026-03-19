SELECT e.FullName AS Employee,
       COUNT(a.AppointmentID) AS AppointmentsHandled,
       SUM(asv.AmountPaid) AS TotalRevenue
FROM Employees e
LEFT JOIN Appointments a ON e.EmployeeID = a.EmployeeID
LEFT JOIN AppointmentServices asv ON a.AppointmentID = asv.AppointmentID
GROUP BY e.FullName
ORDER BY TotalRevenue DESC;

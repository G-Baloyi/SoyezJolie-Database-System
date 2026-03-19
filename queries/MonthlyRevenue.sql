SELECT FORMAT(a.AppointmentDateTime,'yyyy-MM') AS Month,
       SUM(asv.AmountPaid) AS Revenue
FROM AppointmentServices asv
JOIN Appointments a ON asv.AppointmentID = a.AppointmentID
GROUP BY FORMAT(a.AppointmentDateTime,'yyyy-MM')
ORDER BY Month;

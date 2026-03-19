# Soyez Jolie Database System

## Project Overview
Soyez Jolie is a boutique salon in Eastgate, Johannesburg, offering hair styling, nail care, beauty treatments, and advanced aesthetics. This project designs and implements a **relational database system** to replace manual operations, improving efficiency in appointment scheduling, payments, product sales, staff management, and customer feedback.

---

## Objectives
- Eliminate manual record-keeping
- Prevent double bookings
- Improve data accuracy and consistency
- Provide business insights through reports

---

## Database Features

### Core Functionality
- Customer and employee management
- Appointment booking system
- Service and treatment tracking
- Product sales and inventory control

---

### Advanced Features
- Stored Procedures (business logic automation)
- Triggers (stock updates, audit logging)
- Views (reporting and summaries)
- Indexes (performance optimization)
- Constraints (data integrity enforcement)

---

### Security
- SQL Server login and user roles
- Role-based access control
- Audit logging system to track changes

---

## Database Structure

Main entities include:
- Customers
- Employees
- Services & Treatments
- Appointments
- Payments
- Products & Sales
- Feedback

---

## Normalization
The database is fully normalized up to **Third Normal Form (3NF)**:
- No repeating groups (1NF)
- No partial dependencies (2NF)
- No transitive dependencies (3NF)

---

## Sample Queries

### Top Customers by Spending
```sql
SELECT TOP 5 FullName, SUM(AmountPaid) AS TotalSpent
FROM Customers
JOIN Appointments USING(CustomerID)
JOIN Payments USING(AppointmentID)
GROUP BY FullName
ORDER BY TotalSpent DESC;

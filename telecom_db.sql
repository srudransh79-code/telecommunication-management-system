-- ============================================================================
-- TELECOMMUNICATION MANAGEMENT SYSTEM
-- DBMS Project - Rudransh Singh (UID: 25BCS10630), B.E. CSE, Section 802-B
-- Database: MySQL (run in MySQL Workbench or mysql CLI)
-- ============================================================================
-- HOW TO RUN:
--   1. Open MySQL Workbench and connect to your local server.
--   2. Open this file and press Execute (or run: mysql -u root -p < telecom_db.sql)
--   3. All tables, sample data and queries run in order.
-- ============================================================================

DROP DATABASE IF EXISTS telecom_db;
CREATE DATABASE telecom_db;
USE telecom_db;

-- ============================================================================
-- SECTION A: DDL - DATA DEFINITION LANGUAGE (CREATE TABLE)
-- ============================================================================

-- 1. CUSTOMER: stores subscriber details
CREATE TABLE Customer (
    customer_id   INT PRIMARY KEY AUTO_INCREMENT,
    first_name    VARCHAR(30) NOT NULL,
    last_name     VARCHAR(30) NOT NULL,
    phone_no      VARCHAR(10) NOT NULL UNIQUE,
    email         VARCHAR(50) UNIQUE,
    address       VARCHAR(100),
    city          VARCHAR(30) NOT NULL,
    state         VARCHAR(30),
    date_of_birth DATE,
    gender        CHAR(1) CHECK (gender IN ('M', 'F', 'O'))
);

-- 2. PLAN: tariff plans offered by the company
CREATE TABLE Plan (
    plan_id       INT PRIMARY KEY AUTO_INCREMENT,
    plan_name     VARCHAR(40) NOT NULL UNIQUE,
    monthly_rent  DECIMAL(8,2) NOT NULL CHECK (monthly_rent > 0),
    data_limit_gb DECIMAL(6,2) NOT NULL,
    talktime_min  INT NOT NULL,
    validity_days INT NOT NULL,
    plan_type     VARCHAR(10) NOT NULL CHECK (plan_type IN ('Prepaid', 'Postpaid'))
);

-- 3. SUBSCRIPTION: links a customer to a plan (many-to-many resolved)
CREATE TABLE Subscription (
    subscription_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id     INT NOT NULL,
    plan_id         INT NOT NULL,
    start_date      DATE NOT NULL,
    end_date        DATE,
    status          VARCHAR(10) NOT NULL DEFAULT 'Active'
                    CHECK (status IN ('Active', 'Inactive', 'Suspended')),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (plan_id)     REFERENCES Plan(plan_id)     ON DELETE RESTRICT
);

-- 4. TOWER: network towers that carry calls
CREATE TABLE Tower (
    tower_id    INT PRIMARY KEY AUTO_INCREMENT,
    location    VARCHAR(50) NOT NULL,
    city        VARCHAR(30) NOT NULL,
    state       VARCHAR(30),
    capacity    INT CHECK (capacity > 0),
    install_date DATE
);

-- 5. CALLRECORD: every call made by a customer
CREATE TABLE CallRecord (
    call_id      INT PRIMARY KEY AUTO_INCREMENT,
    caller_id    INT NOT NULL,
    receiver_no  VARCHAR(10) NOT NULL,
    call_date    DATE NOT NULL,
    duration_sec INT NOT NULL CHECK (duration_sec >= 0),
    call_type    VARCHAR(5) NOT NULL CHECK (call_type IN ('Local', 'STD', 'ISD')),
    tower_id     INT,
    FOREIGN KEY (caller_id) REFERENCES Customer(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (tower_id)  REFERENCES Tower(tower_id)     ON DELETE SET NULL
);

-- 6. BILL: monthly bill generated for a subscription
CREATE TABLE Bill (
    bill_id         INT PRIMARY KEY AUTO_INCREMENT,
    customer_id     INT NOT NULL,
    subscription_id INT NOT NULL,
    bill_month      VARCHAR(7) NOT NULL,
    bill_date       DATE NOT NULL,
    amount          DECIMAL(8,2) NOT NULL CHECK (amount >= 0),
    due_date        DATE NOT NULL,
    payment_status  VARCHAR(10) NOT NULL DEFAULT 'Unpaid'
                    CHECK (payment_status IN ('Paid', 'Unpaid', 'Partial')),
    FOREIGN KEY (customer_id)     REFERENCES Customer(customer_id)     ON DELETE CASCADE,
    FOREIGN KEY (subscription_id) REFERENCES Subscription(subscription_id) ON DELETE CASCADE
);

-- 7. PAYMENT: payments made against bills
CREATE TABLE Payment (
    payment_id   INT PRIMARY KEY AUTO_INCREMENT,
    bill_id      INT NOT NULL,
    payment_date DATE NOT NULL,
    amount_paid  DECIMAL(8,2) NOT NULL CHECK (amount_paid > 0),
    payment_method VARCHAR(12) NOT NULL
                   CHECK (payment_method IN ('UPI', 'Card', 'Cash', 'NetBanking')),
    FOREIGN KEY (bill_id) REFERENCES Bill(bill_id) ON DELETE CASCADE
);

-- 8. EMPLOYEE: company staff who handle customers and complaints
CREATE TABLE Employee (
    emp_id     INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(30) NOT NULL,
    last_name  VARCHAR(30) NOT NULL,
    role       VARCHAR(30) NOT NULL,
    salary     DECIMAL(10,2) NOT NULL CHECK (salary > 0),
    branch_city VARCHAR(30) NOT NULL,
    hire_date  DATE
);

-- 9. COMPLAINT: customer complaints, assigned to an employee
CREATE TABLE Complaint (
    complaint_id   INT PRIMARY KEY AUTO_INCREMENT,
    customer_id    INT NOT NULL,
    assigned_emp_id INT,
    issue_type     VARCHAR(30) NOT NULL,
    description    VARCHAR(200),
    complaint_date DATE NOT NULL,
    status         VARCHAR(10) NOT NULL DEFAULT 'Open'
                   CHECK (status IN ('Open', 'In Progress', 'Resolved', 'Closed')),
    FOREIGN KEY (customer_id)     REFERENCES Customer(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_emp_id) REFERENCES Employee(emp_id)     ON DELETE SET NULL
);

-- ============================================================================
-- SECTION B: DML - DATA MANIPULATION LANGUAGE (INSERT sample data)
-- ============================================================================

INSERT INTO Customer (first_name, last_name, phone_no, email, address, city, state, date_of_birth, gender) VALUES
('Aarav','Sharma','9811111111','aarav.sharma@gmail.com','Sector 17','Chandigarh','Chandigarh','2003-05-14','M'),
('Priya','Verma','9822222222','priya.verma@gmail.com','Model Town','Ludhiana','Punjab','2002-08-21','F'),
('Rohit','Kumar','9833333333','rohit.kumar@gmail.com','Civil Lines','Delhi','Delhi','2001-11-02','M'),
('Sneha','Patel','9844444444','sneha.patel@gmail.com','Satellite','Ahmedabad','Gujarat','2004-01-30','F'),
('Vikram','Singh','9855555555','vikram.singh@gmail.com','Banjara Hills','Hyderabad','Telangana','2000-07-19','M'),
('Ananya','Iyer','9866666666','ananya.iyer@gmail.com','Anna Nagar','Chennai','Tamil Nadu','2003-03-25','F'),
('Karan','Mehta','9877777777','karan.mehta@gmail.com','Andheri West','Mumbai','Maharashtra','2002-09-12','M'),
('Divya','Nair','9888888888','divya.nair@gmail.com','Kakkanad','Kochi','Kerala','2004-06-08','F'),
('Arjun','Gupta','9899999999','arjun.gupta@gmail.com','Gomti Nagar','Lucknow','Uttar Pradesh','2001-12-05','M'),
('Meera','Joshi','9810000000','meera.joshi@gmail.com','FC Road','Pune','Maharashtra','2003-10-17','F');

INSERT INTO Plan (plan_name, monthly_rent, data_limit_gb, talktime_min, validity_days, plan_type) VALUES
('Smart 199', 199.00, 1.5, 100, 28, 'Prepaid'),
('Value 299', 299.00, 2.0, 300, 28, 'Prepaid'),
('Family 599', 599.00, 5.0, 1000, 28, 'Postpaid'),
('Unlimited 799', 799.00, 100.0, 10000, 28, 'Postpaid'),
('Student 149', 149.00, 1.0, 50, 28, 'Prepaid');

INSERT INTO Tower (location, city, state, capacity, install_date) VALUES
('Sector 17 Tower','Chandigarh','Chandigarh',5000,'2020-03-15'),
('Connaught Place Tower','Delhi','Delhi',8000,'2019-07-22'),
('Bandra Tower','Mumbai','Maharashtra',10000,'2021-01-10'),
('Anna Nagar Tower','Chennai','Tamil Nadu',6000,'2020-11-05');

INSERT INTO Subscription (customer_id, plan_id, start_date, end_date, status) VALUES
(1, 2, '2026-01-05', '2026-12-31', 'Active'),
(2, 3, '2026-02-10', '2026-12-31', 'Active'),
(3, 4, '2026-01-15', '2026-12-31', 'Active'),
(4, 1, '2026-03-01', '2026-12-31', 'Active'),
(5, 3, '2026-02-20', '2026-12-31', 'Active'),
(6, 2, '2026-01-25', '2026-06-30', 'Inactive'),
(7, 4, '2026-03-12', '2026-12-31', 'Active'),
(8, 5, '2026-04-01', '2026-12-31', 'Active'),
(9, 2, '2026-02-05', '2026-12-31', 'Suspended'),
(10, 3, '2026-03-18', '2026-12-31', 'Active');

INSERT INTO Employee (first_name, last_name, role, salary, branch_city, hire_date) VALUES
('Rajesh','Khanna','Manager',85000.00,'Delhi','2018-04-01'),
('Sunita','Rao','Customer Support',42000.00,'Mumbai','2020-06-15'),
('Amit','Das','Network Engineer',68000.00,'Chennai','2019-09-10'),
('Neha','Kapoor','Sales Executive',38000.00,'Chandigarh','2021-02-20'),
('Farhan','Ali','Technician',35000.00,'Hyderabad','2022-01-05');

INSERT INTO CallRecord (caller_id, receiver_no, call_date, duration_sec, call_type, tower_id) VALUES
(1,'9822222222','2026-10-01',320,'Local',1),
(1,'9833333333','2026-10-02',1200,'STD',1),
(2,'9811111111','2026-10-01',180,'Local',3),
(3,'9877777777','2026-10-03',2400,'ISD',2),
(3,'9811111111','2026-10-04',95,'Local',2),
(4,'9866666666','2026-10-02',450,'STD',4),
(5,'9899999999','2026-10-05',1800,'STD',3),
(7,'9810000000','2026-10-03',600,'Local',3),
(7,'9822222222','2026-10-06',75,'Local',3),
(8,'9811111111','2026-10-04',900,'STD',4),
(9,'9833333333','2026-10-05',210,'Local',2),
(10,'9877777777','2026-10-06',1500,'ISD',3);

INSERT INTO Bill (customer_id, subscription_id, bill_month, bill_date, amount, due_date, payment_status) VALUES
(1, 1, '2026-10', '2026-10-05', 299.00, '2026-10-20', 'Paid'),
(2, 2, '2026-10', '2026-10-05', 599.00, '2026-10-20', 'Paid'),
(3, 3, '2026-10', '2026-10-05', 799.00, '2026-10-20', 'Unpaid'),
(4, 4, '2026-10', '2026-10-05', 199.00, '2026-10-20', 'Paid'),
(5, 5, '2026-10', '2026-10-05', 599.00, '2026-10-20', 'Unpaid'),
(7, 7, '2026-10', '2026-10-05', 799.00, '2026-10-20', 'Partial'),
(8, 8, '2026-10', '2026-10-05', 149.00, '2026-10-20', 'Paid'),
(10, 10, '2026-10', '2026-10-05', 599.00, '2026-10-20', 'Unpaid');

INSERT INTO Payment (bill_id, payment_date, amount_paid, payment_method) VALUES
(1, '2026-10-08', 299.00, 'UPI'),
(2, '2026-10-09', 599.00, 'Card'),
(4, '2026-10-07', 199.00, 'UPI'),
(6, '2026-10-10', 400.00, 'NetBanking'),
(7, '2026-10-06', 149.00, 'Cash'),
(1, '2026-10-12', 50.00, 'UPI');

INSERT INTO Complaint (customer_id, assigned_emp_id, issue_type, description, complaint_date, status) VALUES
(3, 3, 'Network', 'Call drops frequently in my area', '2026-10-03', 'In Progress'),
(5, 2, 'Billing', 'Charged extra on last bill', '2026-10-04', 'Open'),
(9, 2, 'Network', 'No signal since yesterday', '2026-10-06', 'Open'),
(1, 5, 'SIM', 'SIM card not detected', '2026-10-02', 'Resolved'),
(7, 3, 'Data', 'Internet speed very slow', '2026-10-05', 'In Progress');

-- DML: UPDATE example - activate a suspended subscription
UPDATE Subscription SET status = 'Active' WHERE subscription_id = 9;

-- DML: DELETE example - remove a resolved complaint.
-- (Kept commented in the script so the sample data stays complete for the
--  20 queries below. To demo it, uncomment both lines: the DELETE removes
--  complaint 4, and the INSERT puts the same complaint back, so the queries
--  that follow are unaffected.)
-- DELETE FROM Complaint WHERE complaint_id = 4 AND status = 'Resolved';
-- INSERT INTO Complaint (customer_id, assigned_emp_id, issue_type, description, complaint_date, status) VALUES (1, 5, 'SIM', 'SIM card not detected', '2026-10-02', 'Resolved');

-- ============================================================================
-- SECTION C: TCL - TRANSACTION CONTROL LANGUAGE
-- ============================================================================
-- A payment must update the Bill and insert a Payment together, or neither.
START TRANSACTION;
INSERT INTO Payment (bill_id, payment_date, amount_paid, payment_method)
VALUES (3, '2026-10-15', 799.00, 'UPI');
SAVEPOINT after_payment;
UPDATE Bill SET payment_status = 'Paid' WHERE bill_id = 3;
-- If anything above failed, we would run: ROLLBACK TO SAVEPOINT after_payment;
COMMIT;

-- ============================================================================
-- SECTION D: DCL - DATA CONTROL LANGUAGE (MySQL only; run as admin/root)
-- ============================================================================
-- CREATE USER 'telecom_staff'@'localhost' IDENTIFIED BY 'staff123';
-- GRANT SELECT, INSERT, UPDATE ON telecom_db.* TO 'telecom_staff'@'localhost';
-- REVOKE DELETE ON telecom_db.* FROM 'telecom_staff'@'localhost';
-- (Commented out so the script runs without admin rights; uncomment to demo DCL.)

-- ============================================================================
-- SECTION E: 20 SQL QUERIES WITH EXPLANATIONS
-- ============================================================================

-- Q1. List all customers (name, phone, city).
SELECT first_name, last_name, phone_no, city FROM Customer;

-- Q2. Customers who live in Mumbai (WHERE filter).
SELECT first_name, last_name, phone_no FROM Customer WHERE city = 'Mumbai';

-- Q3. Plans sorted by monthly rent, cheapest first (ORDER BY).
SELECT plan_name, monthly_rent, plan_type FROM Plan ORDER BY monthly_rent ASC;

-- Q4. Number of customers in each city (GROUP BY + COUNT).
SELECT city, COUNT(*) AS num_customers FROM Customer GROUP BY city;

-- Q5. Total revenue from all bills (SUM aggregate).
SELECT SUM(amount) AS total_billed FROM Bill;

-- Q6. Average call duration in seconds (AVG aggregate).
SELECT AVG(duration_sec) AS avg_call_seconds FROM CallRecord;

-- Q7. Each customer with their plan name (INNER JOIN across 3 tables).
SELECT c.first_name, c.last_name, p.plan_name, s.status
FROM Customer c
JOIN Subscription s ON c.customer_id = s.customer_id
JOIN Plan p ON s.plan_id = p.plan_id;

-- Q8. Customers with unpaid bills (JOIN + WHERE).
SELECT c.first_name, c.last_name, b.amount, b.due_date
FROM Customer c
JOIN Bill b ON c.customer_id = b.customer_id
WHERE b.payment_status = 'Unpaid';

-- Q9. Top 5 longest calls (ORDER BY + LIMIT).
SELECT caller_id, receiver_no, duration_sec, call_type
FROM CallRecord ORDER BY duration_sec DESC LIMIT 5;

-- Q10. Customers whose plan costs more than the average plan rent (subquery).
SELECT first_name, last_name FROM Customer
WHERE customer_id IN (
    SELECT customer_id FROM Subscription WHERE plan_id IN (
        SELECT plan_id FROM Plan WHERE monthly_rent > (SELECT AVG(monthly_rent) FROM Plan)
    )
);

-- Q11. Calls longer than the average call duration (subquery in WHERE).
SELECT call_id, caller_id, duration_sec, call_type FROM CallRecord
WHERE duration_sec > (SELECT AVG(duration_sec) FROM CallRecord);

-- Q12. Total amount collected per payment method (GROUP BY + SUM).
SELECT payment_method, SUM(amount_paid) AS total_collected
FROM Payment GROUP BY payment_method;

-- Q13. Customers who never raised a complaint (NOT IN subquery).
SELECT first_name, last_name FROM Customer
WHERE customer_id NOT IN (SELECT customer_id FROM Complaint);

-- Q14. Employees earning more than the average salary (subquery).
SELECT first_name, last_name, role, salary FROM Employee
WHERE salary > (SELECT AVG(salary) FROM Employee);

-- Q15. Total billed amount per month (GROUP BY).
SELECT bill_month, SUM(amount) AS month_total FROM Bill GROUP BY bill_month;

-- Q16. Customers who made more than 1 call (GROUP BY + HAVING).
SELECT caller_id, COUNT(*) AS num_calls FROM CallRecord
GROUP BY caller_id HAVING COUNT(*) > 1;

-- Q17. The plan with the most subscribers (JOIN + GROUP BY + ORDER BY + LIMIT).
SELECT p.plan_name, COUNT(*) AS subscribers
FROM Plan p JOIN Subscription s ON p.plan_id = s.plan_id
GROUP BY p.plan_name ORDER BY subscribers DESC LIMIT 1;

-- Q18. Call details with the tower location (JOIN across 3 tables).
SELECT cr.call_id, c.first_name AS caller, cr.receiver_no, cr.duration_sec,
       t.location AS tower_location, t.city AS tower_city
FROM CallRecord cr
JOIN Customer c ON cr.caller_id = c.customer_id
JOIN Tower t ON cr.tower_id = t.tower_id;

-- Q19. Open complaints with customer name and assigned employee (JOIN + WHERE).
SELECT co.complaint_id, c.first_name AS customer, co.issue_type, co.status,
       e.first_name AS assigned_to
FROM Complaint co
JOIN Customer c ON co.customer_id = c.customer_id
LEFT JOIN Employee e ON co.assigned_emp_id = e.emp_id
WHERE co.status = 'Open';

-- Q20. Total call minutes per customer (aggregate with JOIN).
SELECT c.first_name, c.last_name, ROUND(SUM(cr.duration_sec)/60.0, 2) AS total_minutes
FROM Customer c
JOIN CallRecord cr ON c.customer_id = cr.caller_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_minutes DESC;

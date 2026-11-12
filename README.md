# Telecommunication Management System — DBMS Project

A complete MySQL database for a telecom company: customers, tariff plans,
subscriptions, network towers, call records, monthly bills, payments,
employees and complaints.

**Student:** Rudransh Singh (UID: 25BCS10630), B.E. Computer Science &
Engineering, Section 802-B, Chandigarh University

## Files

| File | What it is |
|------|-----------|
| `telecom_db.sql` | Complete executable MySQL script — DDL, DML, TCL, DCL and 20 queries |
| `er_diagram.png` | Entity–relationship diagram |
| `Telecom_DBMS_Project_Rudransh_Singh_25BCS10630.pdf` | Full project report (19 pages, teacher's 16-point index) |

## Database

9 tables, normalized to 3NF: Customer, Plan, Subscription, Tower,
CallRecord, Bill, Payment, Employee, Complaint.

Sample data: 10 customers, 5 plans, 4 towers, 10 subscriptions,
5 employees, 12 call records, 8 bills, 7 payments, 5 complaints.

## How to run (MySQL Workbench)

1. Install MySQL Server 8.0+ and MySQL Workbench.
2. Open `telecom_db.sql` in Workbench and connect to your local server.
3. Press Execute (the lightning icon) to run the whole script.
4. The script drops and recreates the `telecom_db` database, so it is
   safe to run again — it always starts from a clean database.
5. The 20 queries at the end run in order; check their result grids
   against Section 11 of the report.

Notes:

- The DCL statements (CREATE USER / GRANT / REVOKE) are commented out
  because they need admin (root) rights — uncomment them to demo DCL.
- The DELETE example is commented out so the sample data stays complete
  for the queries; a matching re-INSERT is given beside it so you can
  demo the delete safely by uncommenting both lines.

## What the script covers

- **DDL** — 9 CREATE TABLE statements with PRIMARY KEY, FOREIGN KEY,
  UNIQUE, NOT NULL, CHECK and DEFAULT constraints
- **DML** — INSERT sample data, an UPDATE and a DELETE example
- **TCL** — a payment transaction (START TRANSACTION, SAVEPOINT, COMMIT)
- **DCL** — GRANT / REVOKE for a staff user
- **DQL** — 20 queries with joins, subqueries, GROUP BY, HAVING and
  aggregate functions (COUNT, SUM, AVG), with real outputs in the report

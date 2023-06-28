# Lab | SQL Rolling calculations

-- In this lab, you will be using the [Sakila](https://dev.mysql.com/doc/sakila/en/) database of movie rentals.

USE sakila;

### Instructions

-- 1. Get number of monthly active customers.

SELECT * FROM rental;

create or replace view Customer_activity as
select 
date_format(convert(rental_date, date), '%m') as month,
date_format(convert(rental_date, date), '%Y') as year,
COUNT(customer_id) AS Customers 
from sakila.rental
GROUP BY month, year
ORDER BY year, month;

SELECT * FROM Customer_activity;

-- 2. Active users in the previous month.


WITH cte_activity AS (
  SELECT Customers, LAG(Customers, 1) OVER (PARTITION BY year ORDER BY month) AS last_month, year, month
  FROM Customer_activity
)
SELECT year, month, Customers, last_month
FROM cte_activity;

-- 3. Percentage change in the number of active customers.

WITH cte_activity AS (
  SELECT Customers, LAG(Customers, 1) OVER (PARTITION BY year ORDER BY month) AS last_month, year, month
  FROM Customer_activity
)
SELECT year, month, Customers, last_month, ROUND((((Customers / last_month) -  1)*100), 2) AS percen
FROM cte_activity;

-- 4. Retained customers every month.

WITH cte_activity AS (
  SELECT
    year,
    month,
    Customers,
    LAG(Customers) OVER (ORDER BY year, month) AS last_month_customers
  FROM
    Customer_activity
)
SELECT
  year,
  month,
  Customers,
  Customers - COALESCE(last_month_customers, 0) AS retained_customers
FROM
  cte_activity;

create or replace view Customer_activity2 as
select 
date_format(convert(rental_date, date), '%m') as month,
date_format(convert(rental_date, date), '%Y') as year,
COUNT(DISTINCT(customer_id)) AS Customers 
from sakila.rental
GROUP BY month, year
ORDER BY year, month;

SELECT * FROM Customer_activity2;

WITH cte_activity2 AS (
  SELECT Customers, LAG(Customers, 1) OVER (PARTITION BY year ORDER BY month) AS last_month, year, month
  FROM Customer_activity2
)
SELECT year, month, Customers, last_month, (Customers - last_month) AS difer
FROM cte_activity2;

-- Me gustaría saber como sustituir los NULL por 0



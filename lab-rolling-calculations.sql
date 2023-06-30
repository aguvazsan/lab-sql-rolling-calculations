# Lab | SQL Rolling calculations

-- In this lab, you will be using the [Sakila](https://dev.mysql.com/doc/sakila/en/) database of movie rentals.

USE sakila;

### Instructions


create or replace view Customer_activit as
select 
DISTINCT(customer_id) AS Active_Customers 
from sakila.rental;

SELECT * FROM Customer_activit;


-- 1. Get number of monthly active customers.

SELECT * FROM rental;

create or replace view Customer_activity as
select 
date_format(convert(rental_date, date), '%m') as month,
date_format(convert(rental_date, date), '%Y') as year,
COUNT(DISTINCT(customer_id)) AS Active_Customers 
from sakila.rental
GROUP BY month, year
ORDER BY year, month;

SELECT * FROM Customer_activity;

-- 2. Active users in the previous month.


WITH cte_activity AS (
  SELECT Active_Customers, LAG(Active_Customers, 1) OVER (PARTITION BY year ORDER BY month) AS last_month, year, month
  FROM Customer_activity
)
SELECT year, month, Active_Customers, last_month
FROM cte_activity;

-- 3. Percentage change in the number of active customers.

WITH cte_activity AS (
  SELECT Active_Customers, LAG(Active_Customers, 1) OVER (PARTITION BY year ORDER BY month) AS last_month, year, month
  FROM Customer_activity
)
SELECT year, month, Active_Customers, last_month, ROUND((((Active_Customers / last_month) -  1)*100), 2) AS percen
FROM cte_activity;

-- 4. Retained customers every month.

CREATE OR REPLACE VIEW Customer_retained AS
SELECT 
    DATE_FORMAT(CONVERT(r1.rental_date, DATE), '%m') AS Activity_month_number,
    DATE_FORMAT(CONVERT(r1.rental_date, DATE), '%Y') AS Activity_year,
    COUNT(DISTINCT r1.customer_id) AS Active_Customers 
FROM 
    sakila.rental AS r1
JOIN 
    sakila.rental AS r2 ON r1.customer_id = r2.customer_id 
    AND MONTH(r2.rental_date) = MONTH(r1.rental_date) + 1 
GROUP BY 
    Activity_year, Activity_month_number
ORDER BY 
    Activity_year, Activity_month_number;
    
SELECT * FROM customer_retained;

-- ----------------------------------------------------------------------------------------------------------

SELECT 
    DATE_FORMAT(CONVERT(rental_date, DATE), '%m') AS Activity_month_number,
    DATE_FORMAT(CONVERT(rental_date, DATE), '%Y') AS Activity_year,
    COUNT(customer_id) AS Active_Customers 
FROM 
    sakila.rental
GROUP BY Activity_year, Activity_month_number
ORDER BY Activity_year, Activity_month_number;


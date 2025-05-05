-- Monday Coffee -- Data Analysis 

SELECT * FROM city
SELECT * FROM customers
SELECT * FROM products
SELECT * FROM sales

-- Reports & Data Analysis--

-- Q.1 Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?

SELECT 
  city_name, 
  population * 0.25, 
  city_rank 
from city
ORDER BY population desc

-- Q.2 Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

SELECT SUM(total) AS total_revenue
FROM sales
WHERE 
    DATEPART(QUARTER, sale_date) = 4
    AND DATEPART(YEAR, sale_date) = 2023;

-- Q.3 Sales Count for Each Product
-- How many units of each coffee product have been sold?

SELECT 
    p.product_name,
    COUNT(s.sale_id) AS total_orders
FROM products AS p
LEFT JOIN sales AS s
ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_orders;

-- Q.4 Average Sales Amount per City
-- What is the average sales amount per customer in each city?

-- city abd total sale
-- no cx in each these city

SELECT 
    ci.city_name,
    SUM(s.total) AS total_revenue,
    COUNT(DISTINCT s.customer_id) AS total_cx,
    ROUND(
        CAST(SUM(s.total) AS FLOAT) / CAST(COUNT(DISTINCT s.customer_id) AS FLOAT),
    2) AS avg_sale_pr_cx
FROM sales AS s
JOIN customers AS c ON s.customer_id = c.customer_id
JOIN city AS ci ON ci.city_id = c.city_id
GROUP BY ci.city_name
ORDER BY total_revenue DESC;

-- Q5 Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?

SELECT *
FROM (
    SELECT 
        ci.city_name,
        p.product_name,
        COUNT(s.sale_id) AS total_orders,
        DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) DESC) AS rnk
    FROM sales AS s
    JOIN products AS p ON s.product_id = p.product_id
    JOIN customers AS c ON c.customer_id = s.customer_id
    JOIN city AS ci ON ci.city_id = c.city_id
    GROUP BY ci.city_name, p.product_name
) AS t1
WHERE rnk <= 3;

-- Q.6 Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?

SELECT 
    ci.city_name,
    COUNT(DISTINCT c.customer_id) AS unique_cx
FROM city AS ci
JOIN customers AS c ON ci.city_id = c.city_id
JOIN sales AS s ON s.customer_id = c.customer_id
JOIN products AS p ON p.product_id = s.product_id
WHERE p.product_name LIKE '%coffee%'
GROUP BY ci.city_name;

-- Q.7 City Population and Coffee Consumers (25%)
-- Provide a list of cities along with their populations and estimated coffee consumers.
-- return city_name, total current cx, estimated coffee consumers (25%)

WITH city_table AS (
    SELECT 
        city_name, 
        ROUND((population * 0.25) / 1000000, 2) AS coffee_consumers
    FROM city
), 
customers_table AS (
    SELECT 
        ci.city_name, 
        COUNT(DISTINCT c.customer_id) AS unique_cx
    FROM sales AS s
    JOIN customers AS c ON c.customer_id = s.customer_id
    JOIN city AS ci ON ci.city_id = c.city_id
    GROUP BY ci.city_name
)
SELECT 
    customers_table.city_name, 
    city_table.coffee_consumers AS coffee_consumer_in_millions, 
    customers_table.unique_cx
FROM city_table
JOIN customers_table 
ON city_table.city_name = customers_table.city_name;

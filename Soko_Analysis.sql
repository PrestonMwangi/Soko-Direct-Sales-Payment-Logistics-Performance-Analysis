-- Create table to load data to
CREATE TABLE orders (
	 order_id         INT,
    order_date       DATE,
    customer_id      INT,
    product_category TEXT,
    region           TEXT,
    quantity         INT,
    unit_price       NUMERIC(12,2),
    discount         NUMERIC,
    payment_method   TEXT,
    delivery_days    NUMERIC,
    customer_rating  NUMERIC(3,1),
    revenue          NUMERIC(14,2),
    order_status     TEXT
);


-- DATA PREVIEW
SELECT DISTINCT order_status FROM orders;
SELECT DISTINCT payment_method FROM orders;
SELECT DISTINCT region FROM orders;
SELECT * FROM orders;

-- Summary preview
SELECT
    COUNT(*) AS orders,
    COUNT(DISTINCT order_id) AS unique_orders,
    MIN(order_date) AS first_date,
    MAX(order_date) AS last_date,
    MIN(customer_rating) AS min_rating,
    MAX(customer_rating) AS max_rating,
    MIN(quantity) AS min_qty,
    MAX(discount) AS max_discount,
    COUNT(*) FILTER (WHERE customer_rating IS NULL) AS blank_ratings
FROM orders;




-- ANALYSIS

-- Net Revenue
SELECT SUM(revenue)
FROM orders
WHERE order_status NOT IN ('Cancelled', 'Returned');

-- 1. GROWTH BY REGION
SELECT region, rev_2023, rev_2024,
		ROUND((100 * (rev_2024 - rev_2023) / rev_2023),2) AS growth_pct
FROM (
		SELECT region,
				SUM(revenue) FILTER (WHERE EXTRACT(YEAR FROM order_date) = 2023) AS rev_2023,
				SUM(revenue) FILTER (WHERE EXTRACT (YEAR FROM order_date) = 2024) AS rev_2024
		FROM orders
		WHERE order_status NOT IN ('Cancelled', 'Returned')
		GROUP BY region
		) AS yearly
ORDER BY growth_pct DESC;

-- 2. GROWTH BY CATEGORY
SELECT product_category, prod_rev_2023, prod_rev_2024,
		(ROUND(100 * (prod_rev_2024 - prod_rev_2023) / prod_rev_2023), 2) AS growth_pct
FROM (
		SELECT product_category,
			SUM(revenue) FILTER (WHERE EXTRACT (YEAR FROM order_date) = 2023) AS prod_rev_2023,
			SUM(revenue) FILTER (WHERE EXTRACT (YEAR FROM order_date) = 2024) AS prod_rev_2024
		FROM orders
		WHERE order_status NOT IN ('Cancelled', 'Returned')
		GROUP BY product_category
		) AS yearly
ORDER BY growth_pct DESC;

-- 2.2 GROWTH BY PAYMENT METHOD
SELECT payment_method, pay_2023, pay_2024,
		(ROUND(100 * (pay_2024 - pay_2023) / pay_2023), 2) AS growth_pct
FROM (
		SELECT payment_method,
			SUM(revenue) FILTER (WHERE EXTRACT (YEAR FROM order_date) = 2023) AS pay_2023,
			SUM(revenue) FILTER (WHERE EXTRACT (YEAR FROM order_date) = 2024) AS pay_2024
		FROM orders
		WHERE order_status NOT IN ('Cancelled', 'Returned')
		GROUP BY payment_method
) AS yearly
ORDER BY growth_pct DESC;

-- 3. ORDERS PER REGION PER YEAR
SELECT region, 
	EXTRACT(YEAR FROM order_date) AS order_year,
	COUNT(*) AS orders
FROM orders
WHERE order_status NOT IN ('Cancelled', 'Returned')
GROUP BY region, order_year
ORDER BY region, order_year; 

-- 4. AVERAGE ORDERS PER CUSTOMER 
SELECT 
		ROUND(AVG(valid_orders), 2) AS repeat_pct
FROM (SELECT customer_id, COUNT(*) AS valid_orders 
		FROM orders 
		WHERE order_status NOT IN ('Cancelled', 'Returned')
		GROUP BY customer_id) AS per_customer;

-- 5: Orders per customer by region
SELECT region,  COUNT(*) AS orders, COUNT(DISTINCT customer_id) AS customers,
		ROUND(1.0 * COUNT(*) / COUNT(DISTINCT customer_id), 2) AS orders_per_customer
FROM orders
GROUP BY region
ORDER BY orders_per_customer DESC;

-- 6.REPEAT CUSTOMER RATE PER REGION
WITH per_customer AS (
	SELECT region, customer_id, COUNT(*) as n
	FROM orders
	GROUP BY region, customer_id
)
SELECT region, COUNT(*) as customers,
COUNT(*) FILTER (WHERE n>=2) AS repeat_customers,
ROUND(100 * COUNT(*) FILTER (WHERE n>=2) / COUNT(*), 2) AS repeat_pct
FROM per_customer
GROUP BY region
ORDER BY repeat_pct DESC; 

-- 7. RATING BY DELIVERY SPEED
SELECT CASE WHEN delivery_days <= 3 THEN 'Fast (1-3 days)'
		 	WHEN delivery_days <= 7 THEN 'Medium (4-6 days)'
			ELSE 'Slow (7-10 days)' 
		END AS speed,
		COUNT(*) AS orders,
		ROUND(AVG(customer_rating),2) AS avg_rating
FROM orders
WHERE delivery_days IS NOT NULL AND customer_rating IS NOT NULL
GROUP BY speed
ORDER BY speed;

-- 8. LOST ORDER RATE BY PAYMENT METHOD
WITH order_counts AS (
	SELECT payment_method,
		COUNT(*) AS orders,
		COUNT(*) FILTER (WHERE order_status IN ('Cancelled', 'Returned')) AS lost_orders
	FROM orders
	GROUP BY payment_method
)
SELECT payment_method, orders, lost_orders,
(100 * lost_orders / orders) AS lost_orders_pct
FROM order_counts
ORDER BY lost_orders_pct DESC;

-- 9. VALUE OF LOST ORDERS BY CATEGORY
SELECT product_category,
		SUM(revenue) FILTER (WHERE order_status IN ('Cancelled', 'Returned')) AS lost_revenue,
		ROUND(100 * SUM(revenue) FILTER (WHERE order_status IN ('Cancelled', 'Returned')) / SUM(revenue), 1) AS lost_pct_of_revenue
FROM orders
GROUP BY product_category
ORDER BY lost_revenue DESC;

-- 9. DISCOUNT COMPARISON
SELECT CASE 
		WHEN discount <=0 THEN 'No discount'
		WHEN discount <=0.10 THEN 'Upto 10%'
		WHEN discount <= 0.20 THEN 'Upto 20%'
		ELSE 'Over 20%' END AS discount_band,
		COUNT(*) AS orders,
		ROUND(AVG(quantity), 2) AS avg_quantity,
		ROUND(100 * COUNT(*) FILTER (WHERE order_status IN ('Cancelled', 'Returned')) / COUNT(*), 2) AS lost_pct
FROM orders
GROUP BY discount_band
ORDER BY discount_band ;

























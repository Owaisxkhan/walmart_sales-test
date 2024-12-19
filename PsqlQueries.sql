select * from walmart;

-- Business Problems
-- Q1. Find different payment method and number of transactions, number of qty sold

SELECT 
		payment_method,
		count(*),
		sum(quantity) as no_of_quantity
FROM walmart
GROUP BY payment_method

-- Q2. Identify the highest-rated category in each branch, displaying the branch, category and AVG RATING


SELECT * FROM
(
SELECT 
		branch, 
		category,
		avg(rating) as avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rank
FROM walmart
GROUP BY branch,category
)
WHERE rank = 1;

-- Q3. Identify the busiest day for each branch based on the number of transactions


SELECT 
		date, 
		TO_DATE(date, 'DD/MM/YY') as formated_date
FROM walmart;

SELECT * FROM
(
SELECT 
		branch,
		TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') as day_name,
		count(*) as no_of_transactions,
		RANK() OVER( PARTITION BY branch ORDER BY COUNT(*) DESC ) as rank
FROM walmart
GROUP BY branch, day_name
)
WHERE rank = 1;

-- Q4. Calculate the total quantity of items sold per payment method, list payment_method and total_quantity.

SELECT 
		payment_method,
		sum(quantity) as total_quantity
FROM walmart
GROUP BY payment_method

-- Q5. Determine the average, minimum, and maximum rating of products for each city.
-- List the city, average_rating, min_ratig and max_rating

SELECT 
		city,
		category,
		AVG(rating) as average_rating,
		MIN(rating) as min_rating,
		MAX(rating) as max_rating
FROM walmart
GROUP BY city, category;

-- Q6. Calculate the total profit for each category by consideing total_profit as
-- (unit_price * quantity * profit_margin).
-- List category and total_profit, ordered from highest to lowest profits.

SELECT 
		category,
		SUM(total) as total_revenue,
		SUM(total * profit_margin) as total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;

-- Q7. Determine the most common payment method for each branch, Display Branch and the preferred_payment_method.


SELECT * FROM
(
SELECT 
		branch,
		payment_method,
		count(*) as total_transactions,
		RANK() OVER( PARTITION BY branch ORDER BY count(*) DESC) as rank
FROM walmart
GROUP BY branch ,payment_method
)
WHERE rank = 1

-- Q8. Categorize sales into 3 group MORNING, AFTERNOON, EVENING
-- Find out which of the shift and number of invoices

SELECT 
		branch,
		CASE 
			WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'Morning'
			WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN  12 AND 17 THEN 'Afternoon'
			ELSE 'Evening'
		END day_time,
		COUNT(*)
FROM walmart
GROUP BY 1,2
ORDER BY 1,3 desc

-- Q9. Identify 5 branch with the highest decrease ratio in revenue compare to last year(Current_year 2023 and last year 2022)

rdr = last_yr_revnue - curr_year_revnue/ last_yr_revnue *100

WITH revenue_2022 AS
(
SELECT
		branch,
		sum(total) as revenue
FROM walmart
WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
GROUP BY 1
),
revenue_2023 AS
(
SELECT
		branch,
		sum(total) as revenue
FROM walmart
WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023 -- PSQL
-- WHERE YEAR(TO_DATE(date, 'DD/MM/YY')) = 2023 MYSQL
GROUP BY 1
)
SELECT 
		ls.branch,
		ls.revenue as last_year_revenue,
		cs.revenue as current_year_revenue,
		ROUND((ls.revenue - cs.revenue)::numeric/ ls.revenue::numeric*100,2) as rev_decrease_ratio
FROM revenue_2022 AS ls
JOIN 
	revenue_2023 AS cs
	ON ls.branch = cs.branch
WHERE 	
		ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5

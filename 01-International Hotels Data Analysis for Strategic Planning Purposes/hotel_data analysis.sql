-- Combine data from three tables (2018, 2019, 2020) and join it with 'market_segment' & 'meal_cost' tables
CREATE VIEW all_years AS
WITH all_years AS (
SELECT * FROM [2018]
UNION
SELECT * FROM [2019]
UNION
SELECT * FROM [2020]
)

SELECT
	ay.*,
	CAST((ay.stays_in_weekend_nights + ay.stays_in_week_nights) * adr * (1 - ms.Discount) as decimal(10,2)) AS Revenue,
	ms.Discount,
    mc.cost
FROM 
	all_years ay
LEFT JOIN market_segment ms
ON ay.market_segment = ms.market_segment
LEFT JOIN meal_cost mc
ON ay.meal = mc.meal;

--SELECT * FROM all_years;

----------------------------------------------------------------------------------------------------------------------------------------------------
-- Q1:Total Revenue per year, broken down by hotel type

SELECT 
	hotel,
	arrival_date_year, 
	SUM(Revenue) AS [Actual Revenue (Excl. Cancellations)]
FROM
	all_years
WHERE is_canceled <> 1
GROUP BY ROLLUP(hotel, arrival_date_year);


----------------------------------------------------------------------------------------------------------------------------------------------------
-- Q2: What is the profit percentage for each month across all years?

SELECT 
	arrival_date_year, 
	arrival_date_month,
	SUM(Revenue) AS profit
FROM
	all_years
WHERE is_canceled <> 1
GROUP BY arrival_date_year, arrival_date_month
ORDER BY arrival_date_year, profit DESC;

----------------------------------------------------------------------------------------------------------------------------------------------------
-- Q3: Which meals and market segments (e.g., families, corporate clients, etc.) contribute the most to the total revenue for each hotel annually?

SELECT
	hotel,
	meal, 
	ROUND(SUM(cost),2) AS cost
FROM 
	all_years
where meal <> 'Undefined'
GROUP BY hotel, meal
ORDER BY hotel, cost DESC;
----------------------------------------------------------------------------------------------------------------------------------------------------
-- Q4: How does revenue compare between public holidays and regular days each year?

SELECT 
	hotel, 
	ROUND( SUM(stays_in_weekend_nights * adr * (1 - Discount)),2) AS [total revenue in holidays],
	ROUND( SUM(stays_in_week_nights * adr * (1 - Discount)),2) AS [total revenue in regular days]
FROM
	all_years
WHERE is_canceled <> 1 
GROUP BY hotel;

----------------------------------------------------------------------------------------------------------------------------------------------------
-- Q5: What are the key factors (e.g., hotel type, market type, meals offered, number of nights booked) significantly impact hotel revenue annually?
----------------------------------------------------------------------------------------------------------------------------------------------------
-- Q6: Based on stay data, what are the yearly trends in customer preferences for room types (e.g., family rooms vs. single rooms), and how do these preferences influence revenue?

SELECT 
	arrival_date_year,
	reserved_room_type,
	COUNT (*) AS total,
	SUM(Revenue) AS [sum of revenue]
FROM
	all_years
GROUP BY arrival_date_year, reserved_room_type
ORDER BY arrival_date_year, total DESC;

----------------------------------------------------------------------------------------------------------------------------------------------------
--Q7:what is the potential unrealized gains from canceled reservations?

SELECT 
	hotel,
	arrival_date_year, 
	SUM(Revenue) AS [Potential Gains From Cancelled Reservations]
FROM
	all_years
WHERE is_canceled = 1
GROUP BY ROLLUP(hotel, arrival_date_year);

----------------------------------------------------------------------------------------------------------------------------------------------------
--Q8:what is the Total No. of Nights Reserved for each hotel type across all years?

SELECT 
	arrival_date_year,
	hotel, 
	SUM(stays_in_weekend_nights + stays_in_week_nights) [Total No. of Nights Reserved]
FROM
	all_years
--WHERE is_canceled <> 1
GROUP BY ROLLUP(arrival_date_year, hotel)
ORDER BY arrival_date_year;
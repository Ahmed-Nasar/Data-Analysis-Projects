-------------------------------------------------------------------------------------------------------------------
--Explore the items table.
-------------------------------------------------------------------------------------------------------------------

--View the menu_items table.
SELECT *
FROM [restaurant_db].[dbo].[menu_items]
-------------------------------------------------------------------------------------------------------------------
--write a query to find the number of items on the menu.
SELECT COUNT(*) AS Num_Items
FROM menu_items;

-------------------------------------------------------------------------------------------------------------------
--What are the least and most expensive items on the menu?
/*SELECT TOP 1 *
FROM menu_items
ORDER BY price;

SELECT TOP 1 *
FROM menu_items
ORDER BY price DESC;*/

WITH Sort_by_price AS
(
	SELECT *, DENSE_RANK() OVER(ORDER BY price) RN
	FROM menu_items
)
SELECT 
	item_name, 
	category, 
	price
FROM Sort_by_price
WHERE RN IN(1,(SELECT MAX(RN) FROM Sort_by_price));

-------------------------------------------------------------------------------------------------------------------
--How many Italian dishes are on the menu? What are the least and most expensive Italian dishes on the menu?
SELECT 
	COUNT(*) AS Num_Italian_Dishes,
	MIN(price) AS [least expensive Italian dish],
	MAX(price) AS [most expensive Italian dish]
FROM menu_items
WHERE category = 'Italian';

-------------------------------------------------------------------------------------------------------------------
--How many dishes are in each category? What is the average dish price within each category?
SELECT 
	category,
	COUNT(*) AS Num_Dishes,
	CAST(AVG(price) AS decimal(10,2)) AS [AVG dish Price]
FROM menu_items
GROUP BY category;



-------------------------------------------------------------------------------------------------------------------
--Explore the orders table.
-------------------------------------------------------------------------------------------------------------------

--View the order_details table. 
SELECT *
FROM [restaurant_db].[dbo].[order_details]

-------------------------------------------------------------------------------------------------------------------
--What is the date range of the table?
SELECT 
	MIN(order_date) MIN_DATE,
	MAX(order_date) MAX_DATE
FROM order_details;

-------------------------------------------------------------------------------------------------------------------
--How many orders were made within this date range? How many items were ordered within this date range?
SELECT	
	COUNT(DISTINCT order_id) AS Num_orders,
	COUNT(*) AS Num_items
FROM order_details;

-------------------------------------------------------------------------------------------------------------------
--Which orders had the most number of items?
SELECT	
	TOP 1 WITH TIES order_id,
	COUNT(*) AS Num_items
FROM order_details
GROUP BY order_id
ORDER BY  Num_items DESC;

-------------------------------------------------------------------------------------------------------------------
--How many orders had more than 12 items?
SELECT COUNT(*) AS [Num_orders > 12 items]
FROM(
	SELECT	
		order_id,
		COUNT(item_id) AS Num_items
	FROM order_details
	GROUP BY order_id
) NewTable
WHERE Num_items > 12;



-------------------------------------------------------------------------------------------------------------------
--Analyze customer behavior.
-------------------------------------------------------------------------------------------------------------------

--What were the least and most ordered items? What categories were they in?
WITH all_data AS(
	SELECT  *
	FROM order_details o LEFT JOIN menu_items m
	ON o.item_id = m.menu_item_id
)
SELECT item_id,
	    item_name,
        category,
		COUNT(*) Num_purchases
FROM all_data
GROUP BY item_id, item_name, category
ORDER BY Num_purchases DESC;


--What were the top 5 orders that spent the most money?
WITH all_data AS(
	SELECT  *
	FROM order_details o LEFT JOIN menu_items m
	ON o.item_id = m.menu_item_id
)
SELECT TOP 5
	order_id,
	SUM(price) AS Total_spend
FROM all_data
GROUP BY order_id
ORDER BY Total_spend DESC;


--View the details of the highest spend order. Which specific items were purchased?
WITH all_data AS(
	SELECT  *
	FROM order_details o LEFT JOIN menu_items m
	ON o.item_id = m.menu_item_id
)
SELECT *
FROM all_data
WHERE order_id = 440;


WITH all_data AS(
	SELECT  *
	FROM order_details o LEFT JOIN menu_items m
	ON o.item_id = m.menu_item_id
)
SELECT category, COUNT(*) AS Num_items
FROM all_data
WHERE order_id = 440
GROUP BY category
ORDER BY Num_items DESC;
		

--View the details of the top 5 highest spend orders.
WITH all_data AS(
	SELECT  *
	FROM order_details o LEFT JOIN menu_items m
	ON o.item_id = m.menu_item_id
),
CTE_2 AS
(
	SELECT TOP 5
		order_id,
		SUM(price) AS Total_Price
	FROM all_data
	GROUP BY order_id
	ORDER BY Total_Price DESC
)
SELECT 
	a.order_id,
    a.item_id,
	a.item_name,
    a.category,
    a.price
FROM all_data a, CTE_2 c
WHERE a.order_id = c.order_id;


WITH all_data AS(
	SELECT  *
	FROM order_details o LEFT JOIN menu_items m
	ON o.item_id = m.menu_item_id
),
CTE_2 AS
(
	SELECT TOP 5
		order_id,
		SUM(price) AS Total_Price
	FROM all_data
	GROUP BY order_id
	ORDER BY Total_Price DESC
)
SELECT 
    a.category,
    COUNT(*) AS Num_items
FROM all_data a, CTE_2 c
WHERE a.order_id = c.order_id
GROUP BY a.category;


WITH all_data AS(
	SELECT  *
	FROM order_details o LEFT JOIN menu_items m
	ON o.item_id = m.menu_item_id
),
CTE_2 AS
(
	SELECT TOP 5
		order_id,
		SUM(price) AS Total_Price
	FROM all_data
	GROUP BY order_id
	ORDER BY Total_Price DESC
)
SELECT 
	a.order_id,
    a.category,
    COUNT(*) AS Num_items
FROM all_data a, CTE_2 c
WHERE a.order_id = c.order_id
GROUP BY a.order_id, a.category
ORDER BY order_id, Num_items DESC;
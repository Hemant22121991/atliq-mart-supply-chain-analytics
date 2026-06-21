-- volume fill rate%

SELECT 
	ROUND(100.0* SUM(delivery_qty)/SUM(order_qty),2) AS vofr_perc
FROM fact_order_lines
;

-- volume fill rate% by customer

SELECT
	customer_id,
	SUM(delivery_qty) AS total_delivered_qty,
	SUM(order_qty) AS total_ordered_qty,
	ROUND(100.0* SUM(delivery_qty)/SUM(order_qty),2) AS vofr_perc
FROM fact_order_lines
GROUP BY 1
ORDER BY 1
;

-- volume fill rate% by product

SELECT
	product_id,
	SUM(delivery_qty) AS total_delivered_qty,
	SUM(order_qty) AS total_ordered_qty,
	ROUND(100.0* SUM(delivery_qty)/SUM(order_qty),2) AS vofr_perc
FROM fact_order_lines
GROUP BY 1
ORDER BY 1
;

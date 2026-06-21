-- Line fill rate%

SELECT 
	ROUND(100.0 * SUM(CASE WHEN "In Full" = 1 THEN "In Full" ELSE 0 END)/
	COUNT(*),2) AS lifr_perc
FROM fact_order_lines
;

-- Line fill rate% by customer

SELECT 
	customer_id,
	SUM(CASE WHEN "In Full" = 1 THEN "In Full" ELSE 0 END) AS total_line_fill_item,
	COUNT(*) total_line_item_in_order,
	ROUND(100.0 * SUM(CASE WHEN "In Full" = 1 THEN "In Full" ELSE 0 END)/
	COUNT(*),2) AS lifr_perc
FROM fact_order_lines
GROUP BY 1
ORDER BY customer_id
;


-- Line fill rate% by product

SELECT 
	product_id,
	SUM(CASE WHEN "In Full" = 1 THEN "In Full" ELSE 0 END) AS total_line_fill_item,
	COUNT(*) total_line_item_in_order,
	ROUND(100.0 * SUM(CASE WHEN "In Full" = 1 THEN "In Full" ELSE 0 END)/
	COUNT(*),2) AS lifr_perc
FROM fact_order_lines
GROUP BY 1
ORDER BY product_id
;
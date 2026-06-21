-- on time in full delivery%

SELECT
	ROUND(100.0 * SUM(otif)/COUNT(*),2) AS otif_perc
FROM fact_orders_aggregate
;

-- in full delivery% by city

SELECT
	dc.city,
	ROUND(100.0 * SUM(fo.otif)/COUNT(*),2) AS otif_perc
FROM fact_orders_aggregate AS fo
LEFT JOIN dim_customers AS dc
	ON fo.customer_id = dc.customer_id
GROUP BY 1
ORDER BY 1
;

-- in full delivery% by customer

SELECT
	customer_id,
	ROUND(100.0 * SUM(otif)/COUNT(*),2) AS otif_perc
FROM fact_orders_aggregate
GROUP BY 1
ORDER BY 1
;
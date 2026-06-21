-- on time delivery%

SELECT
	ROUND(100.0 * SUM(on_time)/COUNT(*),2) AS ot_perc
FROM fact_orders_aggregate
;

-- on time delivery% by city

SELECT
	dc.city,
	ROUND(100.0 * SUM(fo.on_time)/COUNT(*),2) AS ot_perc
FROM fact_orders_aggregate AS fo
LEFT JOIN dim_customers AS dc
	ON fo.customer_id = dc.customer_id
GROUP BY 1
ORDER BY 1
;

-- on time delivery% by customer

SELECT
	customer_id,
	ROUND(100.0 * SUM(on_time)/COUNT(*),2) AS ot_perc
FROM fact_orders_aggregate
GROUP BY 1
ORDER BY 1
;
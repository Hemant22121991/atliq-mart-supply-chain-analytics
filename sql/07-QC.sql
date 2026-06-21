-- Quality check

-- LoFR% and VoFR%

SELECT 
	ROUND(100.0 * SUM(CASE WHEN "In Full" = 1 THEN "In Full" ELSE 0 END)/
	COUNT(*),2) AS lifr_perc,
	ROUND(100.0* SUM(delivery_qty)/SUM(order_qty),2) AS vofr_perc
FROM fact_order_lines
;


-- OT%, IF% and IFOT%

SELECT
	ROUND(100.0 * SUM(on_time)/COUNT(*),2) AS ot_perc,
	ROUND(100.0 * SUM(in_full)/COUNT(*),2) AS if_perc,
	ROUND(100.0 * SUM(otif)/COUNT(*),2) AS otif_perc
FROM fact_orders_aggregate
;

-- Row count check

SELECT COUNT(*)
FROM fact_order_lines
;

SELECT COUNT(*)
FROM fact_orders_aggregate
;

-- customer id check

SELECT
	customer_id,
	ROUND(100.0 * SUM(on_time)/COUNT(*),2) AS ot_perc
FROM fact_orders_aggregate
GROUP BY 1
ORDER BY 1
;

SELECT COUNT(*)
FROM dim_customers
;



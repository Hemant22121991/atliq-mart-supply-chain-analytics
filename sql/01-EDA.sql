-- Data type checking and conversion for each table columns
ALTER TABLE fact_order_lines
ALTER COLUMN agreed_delivery_date TYPE DATE
USING agreed_delivery_date :: DATE;

ALTER TABLE fact_order_lines
ALTER COLUMN order_placement_date TYPE DATE
USING order_placement_date :: DATE;

ALTER TABLE fact_order_lines
ALTER COLUMN actual_delivery_date TYPE DATE
USING actual_delivery_date :: DATE;

SELECT *
FROM fact_order_lines
WHERE NOT (ROW(fact_order_lines.*) IS NOT NULL);

SELECT *
FROM dim_customers
;

SELECT *
FROM dim_date
;

ALTER TABLE dim_date
ALTER COLUMN date TYPE DATE
USING date :: DATE;


ALTER TABLE dim_date
ALTER COLUMN mmm_yy TYPE DATE
USING mmm_yy :: DATE;


ALTER TABLE dim_date
ALTER COLUMN mmm_yy TYPE VARCHAR(6)
USING TO_CHAR(mmm_yy, 'Mon-yy');


SELECT *
FROM dim_date
;

SELECT *
FROM dim_products
ORDER BY product_name
;

SELECT *
FROM dim_targets_orders
;


SELECT *
FROM fact_order_lines
;


SELECT *
FROM fact_orders_aggregate
;


ALTER TABLE fact_orders_aggregate
ALTER COLUMN order_placement_date TYPE DATE
USING order_placement_date :: DATE;


SELECT *
FROM fact_orders_aggregate
;
-- ============================================================
-- AtliQ Mart Supply Chain Analytics
-- Gold Layer — Data Validation & QC Queries
-- Run these after every pipeline execution to verify data integrity
-- Author: Hemant Mandge
-- ============================================================

-- ============================================================
-- 1. ROW COUNT VALIDATION
-- Expected counts based on source data
-- ============================================================
SELECT 'fact_supply_chain'  AS table_name, COUNT(*) AS row_count FROM gold.fact_supply_chain   -- Expected: 57,096
UNION ALL
SELECT 'fact_orders'        AS table_name, COUNT(*) AS row_count FROM gold.fact_orders          -- Expected: 31,729
UNION ALL
SELECT 'dim_customers'      AS table_name, COUNT(*) AS row_count FROM gold.dim_customers        -- Expected: 35
UNION ALL
SELECT 'dim_products'       AS table_name, COUNT(*) AS row_count FROM gold.dim_products         -- Expected: 18
UNION ALL
SELECT 'dim_date'           AS table_name, COUNT(*) AS row_count FROM gold.dim_date             -- Expected: 365
UNION ALL
SELECT 'dim_targets'        AS table_name, COUNT(*) AS row_count FROM gold.dim_targets;         -- Expected: 35

-- ============================================================
-- 2. OVERALL KPI VALIDATION
-- Compare these numbers against PostgreSQL / Excel baseline
-- ============================================================
-- OT%, IF%, OTIF% from fact_orders
SELECT
    CAST(ROUND(100.0 * SUM(on_time) / COUNT(*), 2) AS DECIMAL(6,2)) AS ot_perc,
    CAST(ROUND(100.0 * SUM(in_full) / COUNT(*), 2) AS DECIMAL(6,2)) AS if_perc,
    CAST(ROUND(100.0 * SUM(otif)    / COUNT(*), 2) AS DECIMAL(6,2)) AS otif_perc
FROM silver_sc.dbo.fact_orders_aggregate;

-- LiFR% and VoFR% from fact_supply_chain
SELECT * FROM gold.vw_qc_summary;

-- ============================================================
-- 3. REFERENTIAL INTEGRITY CHECKS
-- Verify no orphan keys in fact tables
-- All results should return 0 rows
-- ============================================================

-- Check unmatched customer_ids in fact_supply_chain
SELECT DISTINCT customer_id
FROM gold.fact_supply_chain
WHERE customer_id NOT IN (SELECT customer_id FROM gold.dim_customers);

-- Check unmatched product_ids in fact_supply_chain
SELECT DISTINCT product_id
FROM gold.fact_supply_chain
WHERE product_id NOT IN (SELECT product_id FROM gold.dim_products);

-- Check unmatched dates in fact_supply_chain
SELECT DISTINCT order_placement_date
FROM gold.fact_supply_chain
WHERE order_placement_date NOT IN (SELECT date FROM gold.dim_date);

-- Check unmatched customer_ids in fact_orders
SELECT DISTINCT customer_id
FROM gold.fact_orders
WHERE customer_id NOT IN (SELECT customer_id FROM gold.dim_customers);

-- Check unmatched customer_ids in dim_targets
SELECT DISTINCT customer_id
FROM gold.dim_targets
WHERE customer_id NOT IN (SELECT customer_id FROM gold.dim_customers);

-- ============================================================
-- 4. COLUMN SWAP VALIDATION
-- Verify on_time and in_full are not swapped in fact_supply_chain
-- on_time sum should be HIGHER than in_full sum
-- (More orders delivered on time than in full historically)
-- ============================================================
SELECT
    SUM(on_time)    AS on_time_sum,   -- Expected: ~40,605
    SUM(in_full)    AS in_full_sum,   -- Expected: ~37,661
    SUM(otif)       AS otif_sum,      -- Expected: ~27,380
    COUNT(*)        AS total_rows     -- Expected: 57,096
FROM gold.fact_supply_chain;

-- ============================================================
-- 5. NULL CHECK
-- Verify no critical columns have nulls
-- ============================================================
SELECT
    SUM(CASE WHEN order_id              IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN customer_id          IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN product_id           IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN order_placement_date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
    SUM(CASE WHEN on_time              IS NULL THEN 1 ELSE 0 END) AS null_on_time,
    SUM(CASE WHEN in_full              IS NULL THEN 1 ELSE 0 END) AS null_in_full,
    SUM(CASE WHEN otif                 IS NULL THEN 1 ELSE 0 END) AS null_otif
FROM gold.fact_supply_chain;

-- ============================================================
-- 6. DATE RANGE VALIDATION
-- Confirm data covers expected period: March 2022 - August 2022
-- ============================================================
SELECT
    MIN(order_placement_date) AS earliest_order_date,
    MAX(order_placement_date) AS latest_order_date,
    MIN(actual_delivery_date) AS earliest_delivery_date,
    MAX(actual_delivery_date) AS latest_delivery_date
FROM gold.fact_supply_chain;
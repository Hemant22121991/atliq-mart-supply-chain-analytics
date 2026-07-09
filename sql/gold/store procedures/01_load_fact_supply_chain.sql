-- ============================================================
-- AtliQ Mart Supply Chain Analytics
-- Gold Layer — Stored Procedures (Silver → Gold ETL)
-- Fabric Warehouse: gold_sc
-- Pattern: TRUNCATE + INSERT (idempotent full refresh)
-- Author: Hemant Mandge
-- ============================================================

-- ============================================================
-- 1. LOAD fact_supply_chain
-- Joins fact_order_lines from Silver
-- Maps column names correctly (On Time, In Full, On Time In Full)
-- Computes line_fill_rate at load time
-- ============================================================
CREATE PROCEDURE gold.load_fact_supply_chain
AS
BEGIN
    TRUNCATE TABLE gold.fact_supply_chain;

    INSERT INTO gold.fact_supply_chain
    SELECT
        order_id,
        customer_id,
        product_id,
        order_qty,
        delivered_qty,
        order_placement_date,
        agreed_delivery_date,
        actual_delivery_date,
        [On Time]           AS on_time,
        [In Full]           AS in_full,
        [On Time In Full]   AS otif,
        CAST(
            delivered_qty * 100.0 / NULLIF(order_qty, 0)
        AS DECIMAL(6,2))    AS line_fill_rate
    FROM silver_sc.dbo.fact_order_lines;
END;
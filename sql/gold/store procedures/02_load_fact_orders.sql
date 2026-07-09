-- ============================================================
-- AtliQ Mart Supply Chain Analytics
-- Gold Layer — Stored Procedures (Silver → Gold ETL)
-- Fabric Warehouse: gold_sc
-- Pattern: TRUNCATE + INSERT (idempotent full refresh)
-- Author: Hemant Mandge
-- ============================================================

-- ============================================================
-- 2. LOAD fact_orders
-- Straight copy from fact_orders_aggregate in Silver
-- ============================================================
CREATE PROCEDURE gold.load_fact_orders
AS
BEGIN
    TRUNCATE TABLE gold.fact_orders;

    INSERT INTO gold.fact_orders
    SELECT
        order_id,
        customer_id,
        order_placement_date,
        on_time,
        in_full,
        otif
    FROM silver_sc.dbo.fact_orders_aggregate;
END;
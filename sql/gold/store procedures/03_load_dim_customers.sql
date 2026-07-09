-- ============================================================
-- AtliQ Mart Supply Chain Analytics
-- Gold Layer — Stored Procedures (Silver → Gold ETL)
-- Fabric Warehouse: gold_sc
-- Pattern: TRUNCATE + INSERT (idempotent full refresh)
-- Author: Hemant Mandge
-- ============================================================

-- ============================================================
-- 3. LOAD dim_customers
-- Straight copy from Silver
-- ============================================================
CREATE PROCEDURE gold.load_dim_customers
AS
BEGIN
    TRUNCATE TABLE gold.dim_customers;

    INSERT INTO gold.dim_customers
    SELECT
        customer_id,
        customer_name,
        city
    FROM silver_sc.dbo.dim_customers;
END;
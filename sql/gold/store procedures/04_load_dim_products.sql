-- ============================================================
-- AtliQ Mart Supply Chain Analytics
-- Gold Layer — Stored Procedures (Silver → Gold ETL)
-- Fabric Warehouse: gold_sc
-- Pattern: TRUNCATE + INSERT (idempotent full refresh)
-- Author: Hemant Mandge
-- ============================================================

-- ============================================================
-- 4. LOAD dim_products
-- Straight copy from Silver
-- ============================================================
CREATE PROCEDURE gold.load_dim_products
AS
BEGIN
    TRUNCATE TABLE gold.dim_products;

    INSERT INTO gold.dim_products
    SELECT
        product_id,
        product_name,
        category
    FROM silver_sc.dbo.dim_products;
END;

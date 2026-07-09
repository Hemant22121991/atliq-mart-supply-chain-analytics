-- ============================================================
-- AtliQ Mart Supply Chain Analytics
-- Gold Layer — Stored Procedures (Silver → Gold ETL)
-- Fabric Warehouse: gold_sc
-- Pattern: TRUNCATE + INSERT (idempotent full refresh)
-- Author: Hemant Mandge
-- ============================================================

-- ============================================================
-- 6. LOAD dim_targets
-- Renames columns with % symbol using brackets (T-SQL syntax)
-- Silver columns: ontime_target%, infull_target%, otif_target%
-- ============================================================
CREATE PROCEDURE gold.load_dim_targets
AS
BEGIN
    TRUNCATE TABLE gold.dim_targets;

    INSERT INTO gold.dim_targets
    SELECT
        customer_id,
        [ontime_target%]    AS ontime_target,
        [infull_target%]    AS infull_target,
        [otif_target%]      AS otif_target
    FROM silver_sc.dbo.dim_targets_orders;
END;
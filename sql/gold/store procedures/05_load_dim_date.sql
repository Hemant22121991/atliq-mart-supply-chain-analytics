-- ============================================================
-- AtliQ Mart Supply Chain Analytics
-- Gold Layer — Stored Procedures (Silver → Gold ETL)
-- Fabric Warehouse: gold_sc
-- Pattern: TRUNCATE + INSERT (idempotent full refresh)
-- Author: Hemant Mandge
-- ============================================================

-- ============================================================
-- 5. LOAD dim_date
-- Renames columns with spaces using brackets (T-SQL syntax)
-- Silver columns: Date, Month No, Month Name, Quarter, Day, Weekday
-- ============================================================
CREATE PROCEDURE gold.load_dim_date
AS
BEGIN
    TRUNCATE TABLE gold.dim_date;

    INSERT INTO gold.dim_date
    SELECT
        [Date]          AS date,
        [Year]          AS year,
        [Month No]      AS month_no,
        [Month Name]    AS month_name,
        [Quarter]       AS quarter,
        [Day]           AS day,
        [Weekday]       AS weekday
    FROM silver_sc.dbo.dim_date;
END;
-- ============================================================
-- AtliQ Mart Supply Chain Analytics
-- Gold Layer — Table Creation Scripts
-- Fabric Warehouse: gold_sc
-- Author: Hemant Mandge
-- ============================================================

-- Create gold schema
CREATE SCHEMA gold;

-- ============================================================
-- 1. FACT TABLE: fact_supply_chain
-- Grain: One row per order line
-- Source: silver_sc.dbo.fact_order_lines
-- Contains computed on_time, in_full, otif flags + line_fill_rate
-- ============================================================
CREATE TABLE gold.fact_supply_chain (
    order_id                VARCHAR(50),
    customer_id             INT,
    product_id              INT,
    order_qty               INT,
    delivered_qty           INT,
    order_placement_date    DATE,
    agreed_delivery_date    DATE,
    actual_delivery_date    DATE,
    on_time                 INT,
    in_full                 INT,
    otif                    INT,
    line_fill_rate          DECIMAL(6,2)
);

-- ============================================================
-- 2. FACT TABLE: fact_orders
-- Grain: One row per order (aggregated level)
-- Source: silver_sc.dbo.fact_orders_aggregate
-- Contains OT, IF, OTIF flags at order level
-- ============================================================
CREATE TABLE gold.fact_orders (
    order_id                VARCHAR(50),
    customer_id             INT,
    order_placement_date    DATE,
    on_time                 INT,
    in_full                 INT,
    otif                    INT
);

-- ============================================================
-- 3. DIMENSION TABLE: dim_customers
-- Grain: One row per customer
-- Source: silver_sc.dbo.dim_customers
-- ============================================================
CREATE TABLE gold.dim_customers (
    customer_id     INT,
    customer_name   VARCHAR(100),
    city            VARCHAR(100)
);

-- ============================================================
-- 4. DIMENSION TABLE: dim_products
-- Grain: One row per product
-- Source: silver_sc.dbo.dim_products
-- ============================================================
CREATE TABLE gold.dim_products (
    product_id      INT,
    product_name    VARCHAR(100),
    category        VARCHAR(100)
);

-- ============================================================
-- 5. DIMENSION TABLE: dim_date
-- Grain: One row per calendar date
-- Source: silver_sc.dbo.dim_date (custom built in Dataflow Gen2)
-- ============================================================
CREATE TABLE gold.dim_date (
    date            DATE,
    year            INT,
    month_no        INT,
    month_name      VARCHAR(20),
    quarter         VARCHAR(5),
    day             INT,
    weekday         VARCHAR(20)
);

-- ============================================================
-- 6. DIMENSION TABLE: dim_targets
-- Grain: One row per customer (OT, IF, OTIF targets)
-- Source: silver_sc.dbo.dim_targets_orders
-- Note: Column names cleaned (removed % symbol from source)
-- ============================================================
CREATE TABLE gold.dim_targets (
    customer_id     INT,
    ontime_target   DECIMAL(5,2),
    infull_target   DECIMAL(5,2),
    otif_target     DECIMAL(5,2)
);
# 🏪 AtliQ Mart Supply Chain Analytics
### End-to-End BI + Data Engineering Project on Microsoft Fabric

![Microsoft Fabric](https://img.shields.io/badge/Microsoft%20Fabric-Trial-0078D4?style=for-the-badge&logo=microsoft)
![Power BI](https://img.shields.io/badge/Power%20BI-Report%20%26%20Dashboard-F2C811?style=for-the-badge&logo=powerbi)
![Paginated Report](https://img.shields.io/badge/Paginated%20Report-Report%20Builder-0078D4?style=for-the-badge&logo=microsoft)
![T-SQL](https://img.shields.io/badge/T--SQL-Gold%20Layer-CC2927?style=for-the-badge&logo=microsoftsqlserver)
![Status](https://img.shields.io/badge/Status-Completed-27AE60?style=for-the-badge)

---

## 📌 Project Overview

AtliQ Mart is a growing FMCG manufacturer operating across **Surat, Ahmedabad, and Vadodara**. The company faced a critical business problem — key customers were not renewing annual contracts due to poor delivery service levels. Management needed an analytics solution to track and improve supply chain performance before expanding to new cities.

This project delivers a **production-grade end-to-end data pipeline** built entirely on **Microsoft Fabric**, transforming raw CSV data into actionable supply chain intelligence through a Power BI interactive report, a live executive dashboard, and a pixel-perfect paginated report for management distribution.

---

## 🎯 Business Problem

> *"Why did our key customers not renew the contract? Are we that bad?"*
> — Bruce Haryali, Director, AtliQ Mart

Management approved analytics budget after discovering that service level tracking had never been deployed. The analytics team (Peter Pandey) was given one month to deliver a comprehensive supply chain monitoring solution covering:

- On-Time delivery performance vs customer targets
- In-Full delivery performance vs customer targets
- OTIF (On Time In Full) — the primary reliability metric
- Line Fill Rate and Volume Fill Rate at product level

---

- Power BI Live Report: 


---

## 🏗️ Architecture

This project follows the **Medallion Architecture** on Microsoft Fabric — a modern, layered data engineering pattern used across enterprise data teams.

```
┌─────────────────────────────────────────────────────────────────┐
│                     Microsoft Fabric — OneLake                  │
│                                                                 │
│   ┌─────────────┐    Dataflow    ┌─────────────┐    T-SQL SP    │
│   │   BRONZE    │ ─────Gen2────► │   SILVER    │ ──────────────►│
│   │  Lakehouse  │                │  Lakehouse  │                │
│   │ Raw Delta   │                │ Clean Delta │                │
│   └─────────────┘                └─────────────┘                │
│                                                                 │
│                                  ┌─────────────┐                │
│                                  │    GOLD     │                │
│                                  │  Warehouse  │                │
│                                  │ Business    │                │
│                                  │   T-SQL     │                │
│                                  └─────────────┘                │
└─────────────────────────────────────────────────────────────────┘
                              │
                    DirectLake Semantic Model
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
 Power BI Report      Executive Dashboard    Paginated Report
(3 interactive pages)  (Live pinned tiles)  (PDF for management)
```

---

## 🛠️ Tech Stack

| Layer | Tool | Purpose |
|-------|------|---------|
| **Ingestion** | Microsoft Fabric Lakehouse | Upload raw CSV files as Delta tables |
| **Transformation — Silver** | Dataflow Gen2 (Power Query) | Data cleaning, type casting, derived columns |
| **Transformation — Gold** | Fabric Warehouse (T-SQL) | Business logic, KPI views, stored procedures |
| **Orchestration** | Data Pipeline | Sequential execution: Copy → Dataflow → Stored Proc |
| **Semantic Layer** | DirectLake Semantic Model | Star schema, DAX measures, relationships |
| **Interactive Report** | Power BI Report (3 pages) | Interactive dashboards with drill-through |
| **Executive Dashboard** | Power BI Services | Live dashboard with pinned tiles |
| **Paginated Report** | Power BI Report Builder | Pixel-perfect PDF for management distribution |
| **Version Control** | GitHub | SQL scripts, documentation |

---

## 📊 Data Model — Star Schema

```
                    ┌──────────────┐
                    │  dim_date    │
                    │  date (PK)   │
                    │  month_name  │
                    │  month_no    │
                    │  quarter     │
                    └──────┬───────┘
                           │ 1:*
          ┌────────────────┼────────────────┐
          │                │                │
     ┌────▼─────┐   ┌──────▼───────┐  ┌────▼──────┐
     │dim_cust. │   │fact_supply   │  │dim_product│
     │cust_id PK│──►│_chain        │◄─│product_id │
     │cust_name │1:*│(57,096 rows) │*:1│prod_name │
     │city      │   │order lines   │  │category   │
     └────┬─────┘   └──────────────┘  └───────────┘
          │
          │1:*  ┌──────────────┐
          │     │ fact_orders  │
          ├────►│ (31,729 rows)│
          │     │ OT, IF, OTIF │
          │     └──────────────┘
          │1:1
          ▼
     ┌────────────┐
     │dim_targets │
     │OT target % │
     │IF target % │
     │OTIF target%│
     └────────────┘
```

**Schema type:** Constellation (Fact Constellation / Galaxy Schema) — two fact tables sharing the same dimension tables.

---

## 📐 Data Pipeline Details

### Bronze Layer — Raw Ingestion
- 6 CSV files uploaded to Fabric Lakehouse Files section
- Loaded to Delta tables via "Load to Tables" feature
- Full overwrite on each run (idempotent)

### Silver Layer — Cleaning via Dataflow Gen2
Transformations applied without PySpark — pure Power Query (M language):

| Table | Transformation Applied |
|-------|----------------------|
| `fact_order_lines` | Long date format parsed, column trimming, type casting, derived `on_time`/`in_full`/`otif` flags |
| `dim_date` | Custom date dimension with Year, Month No, Month Name, Quarter, Day, Weekday |
| `dim_customers` | Whitespace trimming, type validation |
| `dim_products` | Type standardization |
| `dim_targets_orders` | Column rename (removed `%` from column names) |
| `fact_orders_aggregate` | Date parsing, type validation |

All tables use **Replace + Fixed Schema** mode — protects data contracts downstream.

### Gold Layer — Business Logic via T-SQL
Six stored procedures load Gold Warehouse tables from Silver:

```sql
-- Example: load_fact_supply_chain
CREATE PROCEDURE gold.load_fact_supply_chain AS
BEGIN
    TRUNCATE TABLE gold.fact_supply_chain;
    INSERT INTO gold.fact_supply_chain
    SELECT
        order_id, customer_id, product_id,
        order_qty, delivered_qty,
        order_placement_date, agreed_delivery_date, actual_delivery_date,
        [On Time]         AS on_time,
        [In Full]         AS in_full,
        [On Time In Full] AS otif,
        CAST(delivered_qty * 100.0 / NULLIF(order_qty, 0) AS DECIMAL(6,2)) AS line_fill_rate
    FROM silver_sc.dbo.fact_order_lines;
END;
```

Four analytical views support SQL-level reporting independently of Power BI:
- `gold.vw_otif_metrics` — OT%, IF%, OTIF% by customer and city
- `gold.vw_line_fill_rate` — LiFR% by customer and product
- `gold.vw_volume_fill_rate` — VoFR% by customer and product
- `gold.vw_qc_summary` — Overall KPI validation

---

## 📈 DAX Measures

13 measures built in a dedicated `_Measures` table:

```
── Count Measures ──────────────────────────────────
Total Order Lines     = COUNTROWS(fact_supply_chain)
Total Orders          = COUNTROWS(fact_orders)

── Line Level (fact_supply_chain) ──────────────────
LiFR %   = lines in_full = 1 / Total Order Lines
VoFR %   = SUM(delivered_qty) / SUM(order_qty)

── Order Level (fact_orders) ───────────────────────
OT %     = orders on_time = 1 / Total Orders
IF %     = orders in_full = 1 / Total Orders
OTIF %   = orders otif = 1 / Total Orders

── Targets (dim_targets) ───────────────────────────
OT Target %    AVGX of ontime_target per customer
IF Target %    AVGX of infull_target per customer
OTIF Target %  AVGX of otif_target per customer

── Gap vs Target ───────────────────────────────────
OT Gap %   = OT % − OT Target %
IF Gap %   = IF % − IF Target %
OTIF Gap % = OTIF % − OTIF Target %
```

---

## 🔍 Key Business Insights

> Data period: **March 2022 – August 2022** | 3 cities | 15 customers | 18 products

### Overall Performance vs Target

| Metric | Actual | Target | Gap |
|--------|--------|--------|-----|
| **OT %** | 59.03% | 86.09% | **-27.06%** 🔴 |
| **IF %** | 52.78% | 76.51% | **-23.73%** 🔴 |
| **OTIF %** | 29.02% | 65.91% | **-36.89%** 🔴 |
| **LiFR %** | 65.96% | No Target | — |
| **VoFR %** | 96.59% | No Target | — |

### Critical Findings

**1. All three cities fail significantly on OTIF:**
Vadodara (27.78%), Ahmedabad (29.33%), and Surat (30.07%) are all ~35% below their respective targets — indicating a systemic supply chain issue, not a city-specific one.

**2. Two customer clusters with different failure modes:**
- **Coolblue, Acclaimed Stores, Lotus Mart** — very low OTIF (~13-16%) driven by both OT and IF failures simultaneously
- **Propel Mart, Expert Mart, Atlas Stores** — relatively better OTIF (~39-41%) but still ~27% below target

**3. VoFR % is healthy at 96.59%:**
Volume is being shipped — the problem is timing and order completeness at line level, not total volume capacity.

**4. LiFR % at 65.96%:**
34% of order lines are not delivered in full — suggesting SKU-level inventory or forecasting gaps rather than total capacity issues.

---

## 📋 Report Pages — Interactive Power BI Report

### Page 1 — Executive Summary
- 5 KPI cards with actual, target, gap and directional arrow
- Performance by City — clustered horizontal bar chart (OT%, IF%, OTIF%)
- Customer Performance Matrix — conditional formatting by gap severity

### Page 2 — Customer View
- LiFR % and VoFR % summary cards
- Full Customer × City matrix with all metrics, targets, and gaps
- Expandable customer rows with city-level drill-down

### Page 3 — Trend & Products
- Metric Performance Over Time — line chart with **field parameter switcher** (OT%/IF%/OTIF%/LiFR%/VoFR%) and dashed target reference line. Drillable: Month → Week → Day
- Product Insights — matrix with LiFR% and VoFR% per product + **sparkline trend columns**

---

## 📄 Paginated Report — Management Distribution

Built using **Power BI Report Builder** and published to Microsoft Fabric workspace.

**Report: Customer Service Level Report**
- Pixel-perfect landscape A4 layout
- All 15 customers × all cities with complete KPI breakdown
- Columns: Customer | City | Total Orders | OT% | OT Target | IF% | IF Target | OTIF% | OTIF Target | OT Gap | IF Gap | OTIF Gap
- **Conditional formatting**: Gap columns highlighted Red (below target) / Green (above target)
- Auto-generated subtitle with report date
- Page numbers in footer (Page X of Y)
- Designed for PDF export and email distribution to management
- Live connection to Gold Warehouse via SQL endpoint

**Key difference from interactive report:**
The paginated report renders ALL rows across as many pages as needed — designed for printing and PDF archiving, not interactive exploration. The interactive Power BI report is for analysis; the paginated report is for distribution.

---

## 🗂️ Repository Structure

```
atliq-sc-analytics/
│
├── sql/
│   ├── gold/
│   │   ├── tables/
│   │   │   └── 01_create_gold_tables.sql
│   │   ├── stored_procedures/
│   │   │   ├── 01_load_fact_supply_chain.sql
│   │   │   ├── 02_load_fact_orders.sql
│   │   │   ├── 03_load_dim_customers.sql
│   │   │   ├── 04_load_dim_products.sql
│   │   │   ├── 05_load_dim_date.sql
│   │   │   └── 06_load_dim_targets.sql
│   │   └── views/
│   │       ├── vw_otif_metrics.sql
│   │       ├── vw_line_fill_rate.sql
│   │       ├── vw_volume_fill_rate.sql
│   │       └── vw_qc_summary.sql
│   └── qc/
│       └── data_validation_checks.sql
│
├── screenshots/
│   ├── architecture_diagram.png
│   ├── page1_executive_summary.png
│   ├── page2_customer_view.png
│   ├── page3_trend_products.png
│   ├── pbi_services_dashboard.png
│   └── paginated_report_preview.png
│
├── docs/
│   ├── business_knowledge.pdf
│   ├── peter_pandey_notes.pdf
│   └── metrics_definitions.md
│
└── README.md
```

---

## 🏭 Pipeline Execution Order

```sql
-- Run in sequence after data upload to Bronze Lakehouse

-- Step 1: Dataflow Gen2 triggers automatically via Data Pipeline
-- Step 2: Execute Gold stored procedures
EXEC gold.load_dim_customers;
EXEC gold.load_dim_products;
EXEC gold.load_dim_date;
EXEC gold.load_dim_targets;
EXEC gold.load_fact_orders;
EXEC gold.load_fact_supply_chain;

-- Step 3: Validate
SELECT 'fact_supply_chain', COUNT(*) FROM gold.fact_supply_chain  -- 57,096
UNION ALL
SELECT 'fact_orders',        COUNT(*) FROM gold.fact_orders        -- 31,729
UNION ALL
SELECT 'dim_customers',      COUNT(*) FROM gold.dim_customers      -- 35
UNION ALL
SELECT 'dim_products',       COUNT(*) FROM gold.dim_products       -- 18
UNION ALL
SELECT 'dim_date',           COUNT(*) FROM gold.dim_date           -- 365
UNION ALL
SELECT 'dim_targets',        COUNT(*) FROM gold.dim_targets;       -- 35
```

---

## 🎓 Skills Demonstrated

**Data Engineering:**
- Medallion Architecture (Bronze/Silver/Gold) on Microsoft Fabric
- Dataflow Gen2 for no-code/low-code data transformation (Power Query M)
- Fabric Warehouse with T-SQL stored procedures and views
- Idempotent load patterns (TRUNCATE + INSERT)
- Data Pipeline orchestration with sequential activity chaining
- DirectLake Semantic Model on Fabric Warehouse
- Schema enforcement and data contract principles

**Business Intelligence:**
- Star schema / Constellation schema design
- DAX measure development (DIVIDE, FILTER, CALCULATE patterns)
- Field parameters for dynamic metric switching
- Conditional formatting by business rules
- Sparkline trend visualization
- Power BI Services live dashboard
- Paginated reports with Power BI Report Builder (pixel-perfect PDF output)

**Domain Knowledge:**
- FMCG Supply Chain KPIs (OT%, IF%, OTIF%, LiFR%, VoFR%)
- Order vs Order Line level metric distinction
- Customer-level target tracking and gap analysis

---

## 📚 Domain Reference — Supply Chain KPIs

| KPI | Definition | Grain |
|-----|-----------|-------|
| **OT % (On Time)** | % of orders delivered on or before agreed date | Order level |
| **IF % (In Full)** | % of orders delivered with complete quantity | Order level |
| **OTIF %** | % of orders delivered both on time AND in full | Order level |
| **LiFR %** | % of order lines delivered in full (ignores timing) | Line level |
| **VoFR %** | Total qty delivered / Total qty ordered | Line level |

> An order is OTIF only when ALL line items inside the order are delivered In Full AND On Time.

---

## 👨‍💻 About This Project

This project was built as part of the **CodeBasics Resume Project Challenge (FMCG | C2)**, reimagined as a full **BI + Data Engineering showcase** using Microsoft Fabric instead of the traditional PostgreSQL + Power BI approach — demonstrating modern cloud data engineering capabilities alongside core BI skills.

**Built by:** Hemant Mandge
**Role:** BI & Data Engineer
**Connect:** [LinkedIn](https://linkedin.com/in/hemantmandge)

---

## 🙏 Acknowledgements

- [CodeBasics](https://codebasics.io) — Dataset, business context, and stakeholder notes
- Microsoft Fabric Documentation
- Power BI Community

---

*⭐ If you found this project useful, please consider starring the repository!*

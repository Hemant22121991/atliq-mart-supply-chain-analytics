# 🏭 AtliQ Mart — Supply Chain Analytics
### Codebasics Resume Project Challenge #2

![Status](https://img.shields.io/badge/Status-In%20Progress-yellow)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Database-336791?logo=postgresql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Analysis-orange)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?logo=powerbi&logoColor=black)
![DBeaver](https://img.shields.io/badge/DBeaver-SQL%20Client-372923)

---

## 📌 Problem Statement

AtliQ Mart is a growing FMCG manufacturer headquartered in Gujarat, India, operating across **Surat, Ahmedabad, and Vadodara**. The business is facing a critical risk: **key customers are not renewing annual contracts** due to poor service levels.

Management suspects deliveries are either arriving **late** or being **delivered incomplete** — but lacks the data visibility to confirm which products, customers, or cities are driving the failures.

The Supply Chain Analytics team has been tasked with tracking **OTIF% (On Time In Full)** and related service metrics daily, so leadership can act before the service gap widens further.

> **Domain perspective:** After 9+ years working across automotive supply chains — ThyssenKrupp, Tata Motors, COMAU — I have seen how delivery failures cascade. A missed OTIF target doesn't just affect one invoice; it erodes a customer relationship built over years. This project applies that operational lens to AtliQ Mart's FMCG delivery data, looking not just at the numbers but at the *patterns* behind them.

---

## 🎯 Objectives

- Track **OTIF%, OT% (On Time), and IF% (In Full)** vs. agreed customer targets
- Identify which **customers** are receiving the worst service levels
- Spot which **product categories** have the highest unmet demand (low fill rates)
- Surface **delivery delay patterns** by city and by month
- Build a **3-page Power BI dashboard** enabling drill-down from company-wide to customer-level performance

---

## 🗂️ Dataset

**Source:** [Codebasics Resume Project Challenge #2](https://codebasics.io/challenge/codebasics-resume-project-challenge)

| File | Description |
|---|---|
| `dim_customers.csv` | Customer master — name, city |
| `dim_products.csv` | Product master — name, category |
| `dim_date.csv` | Date dimension table |
| `dim_targets_orders.csv` | Per-customer OTIF / OT / IF targets |
| `fact_orders_aggregate.csv` | Aggregated order-level delivery performance |
| `fact_order_lines.csv` | Line-level order detail with actual vs. agreed delivery dates |

> Raw CSV files are not committed to this repository. Download from the Codebasics link above and place in `/data/raw/`.

---

## 🛠️ Tech Stack

| Layer | Tool | Purpose |
|---|---|---|
| Data Ingestion | DBeaver + PostgreSQL | Import CSVs directly into local PostgreSQL database |
| Storage | PostgreSQL (local) | Relational database for all fact and dimension tables |
| Transformation | SQL — window functions, CTEs | OTIF calculations, rolling averages, supplier rankings |
| Data Modelling | Star schema (draw.io) | fact + dim table design, visualised as PNG |
| BI / Visualisation | Power BI Desktop (PBIP format) | 3-page executive dashboard |
| Deployment | Power BI Service | Published workspace — live report |
| Version Control | Git + GitHub | Full project history, conventional commits |

---

## 🏗️ Data Model

Star schema — one central fact table, four dimension tables.

```
                     ┌──────────────┐
                     │   dim_date   │
                     └──────┬───────┘
                            │
 ┌──────────────┐   ┌───────▼────────────┐   ┌──────────────────┐
 │ dim_customers├───► fact_orders_agg    ◄───┤   dim_products   │
 └──────────────┘   │                    │   └──────────────────┘
                    │  order_id          │
 ┌──────────────┐   │  customer_id  FK   │   ┌──────────────────┐
 │dim_targets   ├───► product_id    FK   ◄───┤ fact_order_lines │
 └──────────────┘   │  order_date   FK   │   └──────────────────┘
                    │  otif_flag         │
                    │  ot_flag           │
                    │  if_flag           │
                    └────────────────────┘
```

> Full diagram with cardinality: [`/docs/data_model.png`](./docs/data_model.png)

---

## 📁 Repository Structure

```
atliq-mart-supply-chain-analytics/
│
├── README.md                            ← You are here
├── .gitignore                           ← Excludes .env, .pbix binary, raw CSVs
│
├── /data/
│   └── raw/                             ← Place Codebasics CSVs here (not committed)
│
├── /sql/
│   ├── 01_schema_setup.sql              ← CREATE TABLE statements for all 6 tables
│   ├── 02_otif_analysis.sql             ← OTIF%, OT%, IF% by customer and city
│   ├── 03_supplier_ranking.sql          ← Window functions: supplier reliability rank
│   └── 04_late_delivery_patterns.sql    ← Monthly delivery delay trend analysis
│
├── /pbix/
│   └── supply_chain_analytics.pbip/     ← PBIP format (text-based, Git-diffable)
│
├── /docs/
    ├── data_model.png                   ← Star schema diagram (draw.io export)
    ├── architecture.png                 ← End-to-end pipeline overview
    └── screenshots/
       ├── 01_executive_summary.png
       ├── 02_otif_drilldown.png
       └── 03_supplier_scorecard.png


```

---

## 📊 Key Metrics Tracked

| Metric | Definition |
|---|---|
| **OTIF%** | Orders delivered On Time AND In Full — the headline KPI |
| **OT%** | Orders delivered On Time (regardless of quantity completeness) |
| **IF%** | Orders delivered In Full (regardless of timing) |
| **LIFR%** | Line Fill Rate — % of order lines fully delivered |
| **VOFR%** | Volume Fill Rate — % of total ordered volume actually delivered |

> OTIF is a strict AND condition. An order only qualifies if *both* OT and IF are met simultaneously. This is standard supply chain practice — partial credit doesn't count.

---

## 💡 SQL Techniques Used

- **Window functions** — `ROW_NUMBER()`, `RANK()`, `LAG()` for supplier rankings and month-over-month trend
- **CTEs** — multi-step OTIF calculations broken into readable, testable layers
- **Aggregations with FILTER** — per-customer OT%, IF%, and OTIF% vs. target in a single query
- **Date functions** — rolling 4-week OTIF averages, delivery delay in days

---

## 📈 Dashboard — Power BI

**3 pages, mobile view enabled:**

| Page | What it answers |
|---|---|
| **Executive Summary** | Overall OTIF%, OT%, IF% vs. targets — company-wide KPIs at a glance |
| **OTIF Drill-Down** | Customer-level breakdown — who is furthest below their agreed target? |
| **Supplier Scorecard** | Product category fill rates, late delivery patterns by city and month |

> Published report: *(Power BI Service link — to be added on deployment)*
>
> Screenshots: [`/docs/screenshots/`](./docs/screenshots/)

---

## 🔍 Key Findings

> *(Updated as analysis progresses)*

- [ ] Overall OTIF% vs. target — size of the gap
- [ ] Top 3 underperforming customers by OTIF delta vs. target
- [ ] Product categories with lowest volume fill rate (VOFR%)
- [ ] City with worst on-time delivery record
- [ ] Month-over-month delivery trend — improving or worsening?

---

## ▶️ How to Reproduce

### 1. Clone the repo
```bash
git clone https://github.com/Hemant22121991/atliq-mart-supply-chain-analytics.git
cd atliq-mart-supply-chain-analytics
```

### 2. Download the dataset
Download the 6 CSV files from [Codebasics RPC #2](https://codebasics.io/challenge/codebasics-resume-project-challenge) and place them in `/data/raw/`.

### 3. Set up PostgreSQL database
Create a new database in PostgreSQL (via DBeaver or `psql`):
```sql
CREATE DATABASE atliq_mart_sc;
```

### 4. Load schema and data (DBeaver)
Open DBeaver → connect to `atliq_mart_sc` → run SQL scripts in order:
```
sql/01_schema_setup.sql       ← Creates all tables
sql/02_otif_analysis.sql      ← Core OTIF metrics
sql/03_supplier_ranking.sql   ← Supplier reliability rankings
sql/04_late_delivery_patterns.sql  ← Delay trend analysis
```
Import CSVs using DBeaver's **Import Data** wizard (right-click table → Import Data → CSV).

### 5. Open the dashboard
Open `/pbix/supply_chain_analytics.pbip` in Power BI Desktop.
Update the data source connection to point to your local PostgreSQL instance.

---

## 🧠 Domain Insight

Most supply chain dashboards report the OTIF number. The harder question is **why** it is what it is.

In manufacturing, delivery failures cluster around three root causes: demand spikes that weren't forecasted, lead time compression that squeezed supplier buffers, and last-mile routing failures that show up as geographic patterns.

This analysis looks for those same signatures in AtliQ Mart's FMCG data — specifically whether the OTIF failures are **random noise** or whether they concentrate around specific customers, categories, or months in a way that points to a systemic fix.

---

## 🗺️ Project Roadmap

- [x] Repo setup — folder structure, `.gitignore`, README
- [ ] Schema setup — `01_schema_setup.sql` and CSV import via DBeaver
- [ ] OTIF analysis queries — window functions and CTEs
- [ ] Star schema diagram — draw.io export to `/docs/`
- [ ] Power BI dashboard — 3 pages, mobile view
- [ ] Power BI Service deployment
- [ ] dbt staging + mart models *(Phase 1B — optional)*
- [ ] LinkedIn post — 3-card carousel

---

## 👤 Author

**Hemant** — Jr. BI & Data Engineer | Transitioning to Analytics & Data Engineering roles  
PL-300 · DP-900 · Google DA certified  
Power BI · DAX · SQL · PostgreSQL · Azure Databricks  
9.4 years — BIW Tooling Design (ThyssenKrupp · Tata Motors · COMAU) → Data

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?logo=linkedin&logoColor=white)](https://linkedin.com/in/<your-linkedin-handle>)
[![GitHub](https://img.shields.io/badge/GitHub-Hemant22121991-181717?logo=github&logoColor=white)](https://github.com/Hemant22121991)

---

## 📜 License

Data sourced from [Codebasics Resume Project Challenge #2](https://codebasics.io/challenge/codebasics-resume-project-challenge) — used for educational and portfolio purposes only.  
Code in this repository is available under the [MIT License](./LICENSE).

---

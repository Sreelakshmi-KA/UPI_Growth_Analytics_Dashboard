# UPI Growth & Adoption Analytics - Project Documentation

## 1. Overview

This project analyzes the growth of India's Unified Payments Interface (UPI) from launch (April 2016) to May 2026, using NPCI's official monthly "Product Statistics" reports. The goal was to turn 11 separate raw Excel exports into a clean, relational dataset and a 5-page interactive Power BI dashboard.

**Pipeline:** Excel (11 files) → Python (pandas) → MySQL → Power BI

**Dataset:** 122 monthly records, April 2016 – May 2026

**Headline results:** 119% Volume CAGR . 34x bank network growth (21 → 720 banks) . 775K million total transaction volume

---

## 2. Data Cleaning (Python / pandas)

Raw data arrived as 11 separate Excel workbooks, each needing the same cleaning steps. Key stages in `notebooks/UPI_Analysis.ipynb`:

1. **Ingestion** — used `glob` to programmatically find and loop through all 11 files, reading the "Product Statistics" sheet from each and concatenating them into one dataframe.
2. **Row-level cleaning** — dropped junk rows (titles, footnotes) by filtering for rows where the Month column actually resembles a date.
3. **Type conversion** — converted Volume, Value, and Banks columns from text to numeric, using `errors='coerce'` to safely handle any unparseable values, and converted Month to a proper datetime.
4. **Feature engineering** — derived Year, Month Number, Month Name, and Quarter from the date, plus a custom **Financial Year** column (April–March, matching India's fiscal calendar) built with a lambda function.
5. **Deduplication & export** — removed duplicate months, sorted chronologically, and exported to `upi_clean.csv` for the database load.

Result: 122 clean rows, 9 columns, zero nulls.

---

## 3. Database Layer (MySQL)

The cleaned CSV was loaded into a MySQL table (`upi_transactions`), with queries covering:

- **Aggregate rollups** — totals by calendar year, financial year, and quarter
- **Year-over-year growth** — calculated using the `LAG()` window function to compare each year's volume against the prior year, without a self-join
- **Peak detection** — a correlated subquery to find the highest-volume month within each year
- **COVID-era analysis** — isolating 2019–2021 to quantify the pandemic's effect on adoption
- **A reusable view** (`vw_upi_analysis`) exposing the cleaned, sorted dataset for downstream tools like Power BI

Full query set: `UPI_project_Sqlqueries.sql`

---

## 4. Power BI Model & DAX Measures

The Power BI model uses a single flat table sourced directly from MySQL, with Power BI's automatic date hierarchy powering time-intelligence calculations. Key measures include:

| Measure | Purpose |
|---|---|
| `Total Volume(M)` / `Total Value(Cr)` | Core aggregations |
| `Total Banks Live` | Latest bank count (MAX, not SUM) |
| `AVG Monthly Volume` / `AVG Monthly Value` | Per-month averages via `AVERAGEX` |
| `YOY Volume Growth %` / `YOY Value Growth %` | Year-over-year growth using `SAMEPERIODLASTYEAR()` |
| `YOY Growth %` | An alternate year-over-year calculation using explicit year filtering |
| `Volume CAGR` | Compound Annual Growth Rate (2017–2025) |
| `Peak Month` / `Peak Month Volume` | Identifies the highest-volume month in context |

Full DAX formulas are documented inline in the `.pbix` file (`powerbi/UPI_Transactions.pbix`).

---

## 5. Dashboard Pages

| Page | Purpose |
|---|---|
| **Executive Overview** | Headline KPIs and 10-year volume/value trend |
| **Growth Trends** | Year-over-year growth patterns with a Financial Year slicer |
| **FY Analysis** | Performance reframed on India's April–March financial year |
| **Bank Adoption** | Bank network growth and its correlation with transaction volume |
| **AI Insights** | Power BI's Key Influencers and Decomposition Tree visuals for automated driver analysis |

Screenshots of each page are in the `screenshots/` folder and embedded in the main [README](../README.md).

---

## 6. Key Insights

- UPI scaled from 21 participating banks at launch to 720 by May 2026 — a 34x expansion.
- Transaction volume grew from near-zero in 2016 to a peak of 228.3K million in 2025, a 119% compound annual growth rate.
- 2020, the pandemic year, saw the fastest pace of new bank onboarding — digital payment adoption accelerated rather than slowed during COVID-19.
- March is consistently the peak transaction month across nearly every financial year, likely tied to fiscal year-end activity.
- Bank network size (`Banks_Live`) is the strongest identified driver of transaction volume growth, per Power BI's Key Influencers analysis.

---

## 7. Tools & Techniques Demonstrated

`Python` · `pandas` · `MySQL` · `SQL window functions` · `correlated subqueries` · `Power BI` · `DAX` · `time intelligence` · `Power BI AI visuals`

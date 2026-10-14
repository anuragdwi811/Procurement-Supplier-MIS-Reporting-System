# Procurement & Supplier MIS Reporting System

**Tools:** PostgreSQL | SQL | Excel | Power Query | PivotTables | VBA | Power BI | DAX

An end-to-end procurement MIS and reporting project built to analyze purchase orders, supplier performance, procurement spend, delivery delays, and product quality. The project combines SQL-based reporting, an Excel MIS workbook, and interactive Power BI dashboards to support procurement monitoring and business decision-making.

## 1. Project Overview

Procurement teams need accurate information about purchase orders, supplier reliability, delivery performance, purchase costs, and product defects.

In this project, I developed a **Procurement & Supplier MIS Reporting System** using PostgreSQL, Excel, and Power BI. I used SQL to prepare business-focused reporting datasets, Excel to build operational MIS reports and refresh controls, and Power BI to present procurement performance through interactive dashboards.

The solution includes five SQL reporting files, an Excel MIS workbook, and a three-page Power BI report.

## 2. Project Objectives

- Monitor purchase orders and procurement spend.
- Evaluate supplier delivery performance and reliability.
- Track pending and overdue purchase orders.
- Analyze ordered, received, and defective quantities.
- Compare purchase costs with standard product costs.
- Prepare monthly procurement summaries and management reports.
- Build interactive dashboards for procurement and supplier analysis.

## 3. Business Questions

1. How many purchase orders have been received, cancelled, or remain open?
2. What is the total procurement spend, and how does it change month by month?
3. Which suppliers contribute the most to purchase spend?
4. Which suppliers have better fill rates and on-time delivery performance?
5. How many purchase orders are pending or overdue?
6. How do ordered quantities compare with received quantities?
7. What is the defect rate across procurement activities?
8. Which suppliers have higher purchase costs compared with standard product costs?
9. How does procurement performance vary across warehouses?
10. Which operational exceptions require follow-up?

## 4. Data Source

The data comes from my existing **E-commerce Analytics Database ETL** project.

**Source Repository:** [E-commerce Analytics Database ETL](https://github.com/anuragdwi811/e-commerce-analytics-database-etl)

The source project covers database preparation and data validation. For this project, I used the prepared PostgreSQL database tables to develop procurement reporting and dashboard analysis.

### Main Tables Used

| Table | Purpose |
|---|---|
| `procurement.purchase_orders` | Purchase order dates, status, supplier, warehouse, and order-level amount |
| `procurement.purchase_order_items` | Ordered and received quantities, item cost, and defect quantity |
| `master.suppliers` | Supplier details, type, location, rating, and standard lead time |
| `master.products` | Product information and standard product cost |
| `master.warehouses` | Warehouse details, location, region, and status |
| `master.categories` | Product category information |

## 5. Tools Used

| Tool | Purpose |
|---|---|
| PostgreSQL | Database storage and SQL reporting |
| SQL | Joins, CTEs, aggregations, business rules, and reporting datasets |
| Excel | Operational tracking, MIS reports, and management summaries |
| Power Query | Importing and refreshing SQL reporting outputs |
| PivotTables & PivotCharts | Summarizing procurement data and building Excel reports |
| VBA | Workbook refresh automation |
| Power BI | Interactive dashboards and business performance analysis |
| DAX | KPI calculations and analytical measures |

## 6. Project Workflow

1. **Data Source:** Used the prepared PostgreSQL database from the existing ETL project.
2. **SQL Reporting:** Created five reporting queries for procurement operations and supplier analysis.
3. **Excel Data Import:** Imported reporting outputs using Power Query.
4. **Excel MIS Development:** Created PO tracking, supplier performance, exceptions, and monthly reporting sheets.
5. **Refresh Control:** Added a workbook control page to support report refresh and navigation.
6. **Power BI Data Preparation:** Imported the required source tables and configured data relationships.
7. **DAX Measures:** Created measures for procurement spend, purchase orders, fill rate, defect rate, delivery performance, and pending orders.
8. **Dashboard Development:** Built three Power BI pages for procurement overview, supplier performance, and purchase order analysis.
9. **Business Analysis:** Used the reports to investigate supplier performance, procurement trends, and operational exceptions.

## 7. SQL Analysis

I created five SQL reporting files to support different procurement reporting requirements.

| SQL File | Purpose |
|---|---|
| `01_purchase_order_detail.sql` | Detailed purchase order and item-level tracking |
| `02_supplier_performance.sql` | Supplier performance scorecard |
| `03_pending_and_delayed_orders.sql` | Pending orders, overdue orders, and follow-up priorities |
| `04_purchase_cost_and_defects.sql` | Purchase cost variance and product defect analysis |
| `05_monthly_procurement_summary.sql` | Monthly procurement KPIs and trends |

### SQL Concepts Used

- Joins and Common Table Expressions (CTEs)
- Aggregate functions and `GROUP BY`
- `CASE` expressions for business classifications
- Window functions and ranking
- Date calculations for lead time and overdue analysis
- `NULLIF` for safe percentage calculations
- Aggregation at the correct reporting grain

### Important Data Rules

- Purchase order counts use distinct purchase order IDs when the data is at item level.
- Purchase order header amounts are not summed directly after joining to multiple item rows.
- Supplier attribution for purchase orders is based on the supplier recorded in the purchase order header.
- Delivery performance is evaluated using the available purchase order status and expected/received dates.
- The reporting cutoff date is **01-Jan-2026**, keeping overdue calculations reproducible.

## 8. Excel MIS Development

**Workbook:** `Procurement_Supplier_MIS_Reporting.xlsm`

The Excel workbook combines operational tracking, supplier reporting, management summaries, and refresh controls.

### Workbook Structure

| Sheet | Purpose |
|---|---|
| `Home_Control` | Project information, refresh button, refresh status, and report navigation |
| `MIS_Dashboard` | Management-level procurement KPIs and charts |
| `PO_Tracker` | Detailed purchase order and item tracking |
| `Supplier_Performance` | Supplier scorecards and performance metrics |
| `Exceptions_Report` | Pending, overdue, and partially received order follow-up |
| `Monthly_MIS` | Monthly procurement summary |
| `Raw_PO_Data` | Detailed SQL reporting output |
| `Raw_PO_Items` | Item-level procurement and cost/quality data |
| `Supplier_Master` | Supplier reference information |
| `Control_Lists` | Reporting parameters and controlled values |

### Excel Features

- Power Query for importing and refreshing PostgreSQL reporting outputs.
- Excel Tables with filters for operational reporting.
- PivotTables and PivotCharts for data summaries.
- Lookup, conditional, and aggregation formulas where required.
- Conditional formatting for pending orders, overdue items, and exceptions.
- A refresh control page with report navigation.
- VBA-based refresh automation for updating workbook data and reporting status.

## 9. Power BI Data Preparation and Modeling

The Power BI report uses the relevant PostgreSQL source tables for procurement, supplier, product, category, and warehouse analysis.

### Data Model

The model includes the following business tables:

- `purchase_orders`
- `purchase_order_items`
- `suppliers`
- `warehouses`
- `products`
- `categories`
- `Dim_Date`

Relationships are configured to connect purchase orders with their item records and to enable analysis by supplier, warehouse, product category, and date.

`Dim_Date` supports month, quarter, and year analysis. The model keeps purchase order header-level amounts separate from item-level quantities to avoid double-counting purchase spend.

### DAX Measures

The report includes measures for the main procurement KPIs, including:

- Total Purchase Spend
- Total POs
- Supplier Count
- Supplier Fill Rate
- Defect Rate
- Average Lead Time
- On-Time Delivery Rate
- Pending POs
- Overdue Open POs
- Pending Quantity
- Received POs
- Ordered Quantity
- Received Quantity

These measures support KPI cards, supplier comparisons, monthly trends, and operational analysis.

## 10. Power BI Dashboard Pages

The Power BI report contains three interactive pages.

### Page 1 — Procurement Overview

**Purpose:** Provide an overall view of procurement activity and performance.

**Key KPIs**
- Total Purchase Spend
- Total POs
- Supplier Fill Rate
- Defect Rate
- Average Lead Time

**Visuals**
- Monthly Purchase Spend
- Ordered vs Received Quantity
- PO Status Distribution
- Warehouse-wise Purchase Spend

**Slicers:** Month, PO Status, Supplier, Warehouse.

### Page 2 — Supplier Performance

**Purpose:** Compare suppliers based on spend, delivery performance, quality, and lead time.

**Key KPIs**
- Supplier Count
- Supplier Fill Rate
- Defect Rate
- Average Lead Time

**Visuals**
- Supplier-wise Purchase Spend
- Supplier Defect Rate
- Supplier Fill Rate
- Actual vs Standard Lead Time
- Supplier Performance Matrix

**Slicers:** Supplier, Supplier Type, Region, Month.

### Page 3 — Purchase Order Analysis

**Purpose:** Monitor purchase order status, pending quantities, overdue orders, and warehouse operations.

**Key KPIs**
- Total POs
- Pending POs
- Overdue Open POs
- Pending Quantity

**Visuals**
- PO Status by Month
- Ordered vs Received Quantity
- Overdue Open POs by Supplier
- Warehouse-wise PO Performance
- Detailed Purchase Order Matrix

**Slicers:** Month, Warehouse, Supplier, PO Status.

## 11. Key Business Insights

The dashboards support investigation of:

- Monthly changes in procurement spend and purchasing volume.
- Suppliers contributing the most to total purchase spend.
- Differences in supplier fill rates, defect rates, and delivery lead times.
- Pending and overdue purchase orders requiring operational follow-up.
- Differences between ordered and received quantities.
- Purchase cost variances compared with standard product costs.
- Warehouse-level differences in purchase order activity.

The findings should be interpreted using the selected reporting period, cutoff date, and the relevant KPI definitions.

## 12. Conclusion

This project demonstrates an end-to-end approach to procurement reporting by combining PostgreSQL, SQL, Excel, and Power BI.

It covers database querying, reporting dataset preparation, operational MIS development, workbook refresh automation, data modeling, DAX measures, and interactive dashboards. The resulting reports provide a structured way to monitor procurement spend, supplier performance, delivery exceptions, and purchase order activity.

## 13. Project Screenshots

### Power BI — Procurement Overview

![Procurement Overview](screenshots/01%20-%20Procurement%20Overview.png)

### Power BI — Supplier Performance

![Supplier Performance](screenshots/02%20-%20Supplier%20Performance.png)

### Power BI — Purchase Order Analysis

![Purchase Order Analysis](screenshots/03%20-%20Purchase%20Order%20Analysis.png)

### Excel — MIS Dashboard

![Excel MIS Dashboard](screenshots/05%20-%20Excel%20MIS%20Dashboard.png)

### PostgreSQL — SQL Reporting

See the SQL files in the [`sql`](sql/) folder for the reporting logic and output definitions.

### Power BI — Data Model and Relationships

![Power BI Data Model](screenshots/10%20-%20Data%20Model%20%26%20Relationships.png)

### Excel — Home Control

![Excel Home Control](screenshots/04%20-%20Home%20Control.png)

### Excel — PO Tracker

![Excel PO Tracker](screenshots/06%20-%20PO%20Tracker.png)

### Excel — Supplier Performance

![Excel Supplier Performance](screenshots/07%20-%20Supplier%20Performance.png)

### Excel — Exceptions Report

![Excel Exceptions Report](screenshots/08%20-%20Exceptions%20Report.png)

### Excel — Monthly MIS

![Excel Monthly MIS](screenshots/09%20-%20Monthly%20MIS.png)

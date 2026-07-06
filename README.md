# SQL Business Analytics Project

## 📌 Project Overview

This project demonstrates the development of a SQL Server data warehouse and the creation of customer and product analytics reports. It showcases SQL techniques used in Business Analytics to transform raw transactional data into meaningful business insights.

The project includes data modeling, data loading, business KPI reporting, customer analysis, and product performance analysis using SQL Server.

---

## 🎯 Objectives

* Design and build a retail data warehouse
* Import and manage customer, product, and sales data
* Generate customer analytics reports
* Generate product analytics reports
* Calculate key business performance metrics
* Demonstrate SQL skills used in Business Analytics

---

## 📂 Dataset

This project uses a retail sales dataset consisting of three CSV files.

| File                | Description                                                                                  |
| ------------------- | -------------------------------------------------------------------------------------------- |
| `dim_customers.csv` | Customer information including demographics and location.                                    |
| `dim_products.csv`  | Product details including category, subcategory, and cost.                                   |
| `fact_sales.csv`    | Sales transaction data containing customer, product, quantity, sales amount, and order date. |

---

## 🗂 Project Structure

```
SQL-Business-Analytics-Project
│
├── Dataset
│   ├── dim_customers.csv
│   ├── dim_products.csv
│   └── fact_sales.csv
│
├── SQL Scripts
│   ├── 01_Data_Warehouse_Setup.sql
│   ├── 02_Customer_Analytics_Report.sql
│   └── 03_Product_Analytics_Report.sql
│
└── README.md
```

---

## 🏗 Data Model

The project follows a **Star Schema** consisting of:

### Fact Table

* fact_sales

### Dimension Tables

* dim_customers
* dim_products

---

## 📊 Customer Analytics Report

The customer report includes:

* Total Orders
* Total Sales
* Total Quantity Purchased
* Customer Age
* Customer Segment
* Average Order Value
* Average Monthly Spending
* Customer Lifespan

---

## 📈 Product Analytics Report

The product report includes:

* Total Sales
* Total Orders
* Total Customers
* Product Performance
* Product Segmentation
* Average Order Revenue
* Average Monthly Revenue

---

## 🛠 SQL Concepts Used

* SQL Server
* SELECT
* WHERE
* GROUP BY
* ORDER BY
* CASE Statements
* Common Table Expressions (CTEs)
* Views
* Aggregate Functions
* Window Functions
* Ranking Functions
* Date Functions
* JOINS

---

## 💡 Business Insights

This project helps answer questions such as:

* Who are the highest-value customers?
* Which products generate the highest revenue?
* What is the average order value?
* How are customers segmented based on spending?
* Which products perform best across categories?

---

## 🚀 How to Run

1. Download the dataset files.
2. Open Microsoft SQL Server Management Studio (SSMS).
3. Execute `01_Data_Warehouse_Setup.sql`.
4. Run `02_Customer_Analytics_Report.sql`.
5. Run `03_Product_Analytics_Report.sql`.
6. Query the generated views to explore the reports.

---





Open to Business Analyst, Data Analyst, and Analytics Internship opportunities.


/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouseAnalytics' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, this script creates a schema called gold
	
WARNING:
    Running this script will drop the entire 'DataWarehouseAnalytics' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'DataWarehouseAnalytics' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouseAnalytics')
BEGIN
    ALTER DATABASE DataWarehouseAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouseAnalytics;
END;
GO

-- Create the 'DataWarehouseAnalytics' database
CREATE DATABASE DataWarehouseAnalytics;
GO

USE DataWarehouseAnalytics;
GO

-- Create Schemas

CREATE SCHEMA gold;
GO

CREATE TABLE gold.dim_customers (
	customer_key int PRIMARY KEY,
	customer_id int,
	customer_number nvarchar(50),
	first_name nvarchar(50),
	last_name nvarchar(50),
	country nvarchar(50),
	marital_status nvarchar(50),
	gender nvarchar(50),
	birthdate date,
	create_date date
);
GO

CREATE TABLE gold.dim_products(
	product_key int ,
	product_id int ,
	product_number nvarchar(50) ,
	product_name nvarchar(50) ,
	category_id nvarchar(50) ,
	category nvarchar(50) ,
	subcategory nvarchar(50) ,
	maintenance nvarchar(50) ,
	cost int,
	product_line nvarchar(50),
	start_date date 
);
GO

CREATE TABLE gold.fact_sales(
	order_number nvarchar(50),
	product_key int,
	customer_key int,
	order_date date,
	shipping_date date,
	due_date date,
	sales_amount int,
	quantity tinyint,
	price int 
);
GO

TRUNCATE TABLE gold.dim_customers;
GO

BULK INSERT gold.dim_customers
FROM 'G:\PROJECTS\sql data analytics portfolio project\sql-data-analytics-project\datasets\flat-files\dim_customers.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

TRUNCATE TABLE gold.dim_products;
GO

BULK INSERT gold.dim_products
FROM 'G:\PROJECTS\sql data analytics portfolio project\sql-data-analytics-project\datasets\flat-files\dim_products.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

TRUNCATE TABLE gold.fact_sales;
GO

BULK INSERT gold.fact_sales
FROM 'G:\PROJECTS\sql data analytics portfolio project\sql-data-analytics-project\datasets\flat-files\fact_sales.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

	-- CHANGE OVER TIME 

	-- YEARS WISE SALES 

	SELECT 
	      YEAR(order_date) AS Year,
	      SUM(sales_amount) AS Total_Sales,
	      COUNT(DISTINCT customer_key) AS Total_customer,
	      SUM(quantity) AS Total_Quantity 
	FROM gold.fact_sales
    WHERE order_date IS NOT NULL
	GROUP BY
	        YEAR(order_date)
	ORDER BY 
	        Total_Sales DESC;
	 
	 -- MONTHS WISE SALES
		
	SELECT 
	      MONTH(order_date) AS MONTH,
	      SUM(sales_amount) AS Total_Sales,
	      COUNT(DISTINCT customer_key) AS Total_customer,
	      SUM(quantity) AS Total_Quantity 
	FROM gold.fact_sales
    WHERE order_date IS NOT NULL
	GROUP BY 
	        MONTH(order_date)
	ORDER BY 
	        Total_Sales DESC;


	-- YEAR AND MONTH WISE SALES
	SELECT 
	      YEAR(order_date) AS Year,
	      MONTH(order_date) AS MONTH,
	      SUM(sales_amount) AS Total_Sales,
	      COUNT(DISTINCT customer_key) AS Total_customer,
	      SUM(quantity) AS Total_Quantity 
	FROM gold.fact_sales
    WHERE order_date IS NOT NULL
	GROUP BY 
	        YEAR(order_date),
			MONTH(order_date)
	ORDER BY 
	        Total_Sales DESC;
	 

	 -- CUMUTATIVE ANALYSIS 

	 -- CALCULATE TOTAL SALES PER MONTH
	 -- AND THE RUNNING TOTAL OF SALES OVER TIME AND MOVING AVG OVER TIME

	 SELECT
	       Order_Date,
	       Total_Sales,
	       Avg_price,
	       SUM(Total_Sales) OVER(PARTITION BY YEAR(Order_Date) ORDER BY Order_Date) AS Running_Total_Sales,
	       AVG(Avg_price) OVER(PARTITION BY YEAR(Order_Date) ORDER BY Order_Date) AS Running_Avg_price
	 FROM
     (
	 SELECT
	       DATETRUNC(MONTH,order_date) AS Order_Date,
	       SUM(sales_amount) AS Total_Sales,
	       AVG(price) AS Avg_price
	 FROM gold.fact_sales
	 WHERE order_date IS NOT NULL
	 GROUP BY  
	         DATETRUNC(MONTH,order_date)
	 )T ;


	 -- performance analysis


	 WITH Yearly_Product_Sales AS (
	 SELECT 
	       YEAR(f.order_date) AS Order_year,
	       p.product_name,
	       SUM(sales_amount) AS Current_Sales
	 FROM gold.fact_sales f
	 LEFT JOIN gold.dim_products p
	 ON f.product_key = p.product_key
	 WHERE order_date IS NOT NULL
	 GROUP BY 
	         product_name,
	         YEAR(f.order_date),
	         p.product_name
	 )
     SELECT 
	       Order_year,
	       product_name,
	       Current_Sales,
	       AVG(Current_Sales) OVER ( PARTITION BY product_name ) AS Avg_Sales,
	       Current_Sales -  AVG(Current_Sales) OVER ( PARTITION BY product_name ) AS Diff_avg,
	       CASE WHEN Current_Sales -  AVG(Current_Sales) OVER ( PARTITION BY product_name ) > 0 THEN 'Above Avg'
	       WHEN Current_Sales -  AVG(Current_Sales) OVER ( PARTITION BY product_name ) < 0 THEN 'Below Avg'
		   ELSE 'Avg'
	       END avg_change,
	       LAG(Current_Sales) OVER(PARTITION BY product_name ORDER BY Order_year ) AS PY_Sales,
	       Current_Sales - LAG(Current_Sales) OVER(PARTITION BY product_name ORDER BY Order_year )  AS Diff_PY,
	       CASE WHEN Current_Sales -  LAG(Current_Sales) OVER(PARTITION BY product_name ORDER BY Order_year ) > 0 THEN 'Increase'
	       WHEN Current_Sales -  LAG(Current_Sales) OVER(PARTITION BY product_name ORDER BY Order_year ) < 0 THEN 'Decrease'
		   ELSE 'No change'
	       END PY_change

	 FROM  Yearly_Product_Sales
	 ORDER BY 
	         product_name, 
	         Order_year


	 -- PART OF WHOLE ANALYSIS
	 
	 -- WHICH CATEGORY CONTRIBUTES MOST TO THE REVENUE

	 WITH Category_sales AS (
	 SELECT 
	       category,
	       SUM(sales_amount) AS Total_sales
 	 FROM gold.fact_sales f
	 LEFT JOIN gold.dim_products p
	 ON f.product_key = p.product_key 
	 GROUP BY
	         category )

	 SELECT 
	       category,
	       Total_sales,
	       SUM(Total_sales) OVER() AS Overall_Sales,
	       CONCAT(ROUND((CAST(Total_sales AS FLOAT) / SUM(Total_sales) OVER()) * 100 , 2),'%' )AS Percentage_of_total
	 FROM Category_sales ;



	 -- DATA SEGMENTATION

	 /*Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
     And find the total number of customers by each group */

   WITH Customer_Spending AS (
   SELECT 
          c.customer_key,
          SUM(f.sales_amount) AS Total_Spending,
          MIN(order_date) AS First_order,
          MAX(order_date) AS Last_order,
          DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS Lifespan
   FROM gold.fact_sales f
   LEFT JOIN gold.dim_customers AS c
   ON f.customer_key = c.customer_key
   GROUP BY 
            c.customer_key )

   SELECT 
         Customer_segment,
         COUNT(customer_key) AS Total_customers
   FROM (
   SELECT 
          customer_key,
          Total_Spending,
           Lifespan,
          CASE WHEN Lifespan >=12 AND  Total_Spending > 5000 THEN 'VIP'
          WHEN Lifespan >=12 AND  Total_Spending <= 5000 THEN 'Regular'
		  ELSE 'New'
		  END AS Customer_segment
   FROM Customer_Spending ) t
   GROUP BY 
           Customer_segment
   ORDER BY 
           Total_customers

   
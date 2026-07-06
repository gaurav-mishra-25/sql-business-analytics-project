/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
=============================================================================== */
   
	USE DataWarehouseAnalytics ;
	CREATE VIEW gold_report_customer AS
	WITH base_query AS(
	/*---------------------------------------------------------------------------
    1) Base Query: Retrieves core columns from tables
    ---------------------------------------------------------------------------*/
	SELECT  
		f.order_number,
		f.product_key,
		f.order_date,
		f.sales_amount,
		f.quantity,
		c.customer_key,
		c.customer_number,
		CONCAT(c.first_name , ' ',c.last_name) AS Name,
		DATEDIFF(YEAR,c.birthdate,GETDATE()) AS Age
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c
	ON f.customer_key = c.customer_key
	WHERE order_date IS NOT NULL )

   ,Customer_aggregation AS (
		/*---------------------------------------------------------------------------
          2) Customer Aggregations: Summarizes key metrics at the customer level
         ---------------------------------------------------------------------------*/
   SELECT 
		customer_key,
		customer_number,
		Name,
		Age,
		COUNT(DISTINCT order_number) AS Total_Orders,
		SUM(sales_amount) AS Total_Sales,
		SUM(quantity) AS Total_quantity,
		COUNT(DISTINCT product_key) AS Total_Product,
		MAX(order_date) AS Last_Order_Date,
		DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS LifeSpan
	FROM base_query
	GROUP BY 
	         customer_key,
		     customer_number,
		     Name,
		     Age 
	)
	
/*---------------------------------------------------------------------------
  3) Final Query: Combines all customer results into one output
---------------------------------------------------------------------------*/
	SELECT 
	       customer_key,
		   customer_number,
		   Name,
	       Age ,
		   CASE 
		       WHEN Age < 20 THEN 'Under 20'
			   WHEN Age BETWEEN 20 AND 29 THEN '20-29'
			   WHEN Age BETWEEN 30 AND 39 THEN '30-39'
			   WHEN Age BETWEEN 40 AND 49 THEN '40-49'
			   ELSE '50 And Above'
		   END AS Age_groups,
		   CASE 
		       WHEN LifeSpan >= 12 AND Total_Sales > 5000 THEN 'VIP'
			   WHEN LifeSpan >= 12 AND Total_Sales < 5000 THEN 'Regular'
			   ELSE 'New'
			END AS Customer_segment,
		   Total_Orders,
		   Total_Sales,
		   Total_quantity,
		   Total_Product,
	       Last_Order_Date,
		   LifeSpan,
		   DATEDIFF(MONTH,Last_Order_Date,GETDATE()) AS Recency,
		   ---- Compuate average order value (AVO)
		   CASE 
		       WHEN Total_Orders = 0 THEN 0
			   ELSE Total_Sales/Total_Orders 
		   END AS AVG_Order_Value,

		   -- Compuate average monthly spend
		   CASE 
               WHEN LifeSpan = 0 THEN Total_Sales
			   ELSE Total_Sales/ LifeSpan 
			END AS Avg_Monthly_Sales

	FROM Customer_aggregation;


	SELECT * FROM gold_report_customer;
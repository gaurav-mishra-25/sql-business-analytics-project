/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/
-- =============================================================================
-- Create Report: gold.report_products
-- ====================================
  

    USE DataWarehouseAnalytics;

    CREATE VIEW gold_report_product AS
    WITH base_query AS (
    /*---------------------------------------------------------------------------
    1) Base Query: Retrieves core columns from tables
    ---------------------------------------------------------------------------*/
    SELECT 
          p.product_key,
          p.product_name,
          p.category,
          p.subcategory,
          p.cost,
          f.order_number,
          f.customer_key,
          f.sales_amount,
          f.quantity,
          f.order_date
          
    FROM gold.dim_products p
    LEFT JOIN gold.fact_sales f
    ON p.product_key = f.product_key 
    WHERE order_date IS NOT NULL )

    , product_aggregation AS(
    /*---------------------------------------------------------------------------
2) Product Aggregations: Summarizes key metrics at the product level
---------------------------------------------------------------------------*/
    SELECT 
          product_key,
          product_name,
          category,
          subcategory,
          cost,
          COUNT(DISTINCT order_number) AS Total_Orders,
          SUM(sales_amount) AS Total_Sales,
          SUM(quantity) AS Total_quantity_sold,
          MAX(order_date) AS Last_sale_date,
          DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS Lifespan

    FROM base_query
    GROUP BY  
          product_key,
          product_name,
          category,
          subcategory,
          cost 
                        )
    
/*---------------------------------------------------------------------------
  3) Final Query: Combines all product results into one output
---------------------------------------------------------------------------*/
    SELECT 
          product_key,
          product_name,
          category,
          subcategory,
          cost,
          Total_Orders,
          Total_Sales,
          Total_quantity_sold,
          Last_sale_date,
          DATEDIFF(MONTH,Last_sale_date,GETDATE()) AS Recency,
          CASE 
               WHEN Total_Sales > 50000 THEN 'High-Performer'
               WHEN Total_Sales >=10000 THEN 'Mid_Range'
               ELSE 'Low-Performer'
          END AS product_segment,
          Lifespan,

          -- AVG ORDER REVENUE 
          CASE 
              WHEN Total_Orders = 0 THEN 0
              ELSE Total_Sales/Total_Orders
          END AS Avg_Order_revenue,

          -- AVG MONTHLY REVENUE
          CASE 
              WHEN Lifespan = 0 THEN Total_sales
              ELSE Total_Sales/Lifespan
          END AS Avg_monthly_revenue

    FROM product_aggregation



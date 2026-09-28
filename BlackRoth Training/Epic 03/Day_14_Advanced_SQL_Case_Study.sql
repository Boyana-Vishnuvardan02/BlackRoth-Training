USE sales_analysis_db;

--  DATABASE INSPECTION & RELATIONSHIPS

-- Q01. Inspect customers table
SELECT * FROM customers LIMIT 20;

-- Q02. Inspect products table
SELECT * FROM products LIMIT 20;

-- Q03. Inspect orders table
SELECT * FROM orders LIMIT 20;

-- Q04. Inspect order_items table
SELECT * FROM order_items LIMIT 20;

-- Q05. Check row counts
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items;

-- Q06. Check duplicate customer IDs
SELECT Customer_Id, COUNT(*) AS duplicate_count
FROM customers
GROUP BY Customer_Id
HAVING COUNT(*) > 1;

-- Q07. Check duplicate product IDs
SELECT Product_Id, COUNT(*) AS duplicate_count
FROM products
GROUP BY Product_Id
HAVING COUNT(*) > 1;

-- Q08. Check duplicate order IDs
SELECT Order_Id, COUNT(*) AS duplicate_count
FROM orders
GROUP BY Order_Id
HAVING COUNT(*) > 1;

-- Q09. Check NULLs in key customer fields
SELECT
    SUM(Customer_Id IS NULL) AS null_customer_id,
    SUM(Customer_name IS NULL) AS null_customer_name,
    SUM(City IS NULL) AS null_city,
    SUM(State IS NULL) AS null_state,
    SUM(Registration_Date IS NULL) AS null_registration_date
FROM customers;

-- Q10. Check NULLs in products
SELECT
    SUM(Product_Id IS NULL) AS null_product_id,
    SUM(Product_Name IS NULL) AS null_product_name,
    SUM(Category IS NULL) AS null_category,
    SUM(Price IS NULL) AS null_price
FROM products;

-- Q11. Check NULLs in orders
SELECT
    SUM(Order_Id IS NULL) AS null_order_id,
    SUM(Customer_Id IS NULL) AS null_customer_id,
    SUM(Order_Date IS NULL) AS null_order_date,
    SUM(Order_Status IS NULL) AS null_order_status
FROM orders;

-- Q12. Check NULLs in order_items
SELECT
    SUM(Order_Item_Id IS NULL) AS null_order_item_id,
    SUM(Order_Id IS NULL) AS null_order_id,
    SUM(Product_Id IS NULL) AS null_product_id,
    SUM(Quantity IS NULL) AS null_quantity,
    SUM(Unit_Price IS NULL) AS null_unit_price
FROM order_items;

-- Q13. Find orphan order_items whose order does not exist
SELECT oi.*
FROM order_items oi
LEFT JOIN orders o ON oi.Order_Id = o.Order_Id
WHERE o.Order_Id IS NULL;

-- Q14. Find orphan order_items whose product does not exist
SELECT oi.*
FROM order_items oi
LEFT JOIN products p ON oi.Product_Id = p.Product_Id
WHERE p.Product_Id IS NULL;

-- Q15. Find orders whose customer does not exist
SELECT o.*
FROM orders o
LEFT JOIN customers c ON o.Customer_Id = c.Customer_Id
WHERE c.Customer_Id IS NULL;

-- Q16. Inspect order statuses
SELECT Order_Status, COUNT(*) AS order_count
FROM orders
GROUP BY Order_Status
ORDER BY order_count DESC;


-- OVERALL KPIs

-- Q17. Total revenue
SELECT ROUND(SUM(oi.Quantity * oi.Unit_Price), 2) AS total_revenue
FROM order_items oi;

-- Q18. Total orders
SELECT COUNT(DISTINCT Order_Id) AS total_orders
FROM order_items;

-- Q19. Total customers
SELECT COUNT(DISTINCT Customer_Id) AS total_customers
FROM customers;

-- Q20. Total quantity sold
SELECT SUM(Quantity) AS total_quantity
FROM order_items;

-- Q21. Average Order Value
WITH order_values AS (
    SELECT Order_Id, SUM(Quantity * Unit_Price) AS order_value
    FROM order_items
    GROUP BY Order_Id
)
SELECT ROUND(AVG(order_value), 2) AS average_order_value
FROM order_values;

-- Q22. All five core KPIs in one query
WITH order_values AS (
    SELECT Order_Id, SUM(Quantity * Unit_Price) AS order_value
    FROM order_items
    GROUP BY Order_Id
)
SELECT
    ROUND((SELECT SUM(Quantity * Unit_Price) FROM order_items), 2) AS total_revenue,
    (SELECT COUNT(DISTINCT Order_Id) FROM order_items) AS total_orders,
    (SELECT COUNT(*) FROM customers) AS total_customers,
    ROUND((SELECT AVG(order_value) FROM order_values), 2) AS average_order_value,
    (SELECT SUM(Quantity) FROM order_items) AS total_quantity;


-- PERFORMANCE ANALYSIS

-- Q23. Top 10 products by revenue
SELECT
    p.Product_Id,
    p.Product_Name,
    p.Category,
    ROUND(SUM(oi.Quantity * oi.Unit_Price), 2) AS revenue
FROM products p
JOIN order_items oi ON p.Product_Id = oi.Product_Id
GROUP BY p.Product_Id, p.Product_Name, p.Category
ORDER BY revenue DESC
LIMIT 10;

-- Q24. Top 10 customers by spending
SELECT
    c.Customer_Id,
    c.Customer_name,
    c.City,
    c.State,
    ROUND(SUM(oi.Quantity * oi.Unit_Price), 2) AS total_spending
FROM customers c
JOIN orders o ON c.Customer_Id = o.Customer_Id
JOIN order_items oi ON o.Order_Id = oi.Order_Id
GROUP BY c.Customer_Id, c.Customer_name, c.City, c.State
ORDER BY total_spending DESC
LIMIT 10;

-- Q25. Category revenue
SELECT
    p.Category,
    ROUND(SUM(oi.Quantity * oi.Unit_Price), 2) AS revenue,
    SUM(oi.Quantity) AS quantity_sold
FROM products p
JOIN order_items oi ON p.Product_Id = oi.Product_Id
GROUP BY p.Category
ORDER BY revenue DESC;

-- Q26. Region/state revenue
SELECT
    c.State,
    ROUND(SUM(oi.Quantity * oi.Unit_Price), 2) AS revenue,
    COUNT(DISTINCT o.Order_Id) AS total_orders,
    COUNT(DISTINCT c.Customer_Id) AS customers
FROM customers c
JOIN orders o ON c.Customer_Id = o.Customer_Id
JOIN order_items oi ON o.Order_Id = oi.Order_Id
GROUP BY c.State
ORDER BY revenue DESC;

-- Q27. City revenue
SELECT
    c.City,
    ROUND(SUM(oi.Quantity * oi.Unit_Price), 2) AS revenue
FROM customers c
JOIN orders o ON c.Customer_Id = o.Customer_Id
JOIN order_items oi ON o.Order_Id = oi.Order_Id
GROUP BY c.City
ORDER BY revenue DESC;

-- Q28. Product quantity performance
SELECT
    p.Product_Name,
    SUM(oi.Quantity) AS quantity_sold
FROM products p
JOIN order_items oi ON p.Product_Id = oi.Product_Id
GROUP BY p.Product_Id, p.Product_Name
ORDER BY quantity_sold DESC;

-- Q29. Category average selling price
SELECT
    p.Category,
    ROUND(AVG(oi.Unit_Price), 2) AS average_selling_price
FROM products p
JOIN order_items oi ON p.Product_Id = oi.Product_Id
GROUP BY p.Category
ORDER BY average_selling_price DESC;


-- MONTHLY TRENDS & MOM GROWTH

-- Q30. Monthly revenue
SELECT
    DATE_FORMAT(o.Order_Date, '%Y-%m') AS month,
    ROUND(SUM(oi.Quantity * oi.Unit_Price), 2) AS monthly_revenue
FROM orders o
JOIN order_items oi ON o.Order_Id = oi.Order_Id
GROUP BY DATE_FORMAT(o.Order_Date, '%Y-%m')
ORDER BY month;

-- Q31. Monthly orders and quantity
SELECT
    DATE_FORMAT(o.Order_Date, '%Y-%m') AS month,
    COUNT(DISTINCT o.Order_Id) AS orders,
    SUM(oi.Quantity) AS quantity
FROM orders o
JOIN order_items oi ON o.Order_Id = oi.Order_Id
GROUP BY DATE_FORMAT(o.Order_Date, '%Y-%m')
ORDER BY month;

-- Q32. Month-over-month revenue growth
WITH monthly AS (
    SELECT
        DATE_FORMAT(o.Order_Date, '%Y-%m') AS month,
        SUM(oi.Quantity * oi.Unit_Price) AS revenue
    FROM orders o
    JOIN order_items oi ON o.Order_Id = oi.Order_Id
    GROUP BY DATE_FORMAT(o.Order_Date, '%Y-%m')
),
comparison AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month) AS previous_revenue
    FROM monthly
)
SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_revenue, 2) AS previous_revenue,
    ROUND(
        (revenue - previous_revenue) / NULLIF(previous_revenue, 0) * 100,
        2
    ) AS mom_growth_pct
FROM comparison
ORDER BY month;

-- Q33. Cumulative revenue
WITH monthly AS (
    SELECT
        DATE_FORMAT(o.Order_Date, '%Y-%m') AS month,
        SUM(oi.Quantity * oi.Unit_Price) AS revenue
    FROM orders o
    JOIN order_items oi ON o.Order_Id = oi.Order_Id
    GROUP BY DATE_FORMAT(o.Order_Date, '%Y-%m')
)
SELECT
    month,
    ROUND(revenue, 2) AS monthly_revenue,
    ROUND(
        SUM(revenue) OVER (ORDER BY month),
        2
    ) AS cumulative_revenue
FROM monthly
ORDER BY month;

-- Q34. Monthly AOV
WITH monthly_orders AS (
    SELECT
        o.Order_Id,
        DATE_FORMAT(o.Order_Date, '%Y-%m') AS month,
        SUM(oi.Quantity * oi.Unit_Price) AS order_value
    FROM orders o
    JOIN order_items oi ON o.Order_Id = oi.Order_Id
    GROUP BY o.Order_Id, DATE_FORMAT(o.Order_Date, '%Y-%m')
)
SELECT
    month,
    ROUND(AVG(order_value), 2) AS monthly_aov
FROM monthly_orders
GROUP BY month
ORDER BY month;

-- Q35. Best revenue month
WITH monthly AS (
    SELECT
        DATE_FORMAT(o.Order_Date, '%Y-%m') AS month,
        SUM(oi.Quantity * oi.Unit_Price) AS revenue
    FROM orders o
    JOIN order_items oi ON o.Order_Id = oi.Order_Id
    GROUP BY DATE_FORMAT(o.Order_Date, '%Y-%m')
)
SELECT month, ROUND(revenue, 2) AS revenue
FROM monthly
ORDER BY revenue DESC
LIMIT 1;

-- Q36. Lowest revenue month
WITH monthly AS (
    SELECT
        DATE_FORMAT(o.Order_Date, '%Y-%m') AS month,
        SUM(oi.Quantity * oi.Unit_Price) AS revenue
    FROM orders o
    JOIN order_items oi ON o.Order_Id = oi.Order_Id
    GROUP BY DATE_FORMAT(o.Order_Date, '%Y-%m')
)
SELECT month, ROUND(revenue, 2) AS revenue
FROM monthly
ORDER BY revenue
LIMIT 1;


--  WINDOW FUNCTIONS & RANKING

-- Q37. Rank all products by revenue
WITH product_sales AS (
    SELECT
        p.Product_Id,
        p.Product_Name,
        p.Category,
        SUM(oi.Quantity * oi.Unit_Price) AS revenue
    FROM products p
    JOIN order_items oi ON p.Product_Id = oi.Product_Id
    GROUP BY p.Product_Id, p.Product_Name, p.Category
)
SELECT
    Product_Id,
    Product_Name,
    Category,
    ROUND(revenue, 2) AS revenue,
    RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM product_sales
ORDER BY revenue_rank;

-- Q38. Rank customers by spending
WITH customer_sales AS (
    SELECT
        c.Customer_Id,
        c.Customer_name,
        SUM(oi.Quantity * oi.Unit_Price) AS spending
    FROM customers c
    JOIN orders o ON c.Customer_Id = o.Customer_Id
    JOIN order_items oi ON o.Order_Id = oi.Order_Id
    GROUP BY c.Customer_Id, c.Customer_name
)
SELECT
    Customer_Id,
    Customer_name,
    ROUND(spending, 2) AS spending,
    RANK() OVER (ORDER BY spending DESC) AS spending_rank
FROM customer_sales
ORDER BY spending_rank;

-- Q39. Dense rank products
WITH product_sales AS (
    SELECT
        p.Product_Id,
        p.Product_Name,
        SUM(oi.Quantity * oi.Unit_Price) AS revenue
    FROM products p
    JOIN order_items oi ON p.Product_Id = oi.Product_Id
    GROUP BY p.Product_Id, p.Product_Name
)
SELECT
    Product_Name,
    ROUND(revenue, 2) AS revenue,
    DENSE_RANK() OVER (ORDER BY revenue DESC) AS dense_rankK
FROM product_sales;

-- Q40. Top 3 products in each category
WITH product_sales AS (
    SELECT
        p.Product_Id,
        p.Product_Name,
        p.Category,
        SUM(oi.Quantity * oi.Unit_Price) AS revenue
    FROM products p
    JOIN order_items oi ON p.Product_Id = oi.Product_Id
    GROUP BY p.Product_Id, p.Product_Name, p.Category
),
ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY Category
               ORDER BY revenue DESC
           ) AS category_rank
    FROM product_sales
)
SELECT
    Product_Id,
    Product_Name,
    Category,
    ROUND(revenue, 2) AS revenue,
    category_rank
FROM ranked
WHERE category_rank <= 3
ORDER BY Category, category_rank;

-- Q41. Top 3 customers in each state
WITH customer_sales AS (
    SELECT
        c.Customer_Id,
        c.Customer_name,
        c.State,
        SUM(oi.Quantity * oi.Unit_Price) AS spending
    FROM customers c
    JOIN orders o ON c.Customer_Id = o.Customer_Id
    JOIN order_items oi ON o.Order_Id = oi.Order_Id
    GROUP BY c.Customer_Id, c.Customer_name, c.State
),
ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY State
               ORDER BY spending DESC
           ) AS state_rank
    FROM customer_sales
)
SELECT *
FROM ranked
WHERE state_rank <= 3
ORDER BY State, state_rank;

-- Q42. Compare each product with previous monthly revenue
WITH product_monthly AS (
    SELECT
        p.Product_Id,
        p.Product_Name,
        DATE_FORMAT(o.Order_Date, '%Y-%m') AS month,
        SUM(oi.Quantity * oi.Unit_Price) AS revenue
    FROM products p
    JOIN order_items oi ON p.Product_Id = oi.Product_Id
    JOIN orders o ON oi.Order_Id = o.Order_Id
    GROUP BY p.Product_Id, p.Product_Name, DATE_FORMAT(o.Order_Date, '%Y-%m')
)
SELECT
    Product_Id,
    Product_Name,
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(LAG(revenue) OVER (
        PARTITION BY Product_Id ORDER BY month
    ), 2) AS previous_month_revenue
FROM product_monthly
ORDER BY Product_Name, month;


-- SUBQUERIES & ABOVE-AVERAGE ANALYSIS

-- Q43. Customers spending above average customer spending
WITH customer_sales AS (
    SELECT
        c.Customer_Id,
        c.Customer_name,
        SUM(oi.Quantity * oi.Unit_Price) AS spending
    FROM customers c
    JOIN orders o ON c.Customer_Id = o.Customer_Id
    JOIN order_items oi ON o.Order_Id = oi.Order_Id
    GROUP BY c.Customer_Id, c.Customer_name
)
SELECT *
FROM customer_sales
WHERE spending > (SELECT AVG(spending) FROM customer_sales)
ORDER BY spending DESC;

-- Q44. Products with revenue above average product revenue
WITH product_sales AS (
    SELECT
        p.Product_Id,
        p.Product_Name,
        SUM(oi.Quantity * oi.Unit_Price) AS revenue
    FROM products p
    JOIN order_items oi ON p.Product_Id = oi.Product_Id
    GROUP BY p.Product_Id, p.Product_Name
)
SELECT *
FROM product_sales
WHERE revenue > (SELECT AVG(revenue) FROM product_sales)
ORDER BY revenue DESC;

-- Q45. Products priced above average price
SELECT Product_Id, Product_Name, Category, Price
FROM products
WHERE Price > (SELECT AVG(Price) FROM products)
ORDER BY Price DESC;

-- Q46. Customers who placed at least one order using IN
SELECT Customer_Id, Customer_name
FROM customers
WHERE Customer_Id IN (
    SELECT DISTINCT Customer_Id
    FROM orders
);

-- Q47. Customers who placed at least one order using EXISTS
SELECT c.Customer_Id, c.Customer_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.Customer_Id = c.Customer_Id
);

-- Q48. Customers with no orders
SELECT c.Customer_Id, c.Customer_name
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.Customer_Id = c.Customer_Id
);

-- Q49. Products never sold
SELECT p.Product_Id, p.Product_Name, p.Category
FROM products p
WHERE NOT EXISTS (
    SELECT 1
    FROM order_items oi
    WHERE oi.Product_Id = p.Product_Id
);

-- Q50. Customers spending more than the overall average order value
WITH customer_sales AS (
    SELECT
        c.Customer_Id,
        c.Customer_name,
        SUM(oi.Quantity * oi.Unit_Price) AS spending
    FROM customers c
    JOIN orders o ON c.Customer_Id = o.Customer_Id
    JOIN order_items oi ON o.Order_Id = oi.Order_Id
    GROUP BY c.Customer_Id, c.Customer_name
),
order_values AS (
    SELECT Order_Id, SUM(Quantity * Unit_Price) AS order_value
    FROM order_items
    GROUP BY Order_Id
)
SELECT *
FROM customer_sales
WHERE spending > (SELECT AVG(order_value) FROM order_values)
ORDER BY spending DESC;


-- CASE-BASED CUSTOMER SEGMENTATION

-- Q51. Segment customers by total spending
WITH customer_sales AS (
    SELECT
        c.Customer_Id,
        c.Customer_name,
        COALESCE(SUM(oi.Quantity * oi.Unit_Price), 0) AS spending
    FROM customers c
    LEFT JOIN orders o ON c.Customer_Id = o.Customer_Id
    LEFT JOIN order_items oi ON o.Order_Id = oi.Order_Id
    GROUP BY c.Customer_Id, c.Customer_name
)
SELECT
    Customer_Id,
    Customer_name,
    ROUND(spending, 2) AS spending,
    CASE
        WHEN spending >= 100000 THEN 'HIGH VALUE'
        WHEN spending >= 50000 THEN 'MEDIUM VALUE'
        ELSE 'LOW VALUE'
    END AS customer_segment
FROM customer_sales
ORDER BY spending DESC;

-- Q52. Segment products by revenue
WITH product_sales AS (
    SELECT
        p.Product_Id,
        p.Product_Name,
        COALESCE(SUM(oi.Quantity * oi.Unit_Price), 0) AS revenue
    FROM products p
    LEFT JOIN order_items oi ON p.Product_Id = oi.Product_Id
    GROUP BY p.Product_Id, p.Product_Name
)
SELECT
    Product_Id,
    Product_Name,
    ROUND(revenue, 2) AS revenue,
    CASE
        WHEN revenue >= 100000 THEN 'HIGH'
        WHEN revenue >= 50000 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS revenue_segment
FROM product_sales
ORDER BY revenue DESC;

-- Q53. Customer activity segment
WITH customer_activity AS (
    SELECT
        c.Customer_Id,
        c.Customer_name,
        COUNT(DISTINCT o.Order_Id) AS order_count
    FROM customers c
    LEFT JOIN orders o ON c.Customer_Id = o.Customer_Id
    GROUP BY c.Customer_Id, c.Customer_name
)
SELECT
    Customer_Id,
    Customer_name,
    order_count,
    CASE
        WHEN order_count = 0 THEN 'INACTIVE'
        WHEN order_count = 1 THEN 'LOW ACTIVITY'
        WHEN order_count BETWEEN 2 AND 5 THEN 'MEDIUM ACTIVITY'
        ELSE 'HIGH ACTIVITY'
    END AS activity_segment
FROM customer_activity
ORDER BY order_count DESC;


--  CONTRIBUTION & CUMULATIVE ANALYSIS

-- Q54. Product contribution percentage
WITH product_sales AS (
    SELECT
        p.Product_Id,
        p.Product_Name,
        SUM(oi.Quantity * oi.Unit_Price) AS revenue
    FROM products p
    JOIN order_items oi ON p.Product_Id = oi.Product_Id
    GROUP BY p.Product_Id, p.Product_Name
)
SELECT
    Product_Id,
    Product_Name,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        revenue / NULLIF(SUM(revenue) OVER (), 0) * 100,
        2
    ) AS contribution_pct
FROM product_sales
ORDER BY contribution_pct DESC;

-- Q55. Category contribution percentage
WITH category_sales AS (
    SELECT
        p.Category,
        SUM(oi.Quantity * oi.Unit_Price) AS revenue
    FROM products p
    JOIN order_items oi ON p.Product_Id = oi.Product_Id
    GROUP BY p.Category
)
SELECT
    Category,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        revenue / NULLIF(SUM(revenue) OVER (), 0) * 100,
        2
    ) AS contribution_pct
FROM category_sales
ORDER BY contribution_pct DESC;

-- Q56. Cumulative product revenue
WITH product_sales AS (
    SELECT
        p.Product_Id,
        p.Product_Name,
        SUM(oi.Quantity * oi.Unit_Price) AS revenue
    FROM products p
    JOIN order_items oi ON p.Product_Id = oi.Product_Id
    GROUP BY p.Product_Id, p.Product_Name
)
SELECT
    Product_Id,
    Product_Name,
    ROUND(revenue, 2) AS revenue,
    ROUND(SUM(revenue) OVER (ORDER BY revenue DESC), 2) AS cumulative_revenue
FROM product_sales
ORDER BY revenue DESC;


--  DECLINING / HIGH-GROWTH PRODUCTS

-- Q57. Products with month-over-month decline
WITH product_monthly AS (
    SELECT
        p.Product_Id,
        p.Product_Name,
        DATE_FORMAT(o.Order_Date, '%Y-%m') AS month,
        SUM(oi.Quantity * oi.Unit_Price) AS revenue
    FROM products p
    JOIN order_items oi ON p.Product_Id = oi.Product_Id
    JOIN orders o ON oi.Order_Id = o.Order_Id
    GROUP BY p.Product_Id, p.Product_Name, DATE_FORMAT(o.Order_Date, '%Y-%m')
),
comparison AS (
    SELECT
        Product_Id,
        Product_Name,
        month,
        revenue,
        LAG(revenue) OVER (
            PARTITION BY Product_Id ORDER BY month
        ) AS previous_revenue
    FROM product_monthly
)
SELECT
    Product_Id,
    Product_Name,
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_revenue, 2) AS previous_revenue,
    ROUND((revenue - previous_revenue) / NULLIF(previous_revenue, 0) * 100, 2) AS growth_pct
FROM comparison
WHERE previous_revenue IS NOT NULL
  AND revenue < previous_revenue
ORDER BY growth_pct;

-- Q58. Products with positive month-over-month growth
WITH product_monthly AS (
    SELECT
        p.Product_Id,
        p.Product_Name,
        DATE_FORMAT(o.Order_Date, '%Y-%m') AS month,
        SUM(oi.Quantity * oi.Unit_Price) AS revenue
    FROM products p
    JOIN order_items oi ON p.Product_Id = oi.Product_Id
    JOIN orders o ON oi.Order_Id = o.Order_Id
    GROUP BY p.Product_Id, p.Product_Name, DATE_FORMAT(o.Order_Date, '%Y-%m')
),
comparison AS (
    SELECT
        Product_Id,
        Product_Name,
        month,
        revenue,
        LAG(revenue) OVER (
            PARTITION BY Product_Id ORDER BY month
        ) AS previous_revenue
    FROM product_monthly
)
SELECT
    Product_Id,
    Product_Name,
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_revenue, 2) AS previous_revenue,
    ROUND((revenue - previous_revenue) / NULLIF(previous_revenue, 0) * 100, 2) AS growth_pct
FROM comparison
WHERE previous_revenue IS NOT NULL
  AND previous_revenue > 0
  AND revenue > previous_revenue
ORDER BY growth_pct DESC;

-- Q59. Products with the highest latest-month growth
WITH product_monthly AS (
    SELECT
        p.Product_Id,
        p.Product_Name,
        DATE_FORMAT(o.Order_Date, '%Y-%m') AS month,
        SUM(oi.Quantity * oi.Unit_Price) AS revenue
    FROM products p
    JOIN order_items oi ON p.Product_Id = oi.Product_Id
    JOIN orders o ON oi.Order_Id = o.Order_Id
    GROUP BY p.Product_Id, p.Product_Name, DATE_FORMAT(o.Order_Date, '%Y-%m')
),
latest_month AS (
    SELECT MAX(month) AS month FROM product_monthly
),
comparison AS (
    SELECT
        Product_Id,
        Product_Name,
        month,
        revenue,
        LAG(revenue) OVER (
            PARTITION BY Product_Id ORDER BY month
        ) AS previous_revenue
    FROM product_monthly
)
SELECT
    Product_Id,
    Product_Name,
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_revenue, 2) AS previous_revenue,
    ROUND((revenue - previous_revenue) / NULLIF(previous_revenue, 0) * 100, 2) AS growth_pct
FROM comparison
WHERE month = (SELECT month FROM latest_month)
  AND previous_revenue IS NOT NULL
  AND previous_revenue > 0
ORDER BY growth_pct DESC;


--  INACTIVE / RETENTION ANALYSIS

-- Q60. Inactive customers with no orders
SELECT
    c.Customer_Id,
    c.Customer_name,
    c.City,
    c.State
FROM customers c
LEFT JOIN orders o ON c.Customer_Id = o.Customer_Id
WHERE o.Order_Id IS NULL;

-- Q61. Customers whose last order is older than 90 days from the latest order date
WITH last_order AS (
    SELECT MAX(Order_Date) AS max_order_date
    FROM orders
),
customer_last_order AS (
    SELECT
        c.Customer_Id,
        c.Customer_name,
        MAX(o.Order_Date) AS last_order_date
    FROM customers c
    LEFT JOIN orders o ON c.Customer_Id = o.Customer_Id
    GROUP BY c.Customer_Id, c.Customer_name
)
SELECT
    Customer_Id,
    Customer_name,
    last_order_date,
    DATEDIFF((SELECT max_order_date FROM last_order), last_order_date) AS days_since_last_order
FROM customer_last_order
WHERE last_order_date IS NULL
   OR DATEDIFF((SELECT max_order_date FROM last_order), last_order_date) > 90
ORDER BY days_since_last_order DESC;

-- Q62. Customer order frequency
SELECT
    c.Customer_Id,
    c.Customer_name,
    COUNT(DISTINCT o.Order_Id) AS order_count
FROM customers c
LEFT JOIN orders o ON c.Customer_Id = o.Customer_Id
GROUP BY c.Customer_Id, c.Customer_name
ORDER BY order_count DESC;

-- Q63. Repeat customers
SELECT
    c.Customer_Id,
    c.Customer_name,
    COUNT(DISTINCT o.Order_Id) AS order_count
FROM customers c
JOIN orders o ON c.Customer_Id = o.Customer_Id
GROUP BY c.Customer_Id, c.Customer_name
HAVING COUNT(DISTINCT o.Order_Id) > 1
ORDER BY order_count DESC;

-- Q64. New customers by registration month
SELECT
    DATE_FORMAT(Registration_Date, '%Y-%m') AS registration_month,
    COUNT(*) AS new_customers
FROM customers
GROUP BY DATE_FORMAT(Registration_Date, '%Y-%m')
ORDER BY registration_month;


--  CTE BUSINESS ANALYSIS

-- Q65. Customer revenue, order count, and AOV
WITH customer_orders AS (
    SELECT
        o.Customer_Id,
        o.Order_Id,
        SUM(oi.Quantity * oi.Unit_Price) AS order_value
    FROM orders o
    JOIN order_items oi ON o.Order_Id = oi.Order_Id
    GROUP BY o.Customer_Id, o.Order_Id
),
customer_summary AS (
    SELECT
        Customer_Id,
        COUNT(*) AS order_count,
        SUM(order_value) AS revenue,
        AVG(order_value) AS aov
    FROM customer_orders
    GROUP BY Customer_Id
)
SELECT
    c.Customer_Id,
    c.Customer_name,
    cs.order_count,
    ROUND(cs.revenue, 2) AS revenue,
    ROUND(cs.aov, 2) AS aov
FROM customer_summary cs
JOIN customers c ON c.Customer_Id = cs.Customer_Id
ORDER BY cs.revenue DESC;

-- Q66. Category performance with rank
WITH category_sales AS (
    SELECT
        p.Category,
        SUM(oi.Quantity * oi.Unit_Price) AS revenue,
        SUM(oi.Quantity) AS quantity
    FROM products p
    JOIN order_items oi ON p.Product_Id = oi.Product_Id
    GROUP BY p.Category
)
SELECT
    Category,
    ROUND(revenue, 2) AS revenue,
    quantity,
    RANK() OVER (ORDER BY revenue DESC) AS category_rank
FROM category_sales
ORDER BY category_rank;

-- Q67. State performance with rank
WITH state_sales AS (
    SELECT
        c.State,
        SUM(oi.Quantity * oi.Unit_Price) AS revenue,
        COUNT(DISTINCT o.Order_Id) AS orders
    FROM customers c
    JOIN orders o ON c.Customer_Id = o.Customer_Id
    JOIN order_items oi ON o.Order_Id = oi.Order_Id
    GROUP BY c.State
)
SELECT
    State,
    ROUND(revenue, 2) AS revenue,
    orders,
    RANK() OVER (ORDER BY revenue DESC) AS state_rank
FROM state_sales
ORDER BY state_rank;

-- Q68. Product revenue versus category average
WITH product_sales AS (
    SELECT
        p.Product_Id,
        p.Product_Name,
        p.Category,
        SUM(oi.Quantity * oi.Unit_Price) AS revenue
    FROM products p
    JOIN order_items oi ON p.Product_Id = oi.Product_Id
    GROUP BY p.Product_Id, p.Product_Name, p.Category
),
category_avg AS (
    SELECT
        Category,
        AVG(revenue) AS avg_category_product_revenue
    FROM product_sales
    GROUP BY Category
)
SELECT
    ps.Product_Name,
    ps.Category,
    ROUND(ps.revenue, 2) AS revenue,
    ROUND(ca.avg_category_product_revenue, 2) AS category_avg_revenue,
    CASE
        WHEN ps.revenue > ca.avg_category_product_revenue THEN 'ABOVE CATEGORY AVERAGE'
        ELSE 'AT OR BELOW CATEGORY AVERAGE'
    END AS performance_flag
FROM product_sales ps
JOIN category_avg ca ON ps.Category = ca.Category
ORDER BY ps.Category, ps.revenue DESC;

-- Q69. Customer revenue concentration: top 20% customers
WITH customer_sales AS (
    SELECT
        c.Customer_Id,
        c.Customer_name,
        SUM(oi.Quantity * oi.Unit_Price) AS revenue
    FROM customers c
    JOIN orders o ON c.Customer_Id = o.Customer_Id
    JOIN order_items oi ON o.Order_Id = oi.Order_Id
    GROUP BY c.Customer_Id, c.Customer_name
),
ranked AS (
    SELECT *,
           NTILE(5) OVER (ORDER BY revenue DESC) AS customer_quintile
    FROM customer_sales
)
SELECT
    customer_quintile,
    COUNT(*) AS customers,
    ROUND(SUM(revenue), 2) AS revenue
FROM ranked
GROUP BY customer_quintile
ORDER BY customer_quintile;


--  DATA QUALITY / BUSINESS VALIDATION

-- Q70. Check negative or zero quantities
SELECT *
FROM order_items
WHERE Quantity <= 0;

-- Q71. Check negative unit prices
SELECT *
FROM order_items
WHERE Unit_Price < 0;

-- Q72. Compare product master price with transaction unit price
SELECT
    oi.Product_Id,
    p.Product_Name,
    p.Price AS master_price,
    oi.Unit_Price AS transaction_price,
    ROUND(oi.Unit_Price - p.Price, 2) AS price_difference
FROM order_items oi
JOIN products p ON oi.Product_Id = p.Product_Id
WHERE oi.Unit_Price <> p.Price
ORDER BY ABS(oi.Unit_Price - p.Price) DESC;

-- Q73. Orders without line items
SELECT o.*
FROM orders o
LEFT JOIN order_items oi ON o.Order_Id = oi.Order_Id
WHERE oi.Order_Id IS NULL;

-- Q74. Customer order status distribution
SELECT
    o.Order_Status,
    COUNT(DISTINCT o.Order_Id) AS orders,
    ROUND(
        COUNT(DISTINCT o.Order_Id) /
        NULLIF((SELECT COUNT(*) FROM orders), 0) * 100,
        2
    ) AS order_pct
FROM orders o
GROUP BY o.Order_Status
ORDER BY orders DESC;

-- Q75. Final executive dataset: product performance
WITH product_sales AS (
    SELECT
        p.Product_Id,
        p.Product_Name,
        p.Category,
        SUM(oi.Quantity * oi.Unit_Price) AS revenue,
        SUM(oi.Quantity) AS quantity
    FROM products p
    JOIN order_items oi ON p.Product_Id = oi.Product_Id
    GROUP BY p.Product_Id, p.Product_Name, p.Category
)
SELECT
    Product_Id,
    Product_Name,
    Category,
    ROUND(revenue, 2) AS revenue,
    quantity,
    RANK() OVER (ORDER BY revenue DESC) AS revenue_rank,
    ROUND(revenue / NULLIF(SUM(revenue) OVER (), 0) * 100, 2) AS contribution_pct
FROM product_sales
ORDER BY revenue_rank;

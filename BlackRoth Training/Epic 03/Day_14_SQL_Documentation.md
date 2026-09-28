SQL Query Documentation



Database: SALES\_ANALYSIS\_DB

Tables: CUSTOMERS, PRODUCTS, ORDERS, ORDER\_ITEMS

Analysis Period: April–September 2025



Business Objective



Analyze e-commerce sales performance to identify



Overall sales KPIs



Monthly revenue trends



Category and product performance



Regional performance



Top customers and inactive customers



Order-value patterns



Order-status performance



Low-performing products



Dataset Summary



Customers : 30

Products : 25

Orders : 60

Order Items : 105





\--  **DATABASE INSPECTION \& RELATIONSHIPS**



\-- Q01. Inspect customers table

SELECT \* FROM customers LIMIT 20;



\-- Q02. Inspect products table

SELECT \* FROM products LIMIT 20;



\-- Q03. Inspect orders table

SELECT \* FROM orders LIMIT 20;



\-- Q04. Inspect order\_items table

SELECT \* FROM order\_items LIMIT 20;



\-- Q05. Check row counts

SELECT 'customers' AS table\_name, COUNT(\*) AS row\_count FROM customers

UNION ALL

SELECT 'products', COUNT(\*) FROM products

UNION ALL

SELECT 'orders', COUNT(\*) FROM orders

UNION ALL

SELECT 'order\_items', COUNT(\*) FROM order\_items;



\-- Q06. Check duplicate customer IDs

SELECT Customer\_Id, COUNT(\*) AS duplicate\_count

FROM customers

GROUP BY Customer\_Id

HAVING COUNT(\*) > 1;



\-- Q07. Check duplicate product IDs

SELECT Product\_Id, COUNT(\*) AS duplicate\_count

FROM products

GROUP BY Product\_Id

HAVING COUNT(\*) > 1;



\-- Q08. Check duplicate order IDs

SELECT Order\_Id, COUNT(\*) AS duplicate\_count

FROM orders

GROUP BY Order\_Id

HAVING COUNT(\*) > 1;



\-- Q09. Check NULLs in key customer fields

SELECT

&#x20;   SUM(Customer\_Id IS NULL) AS null\_customer\_id,

&#x20;   SUM(Customer\_name IS NULL) AS null\_customer\_name,

&#x20;   SUM(City IS NULL) AS null\_city,

&#x20;   SUM(State IS NULL) AS null\_state,

&#x20;   SUM(Registration\_Date IS NULL) AS null\_registration\_date

FROM customers;



\-- Q10. Check NULLs in products

SELECT

&#x20;   SUM(Product\_Id IS NULL) AS null\_product\_id,

&#x20;   SUM(Product\_Name IS NULL) AS null\_product\_name,

&#x20;   SUM(Category IS NULL) AS null\_category,

&#x20;   SUM(Price IS NULL) AS null\_price

FROM products;



\-- Q11. Check NULLs in orders

SELECT

&#x20;   SUM(Order\_Id IS NULL) AS null\_order\_id,

&#x20;   SUM(Customer\_Id IS NULL) AS null\_customer\_id,

&#x20;   SUM(Order\_Date IS NULL) AS null\_order\_date,

&#x20;   SUM(Order\_Status IS NULL) AS null\_order\_status

FROM orders;



\-- Q12. Check NULLs in order\_items

SELECT

&#x20;   SUM(Order\_Item\_Id IS NULL) AS null\_order\_item\_id,

&#x20;   SUM(Order\_Id IS NULL) AS null\_order\_id,

&#x20;   SUM(Product\_Id IS NULL) AS null\_product\_id,

&#x20;   SUM(Quantity IS NULL) AS null\_quantity,

&#x20;   SUM(Unit\_Price IS NULL) AS null\_unit\_price

FROM order\_items;



\-- Q13. Find orphan order\_items whose order does not exist

SELECT oi.\*

FROM order\_items oi

LEFT JOIN orders o ON oi.Order\_Id = o.Order\_Id

WHERE o.Order\_Id IS NULL;



\-- Q14. Find orphan order\_items whose product does not exist

SELECT oi.\*

FROM order\_items oi

LEFT JOIN products p ON oi.Product\_Id = p.Product\_Id

WHERE p.Product\_Id IS NULL;



\-- Q15. Find orders whose customer does not exist

SELECT o.\*

FROM orders o

LEFT JOIN customers c ON o.Customer\_Id = c.Customer\_Id

WHERE c.Customer\_Id IS NULL;



\-- Q16. Inspect order statuses

SELECT Order\_Status, COUNT(\*) AS order\_count

FROM orders

GROUP BY Order\_Status

ORDER BY order\_count DESC;





\-- **OVERALL KPIs**



\-- Q17. Total revenue

SELECT ROUND(SUM(oi.Quantity \* oi.Unit\_Price), 2) AS total\_revenue

FROM order\_items oi;



\-- Q18. Total orders

SELECT COUNT(DISTINCT Order\_Id) AS total\_orders

FROM order\_items;



\-- Q19. Total customers

SELECT COUNT(DISTINCT Customer\_Id) AS total\_customers

FROM customers;



\-- Q20. Total quantity sold

SELECT SUM(Quantity) AS total\_quantity

FROM order\_items;



\-- Q21. Average Order Value

WITH order\_values AS (

&#x20;   SELECT Order\_Id, SUM(Quantity \* Unit\_Price) AS order\_value

&#x20;   FROM order\_items

&#x20;   GROUP BY Order\_Id

)

SELECT ROUND(AVG(order\_value), 2) AS average\_order\_value

FROM order\_values;



\-- Q22. All five core KPIs in one query

WITH order\_values AS (

&#x20;   SELECT Order\_Id, SUM(Quantity \* Unit\_Price) AS order\_value

&#x20;   FROM order\_items

&#x20;   GROUP BY Order\_Id

)

SELECT

&#x20;   ROUND((SELECT SUM(Quantity \* Unit\_Price) FROM order\_items), 2) AS total\_revenue,

&#x20;   (SELECT COUNT(DISTINCT Order\_Id) FROM order\_items) AS total\_orders,

&#x20;   (SELECT COUNT(\*) FROM customers) AS total\_customers,

&#x20;   ROUND((SELECT AVG(order\_value) FROM order\_values), 2) AS average\_order\_value,

&#x20;   (SELECT SUM(Quantity) FROM order\_items) AS total\_quantity;





\-- **PERFORMANCE ANALYSIS**



\-- Q23. Top 10 products by revenue

SELECT

&#x20;   p.Product\_Id,

&#x20;   p.Product\_Name,

&#x20;   p.Category,

&#x20;   ROUND(SUM(oi.Quantity \* oi.Unit\_Price), 2) AS revenue

FROM products p

JOIN order\_items oi ON p.Product\_Id = oi.Product\_Id

GROUP BY p.Product\_Id, p.Product\_Name, p.Category

ORDER BY revenue DESC

LIMIT 10;



\-- Q24. Top 10 customers by spending

SELECT

&#x20;   c.Customer\_Id,

&#x20;   c.Customer\_name,

&#x20;   c.City,

&#x20;   c.State,

&#x20;   ROUND(SUM(oi.Quantity \* oi.Unit\_Price), 2) AS total\_spending

FROM customers c

JOIN orders o ON c.Customer\_Id = o.Customer\_Id

JOIN order\_items oi ON o.Order\_Id = oi.Order\_Id

GROUP BY c.Customer\_Id, c.Customer\_name, c.City, c.State

ORDER BY total\_spending DESC

LIMIT 10;



\-- Q25. Category revenue

SELECT

&#x20;   p.Category,

&#x20;   ROUND(SUM(oi.Quantity \* oi.Unit\_Price), 2) AS revenue,

&#x20;   SUM(oi.Quantity) AS quantity\_sold

FROM products p

JOIN order\_items oi ON p.Product\_Id = oi.Product\_Id

GROUP BY p.Category

ORDER BY revenue DESC;



\-- Q26. Region/state revenue

SELECT

&#x20;   c.State,

&#x20;   ROUND(SUM(oi.Quantity \* oi.Unit\_Price), 2) AS revenue,

&#x20;   COUNT(DISTINCT o.Order\_Id) AS total\_orders,

&#x20;   COUNT(DISTINCT c.Customer\_Id) AS customers

FROM customers c

JOIN orders o ON c.Customer\_Id = o.Customer\_Id

JOIN order\_items oi ON o.Order\_Id = oi.Order\_Id

GROUP BY c.State

ORDER BY revenue DESC;



\-- Q27. City revenue

SELECT

&#x20;   c.City,

&#x20;   ROUND(SUM(oi.Quantity \* oi.Unit\_Price), 2) AS revenue

FROM customers c

JOIN orders o ON c.Customer\_Id = o.Customer\_Id

JOIN order\_items oi ON o.Order\_Id = oi.Order\_Id

GROUP BY c.City

ORDER BY revenue DESC;



\-- Q28. Product quantity performance

SELECT

&#x20;   p.Product\_Name,

&#x20;   SUM(oi.Quantity) AS quantity\_sold

FROM products p

JOIN order\_items oi ON p.Product\_Id = oi.Product\_Id

GROUP BY p.Product\_Id, p.Product\_Name

ORDER BY quantity\_sold DESC;



\-- Q29. Category average selling price

SELECT

&#x20;   p.Category,

&#x20;   ROUND(AVG(oi.Unit\_Price), 2) AS average\_selling\_price

FROM products p

JOIN order\_items oi ON p.Product\_Id = oi.Product\_Id

GROUP BY p.Category

ORDER BY average\_selling\_price DESC;





\-- **MONTHLY TRENDS \& MOM GROWTH**



\-- Q30. Monthly revenue

SELECT

&#x20;   DATE\_FORMAT(o.Order\_Date, '%Y-%m') AS month,

&#x20;   ROUND(SUM(oi.Quantity \* oi.Unit\_Price), 2) AS monthly\_revenue

FROM orders o

JOIN order\_items oi ON o.Order\_Id = oi.Order\_Id

GROUP BY DATE\_FORMAT(o.Order\_Date, '%Y-%m')

ORDER BY month;



\-- Q31. Monthly orders and quantity

SELECT

&#x20;   DATE\_FORMAT(o.Order\_Date, '%Y-%m') AS month,

&#x20;   COUNT(DISTINCT o.Order\_Id) AS orders,

&#x20;   SUM(oi.Quantity) AS quantity

FROM orders o

JOIN order\_items oi ON o.Order\_Id = oi.Order\_Id

GROUP BY DATE\_FORMAT(o.Order\_Date, '%Y-%m')

ORDER BY month;



\-- Q32. Month-over-month revenue growth

WITH monthly AS (

&#x20;   SELECT

&#x20;       DATE\_FORMAT(o.Order\_Date, '%Y-%m') AS month,

&#x20;       SUM(oi.Quantity \* oi.Unit\_Price) AS revenue

&#x20;   FROM orders o

&#x20;   JOIN order\_items oi ON o.Order\_Id = oi.Order\_Id

&#x20;   GROUP BY DATE\_FORMAT(o.Order\_Date, '%Y-%m')

),

comparison AS (

&#x20;   SELECT

&#x20;       month,

&#x20;       revenue,

&#x20;       LAG(revenue) OVER (ORDER BY month) AS previous\_revenue

&#x20;   FROM monthly

)

SELECT

&#x20;   month,

&#x20;   ROUND(revenue, 2) AS revenue,

&#x20;   ROUND(previous\_revenue, 2) AS previous\_revenue,

&#x20;   ROUND(

&#x20;       (revenue - previous\_revenue) / NULLIF(previous\_revenue, 0) \* 100,

&#x20;       2

&#x20;   ) AS mom\_growth\_pct

FROM comparison

ORDER BY month;



\-- Q33. Cumulative revenue

WITH monthly AS (

&#x20;   SELECT

&#x20;       DATE\_FORMAT(o.Order\_Date, '%Y-%m') AS month,

&#x20;       SUM(oi.Quantity \* oi.Unit\_Price) AS revenue

&#x20;   FROM orders o

&#x20;   JOIN order\_items oi ON o.Order\_Id = oi.Order\_Id

&#x20;   GROUP BY DATE\_FORMAT(o.Order\_Date, '%Y-%m')

)

SELECT

&#x20;   month,

&#x20;   ROUND(revenue, 2) AS monthly\_revenue,

&#x20;   ROUND(

&#x20;       SUM(revenue) OVER (ORDER BY month),

&#x20;       2

&#x20;   ) AS cumulative\_revenue

FROM monthly

ORDER BY month;



\-- Q34. Monthly AOV

WITH monthly\_orders AS (

&#x20;   SELECT

&#x20;       o.Order\_Id,

&#x20;       DATE\_FORMAT(o.Order\_Date, '%Y-%m') AS month,

&#x20;       SUM(oi.Quantity \* oi.Unit\_Price) AS order\_value

&#x20;   FROM orders o

&#x20;   JOIN order\_items oi ON o.Order\_Id = oi.Order\_Id

&#x20;   GROUP BY o.Order\_Id, DATE\_FORMAT(o.Order\_Date, '%Y-%m')

)

SELECT

&#x20;   month,

&#x20;   ROUND(AVG(order\_value), 2) AS monthly\_aov

FROM monthly\_orders

GROUP BY month

ORDER BY month;



\-- Q35. Best revenue month

WITH monthly AS (

&#x20;   SELECT

&#x20;       DATE\_FORMAT(o.Order\_Date, '%Y-%m') AS month,

&#x20;       SUM(oi.Quantity \* oi.Unit\_Price) AS revenue

&#x20;   FROM orders o

&#x20;   JOIN order\_items oi ON o.Order\_Id = oi.Order\_Id

&#x20;   GROUP BY DATE\_FORMAT(o.Order\_Date, '%Y-%m')

)

SELECT month, ROUND(revenue, 2) AS revenue

FROM monthly

ORDER BY revenue DESC

LIMIT 1;



\-- Q36. Lowest revenue month

WITH monthly AS (

&#x20;   SELECT

&#x20;       DATE\_FORMAT(o.Order\_Date, '%Y-%m') AS month,

&#x20;       SUM(oi.Quantity \* oi.Unit\_Price) AS revenue

&#x20;   FROM orders o

&#x20;   JOIN order\_items oi ON o.Order\_Id = oi.Order\_Id

&#x20;   GROUP BY DATE\_FORMAT(o.Order\_Date, '%Y-%m')

)

SELECT month, ROUND(revenue, 2) AS revenue

FROM monthly

ORDER BY revenue

LIMIT 1;





\--  **WINDOW FUNCTIONS \& RANKING**



\-- Q37. Rank all products by revenue

WITH product\_sales AS (

&#x20;   SELECT

&#x20;       p.Product\_Id,

&#x20;       p.Product\_Name,

&#x20;       p.Category,

&#x20;       SUM(oi.Quantity \* oi.Unit\_Price) AS revenue

&#x20;   FROM products p

&#x20;   JOIN order\_items oi ON p.Product\_Id = oi.Product\_Id

&#x20;   GROUP BY p.Product\_Id, p.Product\_Name, p.Category

)

SELECT

&#x20;   Product\_Id,

&#x20;   Product\_Name,

&#x20;   Category,

&#x20;   ROUND(revenue, 2) AS revenue,

&#x20;   RANK() OVER (ORDER BY revenue DESC) AS revenue\_rank

FROM product\_sales

ORDER BY revenue\_rank;



\-- Q38. Rank customers by spending

WITH customer\_sales AS (

&#x20;   SELECT

&#x20;       c.Customer\_Id,

&#x20;       c.Customer\_name,

&#x20;       SUM(oi.Quantity \* oi.Unit\_Price) AS spending

&#x20;   FROM customers c

&#x20;   JOIN orders o ON c.Customer\_Id = o.Customer\_Id

&#x20;   JOIN order\_items oi ON o.Order\_Id = oi.Order\_Id

&#x20;   GROUP BY c.Customer\_Id, c.Customer\_name

)

SELECT

&#x20;   Customer\_Id,

&#x20;   Customer\_name,

&#x20;   ROUND(spending, 2) AS spending,

&#x20;   RANK() OVER (ORDER BY spending DESC) AS spending\_rank

FROM customer\_sales

ORDER BY spending\_rank;



\-- Q39. Dense rank products

WITH product\_sales AS (

&#x20;   SELECT

&#x20;       p.Product\_Id,

&#x20;       p.Product\_Name,

&#x20;       SUM(oi.Quantity \* oi.Unit\_Price) AS revenue

&#x20;   FROM products p

&#x20;   JOIN order\_items oi ON p.Product\_Id = oi.Product\_Id

&#x20;   GROUP BY p.Product\_Id, p.Product\_Name

)

SELECT

&#x20;   Product\_Name,

&#x20;   ROUND(revenue, 2) AS revenue,

&#x20;   DENSE\_RANK() OVER (ORDER BY revenue DESC) AS dense\_rankK

FROM product\_sales;



\-- Q40. Top 3 products in each category

WITH product\_sales AS (

&#x20;   SELECT

&#x20;       p.Product\_Id,

&#x20;       p.Product\_Name,

&#x20;       p.Category,

&#x20;       SUM(oi.Quantity \* oi.Unit\_Price) AS revenue

&#x20;   FROM products p

&#x20;   JOIN order\_items oi ON p.Product\_Id = oi.Product\_Id

&#x20;   GROUP BY p.Product\_Id, p.Product\_Name, p.Category

),

ranked AS (

&#x20;   SELECT \*,

&#x20;          ROW\_NUMBER() OVER (

&#x20;              PARTITION BY Category

&#x20;              ORDER BY revenue DESC

&#x20;          ) AS category\_rank

&#x20;   FROM product\_sales

)

SELECT

&#x20;   Product\_Id,

&#x20;   Product\_Name,

&#x20;   Category,

&#x20;   ROUND(revenue, 2) AS revenue,

&#x20;   category\_rank

FROM ranked

WHERE category\_rank <= 3

ORDER BY Category, category\_rank;



\-- Q41. Top 3 customers in each state

WITH customer\_sales AS (

&#x20;   SELECT

&#x20;       c.Customer\_Id,

&#x20;       c.Customer\_name,

&#x20;       c.State,

&#x20;       SUM(oi.Quantity \* oi.Unit\_Price) AS spending

&#x20;   FROM customers c

&#x20;   JOIN orders o ON c.Customer\_Id = o.Customer\_Id

&#x20;   JOIN order\_items oi ON o.Order\_Id = oi.Order\_Id

&#x20;   GROUP BY c.Customer\_Id, c.Customer\_name, c.State

),

ranked AS (

&#x20;   SELECT \*,

&#x20;          ROW\_NUMBER() OVER (

&#x20;              PARTITION BY State

&#x20;              ORDER BY spending DESC

&#x20;          ) AS state\_rank

&#x20;   FROM customer\_sales

)

SELECT \*

FROM ranked

WHERE state\_rank <= 3

ORDER BY State, state\_rank;



\-- Q42. Compare each product with previous monthly revenue

WITH product\_monthly AS (

&#x20;   SELECT

&#x20;       p.Product\_Id,

&#x20;       p.Product\_Name,

&#x20;       DATE\_FORMAT(o.Order\_Date, '%Y-%m') AS month,

&#x20;       SUM(oi.Quantity \* oi.Unit\_Price) AS revenue

&#x20;   FROM products p

&#x20;   JOIN order\_items oi ON p.Product\_Id = oi.Product\_Id

&#x20;   JOIN orders o ON oi.Order\_Id = o.Order\_Id

&#x20;   GROUP BY p.Product\_Id, p.Product\_Name, DATE\_FORMAT(o.Order\_Date, '%Y-%m')

)

SELECT

&#x20;   Product\_Id,

&#x20;   Product\_Name,

&#x20;   month,

&#x20;   ROUND(revenue, 2) AS revenue,

&#x20;   ROUND(LAG(revenue) OVER (

&#x20;       PARTITION BY Product\_Id ORDER BY month

&#x20;   ), 2) AS previous\_month\_revenue

FROM product\_monthly

ORDER BY Product\_Name, month;





\-- **SUBQUERIES \& ABOVE-AVERAGE ANALYSIS**



\-- Q43. Customers spending above average customer spending

WITH customer\_sales AS (

&#x20;   SELECT

&#x20;       c.Customer\_Id,

&#x20;       c.Customer\_name,

&#x20;       SUM(oi.Quantity \* oi.Unit\_Price) AS spending

&#x20;   FROM customers c

&#x20;   JOIN orders o ON c.Customer\_Id = o.Customer\_Id

&#x20;   JOIN order\_items oi ON o.Order\_Id = oi.Order\_Id

&#x20;   GROUP BY c.Customer\_Id, c.Customer\_name

)

SELECT \*

FROM customer\_sales

WHERE spending > (SELECT AVG(spending) FROM customer\_sales)

ORDER BY spending DESC;



\-- Q44. Products with revenue above average product revenue

WITH product\_sales AS (

&#x20;   SELECT

&#x20;       p.Product\_Id,

&#x20;       p.Product\_Name,

&#x20;       SUM(oi.Quantity \* oi.Unit\_Price) AS revenue

&#x20;   FROM products p

&#x20;   JOIN order\_items oi ON p.Product\_Id = oi.Product\_Id

&#x20;   GROUP BY p.Product\_Id, p.Product\_Name

)

SELECT \*

FROM product\_sales

WHERE revenue > (SELECT AVG(revenue) FROM product\_sales)

ORDER BY revenue DESC;



\-- Q45. Products priced above average price

SELECT Product\_Id, Product\_Name, Category, Price

FROM products

WHERE Price > (SELECT AVG(Price) FROM products)

ORDER BY Price DESC;



\-- Q46. Customers who placed at least one order using IN

SELECT Customer\_Id, Customer\_name

FROM customers

WHERE Customer\_Id IN (

&#x20;   SELECT DISTINCT Customer\_Id

&#x20;   FROM orders

);



\-- Q47. Customers who placed at least one order using EXISTS

SELECT c.Customer\_Id, c.Customer\_name

FROM customers c

WHERE EXISTS (

&#x20;   SELECT 1

&#x20;   FROM orders o

&#x20;   WHERE o.Customer\_Id = c.Customer\_Id

);



\-- Q48. Customers with no orders

SELECT c.Customer\_Id, c.Customer\_name

FROM customers c

WHERE NOT EXISTS (

&#x20;   SELECT 1

&#x20;   FROM orders o

&#x20;   WHERE o.Customer\_Id = c.Customer\_Id

);



\-- Q49. Products never sold

SELECT p.Product\_Id, p.Product\_Name, p.Category

FROM products p

WHERE NOT EXISTS (

&#x20;   SELECT 1

&#x20;   FROM order\_items oi

&#x20;   WHERE oi.Product\_Id = p.Product\_Id

);



\-- Q50. Customers spending more than the overall average order value

WITH customer\_sales AS (

&#x20;   SELECT

&#x20;       c.Customer\_Id,

&#x20;       c.Customer\_name,

&#x20;       SUM(oi.Quantity \* oi.Unit\_Price) AS spending

&#x20;   FROM customers c

&#x20;   JOIN orders o ON c.Customer\_Id = o.Customer\_Id

&#x20;   JOIN order\_items oi ON o.Order\_Id = oi.Order\_Id

&#x20;   GROUP BY c.Customer\_Id, c.Customer\_name

),

order\_values AS (

&#x20;   SELECT Order\_Id, SUM(Quantity \* Unit\_Price) AS order\_value

&#x20;   FROM order\_items

&#x20;   GROUP BY Order\_Id

)

SELECT \*

FROM customer\_sales

WHERE spending > (SELECT AVG(order\_value) FROM order\_values)

ORDER BY spending DESC;





\--  **CASE-BASED CUSTOMER SEGMENTATION**



\-- Q51. Segment customers by total spending

WITH customer\_sales AS (

&#x20;   SELECT

&#x20;       c.Customer\_Id,

&#x20;       c.Customer\_name,

&#x20;       COALESCE(SUM(oi.Quantity \* oi.Unit\_Price), 0) AS spending

&#x20;   FROM customers c

&#x20;   LEFT JOIN orders o ON c.Customer\_Id = o.Customer\_Id

&#x20;   LEFT JOIN order\_items oi ON o.Order\_Id = oi.Order\_Id

&#x20;   GROUP BY c.Customer\_Id, c.Customer\_name

)

SELECT

&#x20;   Customer\_Id,

&#x20;   Customer\_name,

&#x20;   ROUND(spending, 2) AS spending,

&#x20;   CASE

&#x20;       WHEN spending >= 100000 THEN 'HIGH VALUE'

&#x20;       WHEN spending >= 50000 THEN 'MEDIUM VALUE'

&#x20;       ELSE 'LOW VALUE'

&#x20;   END AS customer\_segment

FROM customer\_sales

ORDER BY spending DESC;



\-- Q52. Segment products by revenue

WITH product\_sales AS (

&#x20;   SELECT

&#x20;       p.Product\_Id,

&#x20;       p.Product\_Name,

&#x20;       COALESCE(SUM(oi.Quantity \* oi.Unit\_Price), 0) AS revenue

&#x20;   FROM products p

&#x20;   LEFT JOIN order\_items oi ON p.Product\_Id = oi.Product\_Id

&#x20;   GROUP BY p.Product\_Id, p.Product\_Name

)

SELECT

&#x20;   Product\_Id,

&#x20;   Product\_Name,

&#x20;   ROUND(revenue, 2) AS revenue,

&#x20;   CASE

&#x20;       WHEN revenue >= 100000 THEN 'HIGH'

&#x20;       WHEN revenue >= 50000 THEN 'MEDIUM'

&#x20;       ELSE 'LOW'

&#x20;   END AS revenue\_segment

FROM product\_sales

ORDER BY revenue DESC;



\-- Q53. Customer activity segment

WITH customer\_activity AS (

&#x20;   SELECT

&#x20;       c.Customer\_Id,

&#x20;       c.Customer\_name,

&#x20;       COUNT(DISTINCT o.Order\_Id) AS order\_count

&#x20;   FROM customers c

&#x20;   LEFT JOIN orders o ON c.Customer\_Id = o.Customer\_Id

&#x20;   GROUP BY c.Customer\_Id, c.Customer\_name

)

SELECT

&#x20;   Customer\_Id,

&#x20;   Customer\_name,

&#x20;   order\_count,

&#x20;   CASE

&#x20;       WHEN order\_count = 0 THEN 'INACTIVE'

&#x20;       WHEN order\_count = 1 THEN 'LOW ACTIVITY'

&#x20;       WHEN order\_count BETWEEN 2 AND 5 THEN 'MEDIUM ACTIVITY'

&#x20;       ELSE 'HIGH ACTIVITY'

&#x20;   END AS activity\_segment

FROM customer\_activity

ORDER BY order\_count DESC;





\-- **CONTRIBUTION \& CUMULATIVE ANALYSIS**



\-- Q54. Product contribution percentage

WITH product\_sales AS (

&#x20;   SELECT

&#x20;       p.Product\_Id,

&#x20;       p.Product\_Name,

&#x20;       SUM(oi.Quantity \* oi.Unit\_Price) AS revenue

&#x20;   FROM products p

&#x20;   JOIN order\_items oi ON p.Product\_Id = oi.Product\_Id

&#x20;   GROUP BY p.Product\_Id, p.Product\_Name

)

SELECT

&#x20;   Product\_Id,

&#x20;   Product\_Name,

&#x20;   ROUND(revenue, 2) AS revenue,

&#x20;   ROUND(

&#x20;       revenue / NULLIF(SUM(revenue) OVER (), 0) \* 100,

&#x20;       2

&#x20;   ) AS contribution\_pct

FROM product\_sales

ORDER BY contribution\_pct DESC;



\-- Q55. Category contribution percentage

WITH category\_sales AS (

&#x20;   SELECT

&#x20;       p.Category,

&#x20;       SUM(oi.Quantity \* oi.Unit\_Price) AS revenue

&#x20;   FROM products p

&#x20;   JOIN order\_items oi ON p.Product\_Id = oi.Product\_Id

&#x20;   GROUP BY p.Category

)

SELECT

&#x20;   Category,

&#x20;   ROUND(revenue, 2) AS revenue,

&#x20;   ROUND(

&#x20;       revenue / NULLIF(SUM(revenue) OVER (), 0) \* 100,

&#x20;       2

&#x20;   ) AS contribution\_pct

FROM category\_sales

ORDER BY contribution\_pct DESC;



\-- Q56. Cumulative product revenue

WITH product\_sales AS (

&#x20;   SELECT

&#x20;       p.Product\_Id,

&#x20;       p.Product\_Name,

&#x20;       SUM(oi.Quantity \* oi.Unit\_Price) AS revenue

&#x20;   FROM products p

&#x20;   JOIN order\_items oi ON p.Product\_Id = oi.Product\_Id

&#x20;   GROUP BY p.Product\_Id, p.Product\_Name

)

SELECT

&#x20;   Product\_Id,

&#x20;   Product\_Name,

&#x20;   ROUND(revenue, 2) AS revenue,

&#x20;   ROUND(SUM(revenue) OVER (ORDER BY revenue DESC), 2) AS cumulative\_revenue

FROM product\_sales

ORDER BY revenue DESC;





\--  **DECLINING / HIGH-GROWTH PRODUCTS**



\-- Q57. Products with month-over-month decline

WITH product\_monthly AS (

&#x20;   SELECT

&#x20;       p.Product\_Id,

&#x20;       p.Product\_Name,

&#x20;       DATE\_FORMAT(o.Order\_Date, '%Y-%m') AS month,

&#x20;       SUM(oi.Quantity \* oi.Unit\_Price) AS revenue

&#x20;   FROM products p

&#x20;   JOIN order\_items oi ON p.Product\_Id = oi.Product\_Id

&#x20;   JOIN orders o ON oi.Order\_Id = o.Order\_Id

&#x20;   GROUP BY p.Product\_Id, p.Product\_Name, DATE\_FORMAT(o.Order\_Date, '%Y-%m')

),

comparison AS (

&#x20;   SELECT

&#x20;       Product\_Id,

&#x20;       Product\_Name,

&#x20;       month,

&#x20;       revenue,

&#x20;       LAG(revenue) OVER (

&#x20;           PARTITION BY Product\_Id ORDER BY month

&#x20;       ) AS previous\_revenue

&#x20;   FROM product\_monthly

)

SELECT

&#x20;   Product\_Id,

&#x20;   Product\_Name,

&#x20;   month,

&#x20;   ROUND(revenue, 2) AS revenue,

&#x20;   ROUND(previous\_revenue, 2) AS previous\_revenue,

&#x20;   ROUND((revenue - previous\_revenue) / NULLIF(previous\_revenue, 0) \* 100, 2) AS growth\_pct

FROM comparison

WHERE previous\_revenue IS NOT NULL

&#x20; AND revenue < previous\_revenue

ORDER BY growth\_pct;



\-- Q58. Products with positive month-over-month growth

WITH product\_monthly AS (

&#x20;   SELECT

&#x20;       p.Product\_Id,

&#x20;       p.Product\_Name,

&#x20;       DATE\_FORMAT(o.Order\_Date, '%Y-%m') AS month,

&#x20;       SUM(oi.Quantity \* oi.Unit\_Price) AS revenue

&#x20;   FROM products p

&#x20;   JOIN order\_items oi ON p.Product\_Id = oi.Product\_Id

&#x20;   JOIN orders o ON oi.Order\_Id = o.Order\_Id

&#x20;   GROUP BY p.Product\_Id, p.Product\_Name, DATE\_FORMAT(o.Order\_Date, '%Y-%m')

),

comparison AS (

&#x20;   SELECT

&#x20;       Product\_Id,

&#x20;       Product\_Name,

&#x20;       month,

&#x20;       revenue,

&#x20;       LAG(revenue) OVER (

&#x20;           PARTITION BY Product\_Id ORDER BY month

&#x20;       ) AS previous\_revenue

&#x20;   FROM product\_monthly

)

SELECT

&#x20;   Product\_Id,

&#x20;   Product\_Name,

&#x20;   month,

&#x20;   ROUND(revenue, 2) AS revenue,

&#x20;   ROUND(previous\_revenue, 2) AS previous\_revenue,

&#x20;   ROUND((revenue - previous\_revenue) / NULLIF(previous\_revenue, 0) \* 100, 2) AS growth\_pct

FROM comparison

WHERE previous\_revenue IS NOT NULL

&#x20; AND previous\_revenue > 0

&#x20; AND revenue > previous\_revenue

ORDER BY growth\_pct DESC;



\-- Q59. Products with the highest latest-month growth

WITH product\_monthly AS (

&#x20;   SELECT

&#x20;       p.Product\_Id,

&#x20;       p.Product\_Name,

&#x20;       DATE\_FORMAT(o.Order\_Date, '%Y-%m') AS month,

&#x20;       SUM(oi.Quantity \* oi.Unit\_Price) AS revenue

&#x20;   FROM products p

&#x20;   JOIN order\_items oi ON p.Product\_Id = oi.Product\_Id

&#x20;   JOIN orders o ON oi.Order\_Id = o.Order\_Id

&#x20;   GROUP BY p.Product\_Id, p.Product\_Name, DATE\_FORMAT(o.Order\_Date, '%Y-%m')

),

latest\_month AS (

&#x20;   SELECT MAX(month) AS month FROM product\_monthly

),

comparison AS (

&#x20;   SELECT

&#x20;       Product\_Id,

&#x20;       Product\_Name,

&#x20;       month,

&#x20;       revenue,

&#x20;       LAG(revenue) OVER (

&#x20;           PARTITION BY Product\_Id ORDER BY month

&#x20;       ) AS previous\_revenue

&#x20;   FROM product\_monthly

)

SELECT

&#x20;   Product\_Id,

&#x20;   Product\_Name,

&#x20;   month,

&#x20;   ROUND(revenue, 2) AS revenue,

&#x20;   ROUND(previous\_revenue, 2) AS previous\_revenue,

&#x20;   ROUND((revenue - previous\_revenue) / NULLIF(previous\_revenue, 0) \* 100, 2) AS growth\_pct

FROM comparison

WHERE month = (SELECT month FROM latest\_month)

&#x20; AND previous\_revenue IS NOT NULL

&#x20; AND previous\_revenue > 0

ORDER BY growth\_pct DESC;





\-- **INACTIVE / RETENTION ANALYSIS**



\-- Q60. Inactive customers with no orders

SELECT

&#x20;   c.Customer\_Id,

&#x20;   c.Customer\_name,

&#x20;   c.City,

&#x20;   c.State

FROM customers c

LEFT JOIN orders o ON c.Customer\_Id = o.Customer\_Id

WHERE o.Order\_Id IS NULL;



\-- Q61. Customers whose last order is older than 90 days from the latest order date

WITH last\_order AS (

&#x20;   SELECT MAX(Order\_Date) AS max\_order\_date

&#x20;   FROM orders

),

customer\_last\_order AS (

&#x20;   SELECT

&#x20;       c.Customer\_Id,

&#x20;       c.Customer\_name,

&#x20;       MAX(o.Order\_Date) AS last\_order\_date

&#x20;   FROM customers c

&#x20;   LEFT JOIN orders o ON c.Customer\_Id = o.Customer\_Id

&#x20;   GROUP BY c.Customer\_Id, c.Customer\_name

)

SELECT

&#x20;   Customer\_Id,

&#x20;   Customer\_name,

&#x20;   last\_order\_date,

&#x20;   DATEDIFF((SELECT max\_order\_date FROM last\_order), last\_order\_date) AS days\_since\_last\_order

FROM customer\_last\_order

WHERE last\_order\_date IS NULL

&#x20;  OR DATEDIFF((SELECT max\_order\_date FROM last\_order), last\_order\_date) > 90

ORDER BY days\_since\_last\_order DESC;



\-- Q62. Customer order frequency

SELECT

&#x20;   c.Customer\_Id,

&#x20;   c.Customer\_name,

&#x20;   COUNT(DISTINCT o.Order\_Id) AS order\_count

FROM customers c

LEFT JOIN orders o ON c.Customer\_Id = o.Customer\_Id

GROUP BY c.Customer\_Id, c.Customer\_name

ORDER BY order\_count DESC;



\-- Q63. Repeat customers

SELECT

&#x20;   c.Customer\_Id,

&#x20;   c.Customer\_name,

&#x20;   COUNT(DISTINCT o.Order\_Id) AS order\_count

FROM customers c

JOIN orders o ON c.Customer\_Id = o.Customer\_Id

GROUP BY c.Customer\_Id, c.Customer\_name

HAVING COUNT(DISTINCT o.Order\_Id) > 1

ORDER BY order\_count DESC;



\-- Q64. New customers by registration month

SELECT

&#x20;   DATE\_FORMAT(Registration\_Date, '%Y-%m') AS registration\_month,

&#x20;   COUNT(\*) AS new\_customers

FROM customers

GROUP BY DATE\_FORMAT(Registration\_Date, '%Y-%m')

ORDER BY registration\_month;





\--  CTE BUSINESS ANALYSIS



\-- Q65. Customer revenue, order count, and AOV

WITH customer\_orders AS (

&#x20;   SELECT

&#x20;       o.Customer\_Id,

&#x20;       o.Order\_Id,

&#x20;       SUM(oi.Quantity \* oi.Unit\_Price) AS order\_value

&#x20;   FROM orders o

&#x20;   JOIN order\_items oi ON o.Order\_Id = oi.Order\_Id

&#x20;   GROUP BY o.Customer\_Id, o.Order\_Id

),

customer\_summary AS (

&#x20;   SELECT

&#x20;       Customer\_Id,

&#x20;       COUNT(\*) AS order\_count,

&#x20;       SUM(order\_value) AS revenue,

&#x20;       AVG(order\_value) AS aov

&#x20;   FROM customer\_orders

&#x20;   GROUP BY Customer\_Id

)

SELECT

&#x20;   c.Customer\_Id,

&#x20;   c.Customer\_name,

&#x20;   cs.order\_count,

&#x20;   ROUND(cs.revenue, 2) AS revenue,

&#x20;   ROUND(cs.aov, 2) AS aov

FROM customer\_summary cs

JOIN customers c ON c.Customer\_Id = cs.Customer\_Id

ORDER BY cs.revenue DESC;



\-- Q66. Category performance with rank

WITH category\_sales AS (

&#x20;   SELECT

&#x20;       p.Category,

&#x20;       SUM(oi.Quantity \* oi.Unit\_Price) AS revenue,

&#x20;       SUM(oi.Quantity) AS quantity

&#x20;   FROM products p

&#x20;   JOIN order\_items oi ON p.Product\_Id = oi.Product\_Id

&#x20;   GROUP BY p.Category

)

SELECT

&#x20;   Category,

&#x20;   ROUND(revenue, 2) AS revenue,

&#x20;   quantity,

&#x20;   RANK() OVER (ORDER BY revenue DESC) AS category\_rank

FROM category\_sales

ORDER BY category\_rank;



\-- Q67. State performance with rank

WITH state\_sales AS (

&#x20;   SELECT

&#x20;       c.State,

&#x20;       SUM(oi.Quantity \* oi.Unit\_Price) AS revenue,

&#x20;       COUNT(DISTINCT o.Order\_Id) AS orders

&#x20;   FROM customers c

&#x20;   JOIN orders o ON c.Customer\_Id = o.Customer\_Id

&#x20;   JOIN order\_items oi ON o.Order\_Id = oi.Order\_Id

&#x20;   GROUP BY c.State

)

SELECT

&#x20;   State,

&#x20;   ROUND(revenue, 2) AS revenue,

&#x20;   orders,

&#x20;   RANK() OVER (ORDER BY revenue DESC) AS state\_rank

FROM state\_sales

ORDER BY state\_rank;



\-- Q68. Product revenue versus category average

WITH product\_sales AS (

&#x20;   SELECT

&#x20;       p.Product\_Id,

&#x20;       p.Product\_Name,

&#x20;       p.Category,

&#x20;       SUM(oi.Quantity \* oi.Unit\_Price) AS revenue

&#x20;   FROM products p

&#x20;   JOIN order\_items oi ON p.Product\_Id = oi.Product\_Id

&#x20;   GROUP BY p.Product\_Id, p.Product\_Name, p.Category

),

category\_avg AS (

&#x20;   SELECT

&#x20;       Category,

&#x20;       AVG(revenue) AS avg\_category\_product\_revenue

&#x20;   FROM product\_sales

&#x20;   GROUP BY Category

)

SELECT

&#x20;   ps.Product\_Name,

&#x20;   ps.Category,

&#x20;   ROUND(ps.revenue, 2) AS revenue,

&#x20;   ROUND(ca.avg\_category\_product\_revenue, 2) AS category\_avg\_revenue,

&#x20;   CASE

&#x20;       WHEN ps.revenue > ca.avg\_category\_product\_revenue THEN 'ABOVE CATEGORY AVERAGE'

&#x20;       ELSE 'AT OR BELOW CATEGORY AVERAGE'

&#x20;   END AS performance\_flag

FROM product\_sales ps

JOIN category\_avg ca ON ps.Category = ca.Category

ORDER BY ps.Category, ps.revenue DESC;



\-- Q69. Customer revenue concentration: top 20% customers

WITH customer\_sales AS (

&#x20;   SELECT

&#x20;       c.Customer\_Id,

&#x20;       c.Customer\_name,

&#x20;       SUM(oi.Quantity \* oi.Unit\_Price) AS revenue

&#x20;   FROM customers c

&#x20;   JOIN orders o ON c.Customer\_Id = o.Customer\_Id

&#x20;   JOIN order\_items oi ON o.Order\_Id = oi.Order\_Id

&#x20;   GROUP BY c.Customer\_Id, c.Customer\_name

),

ranked AS (

&#x20;   SELECT \*,

&#x20;          NTILE(5) OVER (ORDER BY revenue DESC) AS customer\_quintile

&#x20;   FROM customer\_sales

)

SELECT

&#x20;   customer\_quintile,

&#x20;   COUNT(\*) AS customers,

&#x20;   ROUND(SUM(revenue), 2) AS revenue

FROM ranked

GROUP BY customer\_quintile

ORDER BY customer\_quintile;





\--  **DATA QUALITY / BUSINESS VALIDATION**



\-- Q70. Check negative or zero quantities

SELECT \*

FROM order\_items

WHERE Quantity <= 0;



\-- Q71. Check negative unit prices

SELECT \*

FROM order\_items

WHERE Unit\_Price < 0;



\-- Q72. Compare product master price with transaction unit price

SELECT

&#x20;   oi.Product\_Id,

&#x20;   p.Product\_Name,

&#x20;   p.Price AS master\_price,

&#x20;   oi.Unit\_Price AS transaction\_price,

&#x20;   ROUND(oi.Unit\_Price - p.Price, 2) AS price\_difference

FROM order\_items oi

JOIN products p ON oi.Product\_Id = p.Product\_Id

WHERE oi.Unit\_Price <> p.Price

ORDER BY ABS(oi.Unit\_Price - p.Price) DESC;



\-- Q73. Orders without line items

SELECT o.\*

FROM orders o

LEFT JOIN order\_items oi ON o.Order\_Id = oi.Order\_Id

WHERE oi.Order\_Id IS NULL;



\-- Q74. Customer order status distribution

SELECT

&#x20;   o.Order\_Status,

&#x20;   COUNT(DISTINCT o.Order\_Id) AS orders,

&#x20;   ROUND(

&#x20;       COUNT(DISTINCT o.Order\_Id) /

&#x20;       NULLIF((SELECT COUNT(\*) FROM orders), 0) \* 100,

&#x20;       2

&#x20;   ) AS order\_pct

FROM orders o

GROUP BY o.Order\_Status

ORDER BY orders DESC;



\-- Q75. Final executive dataset: product performance

WITH product\_sales AS (

&#x20;   SELECT

&#x20;       p.Product\_Id,

&#x20;       p.Product\_Name,

&#x20;       p.Category,

&#x20;       SUM(oi.Quantity \* oi.Unit\_Price) AS revenue,

&#x20;       SUM(oi.Quantity) AS quantity

&#x20;   FROM products p

&#x20;   JOIN order\_items oi ON p.Product\_Id = oi.Product\_Id

&#x20;   GROUP BY p.Product\_Id, p.Product\_Name, p.Category

)

SELECT

&#x20;   Product\_Id,

&#x20;   Product\_Name,

&#x20;   Category,

&#x20;   ROUND(revenue, 2) AS revenue,

&#x20;   quantity,

&#x20;   RANK() OVER (ORDER BY revenue DESC) AS revenue\_rank,

&#x20;   ROUND(revenue / NULLIF(SUM(revenue) OVER (), 0) \* 100, 2) AS contribution\_pct

FROM product\_sales

ORDER BY revenue\_rank;




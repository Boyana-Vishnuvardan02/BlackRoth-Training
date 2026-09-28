**SQL Query Documentation**



Database: SALES\_ANALYSIS\_DB

Tables: CUSTOMERS, PRODUCTS, ORDERS, ORDER\_ITEMS

Analysis Period: April–September 2025



**Business Objective**



**Analyze e-commerce sales performance to identify**



* Overall sales KPIs



* Monthly revenue trends



* Category and product performance



* Regional performance



* Top customers and inactive customers



* Order-value patterns



* Order-status performance



* Low-performing products



**Dataset Summary**



1. Customers : 30

2. Products : 25

3. Orders : 60

4. Order Items : 105





**Database Inspection**





**Query 1 – Display customers**



SELECT \* FROM CUSTOMERS;



**Query 2 – Display products**



SELECT \* FROM PRODUCTS;



**Query 3 – Display orders**



SELECT \* FROM ORDERS;



**Query 4 – Display order items**



SELECT \* FROM ORDER\_ITEMS;



**Query 5 – Count customers**



SELECT COUNT(\*) AS TOTAL\_CUSTOMERS

FROM CUSTOMERS;



**Query 6 – Count products**



SELECT COUNT(\*) AS TOTAL\_PRODUCTS

FROM PRODUCTS;



**Query 7 – Count orders**



SELECT COUNT(\*) AS TOTAL\_ORDERS

FROM ORDERS;



**Query 8 – Count order items**



SELECT COUNT(\*) AS TOTAL\_ORDER\_ITEMS

FROM ORDER\_ITEMS;



**Data Quality Checks**



Query 9 – Missing customer names



SELECT \*

FROM CUSTOMERS

WHERE CUSTOMER\_NAME IS NULL;



**Query 10 – Missing customer emails**



SELECT \*

FROM CUSTOMERS

WHERE EMAIL IS NULL;



**Query 11 – Missing product names**



SELECT \*

FROM PRODUCTS

WHERE PRODUCT\_NAME IS NULL;



**Query 12 – Missing product categories**



SELECT \*

FROM PRODUCTS

WHERE CATEGORY IS NULL;



**Query 13 – Missing product prices**



SELECT \*

FROM PRODUCTS

WHERE PRICE IS NULL;



**Query 14 – Missing order dates**



SELECT \*

FROM ORDERS

WHERE ORDER\_DATE IS NULL;



**Query 15 – Missing order status**



SELECT \*

FROM ORDERS

WHERE ORDER\_STATUS IS NULL;



**Query 16 – Duplicate customer emails**



SELECT EMAIL, COUNT(\*) AS DUPLICATE\_COUNT

FROM CUSTOMERS

GROUP BY EMAIL

HAVING COUNT(\*) > 1;



**Query 17 – Duplicate product names**



SELECT PRODUCT\_NAME, COUNT(\*) AS DUPLICATE\_COUNT

FROM PRODUCTS

GROUP BY PRODUCT\_NAME

HAVING COUNT(\*) > 1;



**Monthly Revenue Analysis**



**Query 18 – Monthly revenue**



SELECT YEAR(O.ORDER\_DATE) AS ORDER\_YEAR,MONTH(O.ORDER\_DATE) AS ORDER\_MONTH,SUM(OI.QUANTITY \* OI.UNIT\_PRICE) AS MONTHLY\_REVENUE

FROM ORDERS O

JOIN ORDER\_ITEMS OI

ON O.ORDER\_ID = OI.ORDER\_ID

GROUP BY YEAR(O.ORDER\_DATE), MONTH(O.ORDER\_DATE)

ORDER BY ORDER\_YEAR, ORDER\_MONTH;



**Business Purpose:** Identify the strongest and weakest sales months.



**Category Performance**



**Query 19 – Category-wise revenue**



SELECT P.CATEGORY,SUM(OI.QUANTITY \* OI.UNIT\_PRICE) AS TOTAL\_REVENUE

FROM PRODUCTS P

JOIN ORDER\_ITEMS OI

ON P.PRODUCT\_ID = OI.PRODUCT\_ID

GROUP BY P.CATEGORY

ORDER BY TOTAL\_REVENUE DESC;



**Query 20 – Category-wise quantity sold**



SELECT P.CATEGORY,SUM(OI.QUANTITY) AS TOTAL\_QUANTITY\_SOLD

FROM PRODUCTS P

JOIN ORDER\_ITEMS OI

ON P.PRODUCT\_ID = OI.PRODUCT\_ID

GROUP BY P.CATEGORY

ORDER BY TOTAL\_QUANTITY\_SOLD DESC;



**Query 21 – Category-wise average product price**



SELECT CATEGORY,

AVG(PRICE) AS AVERAGE\_PRICE

FROM PRODUCTS

GROUP BY CATEGORY

ORDER BY AVERAGE\_PRICE DESC;



**Product Performance**



**Query 22 – Product-wise revenue**



SELECT P.PRODUCT\_ID,P.PRODUCT\_NAME,SUM(OI.QUANTITY \* OI.UNIT\_PRICE) AS TOTAL\_REVENUE

FROM PRODUCTS P

JOIN ORDER\_ITEMS OI

ON P.PRODUCT\_ID = OI.PRODUCT\_ID

GROUP BY P.PRODUCT\_ID, P.PRODUCT\_NAME

ORDER BY TOTAL\_REVENUE DESC;



**Query 23 – Top 10 products**



SELECT P.PRODUCT\_ID,P.PRODUCT\_NAME,SUM(OI.QUANTITY \* OI.UNIT\_PRICE) AS TOTAL\_REVENUE

FROM PRODUCTS P

JOIN ORDER\_ITEMS OI 

ON P.PRODUCT\_ID = OI.PRODUCT\_ID

GROUP BY P.PRODUCT\_ID, P.PRODUCT\_NAME

ORDER BY TOTAL\_REVENUE DESC

LIMIT 10;



**Query 24 – Low-performing products**



SELECT P.PRODUCT\_ID,P.PRODUCT\_NAME,COALESCE(SUM(OI.QUANTITY \* OI.UNIT\_PRICE), 0) AS TOTAL\_REVENUE

FROM PRODUCTS P

LEFT JOIN ORDER\_ITEMS OI

ON P.PRODUCT\_ID = OI.PRODUCT\_ID

GROUP BY P.PRODUCT\_ID, P.PRODUCT\_NAME

ORDER BY TOTAL\_REVENUE ASC;



**Business Purpose:** Identify products requiring promotion, pricing review, inventory review, or possible discontinuation.



**Regional Performance**



**Query 25 – State-wise revenue**



SELECT C.STATE,SUM(OI.QUANTITY \* OI.UNIT\_PRICE) AS TOTAL\_REVENUE

FROM CUSTOMERS C

JOIN ORDERS O

ON C.CUSTOMER\_ID = O.CUSTOMER\_ID

JOIN ORDER\_ITEMS OI

ON O.ORDER\_ID = OI.ORDER\_ID

GROUP BY C.STATE

ORDER BY TOTAL\_REVENUE DESC;



**Query 26 – City-wise revenue**



SELECT C.CITY,SUM(OI.QUANTITY \* OI.UNIT\_PRICE) AS TOTAL\_REVENUE

FROM CUSTOMERS C

JOIN ORDERS O

ON C.CUSTOMER\_ID = O.CUSTOMER\_ID

JOIN ORDER\_ITEMS OI

ON O.ORDER\_ID = OI.ORDER\_ID

GROUP BY C.CITY

ORDER BY TOTAL\_REVENUE DESC;



**Business Purpose:** Identify high-performing geographic markets.



**Customer Analysis**



**Query 27 – Customer-wise revenue**



SELECT C.CUSTOMER\_ID,C.CUSTOMER\_NAME,SUM(OI.QUANTITY \* OI.UNIT\_PRICE) AS TOTAL\_REVENUE

FROM CUSTOMERS C

JOIN ORDERS O

ON C.CUSTOMER\_ID = O.CUSTOMER\_ID

JOIN ORDER\_ITEMS OI

ON O.ORDER\_ID = OI.ORDER\_ID

GROUP BY C.CUSTOMER\_ID, C.CUSTOMER\_NAME

ORDER BY TOTAL\_REVENUE DESC;



**Query 28 – Top 10 customers**



SELECT C.CUSTOMER\_ID,C.CUSTOMER\_NAME,SUM(OI.QUANTITY \* OI.UNIT\_PRICE) AS TOTAL\_REVENUE

FROM CUSTOMERS C

JOIN ORDERS O

ON C.CUSTOMER\_ID = O.CUSTOMER\_ID

JOIN ORDER\_ITEMS OI

ON O.ORDER\_ID = OI.ORDER\_ID

GROUP BY C.CUSTOMER\_ID, C.CUSTOMER\_NAME

ORDER BY TOTAL\_REVENUE DESC

LIMIT 10;



**Query 29 – Customers with no purchases**



SELECT C.CUSTOMER\_ID,C.CUSTOMER\_NAME

FROM CUSTOMERS C

LEFT JOIN ORDERS O

ON C.CUSTOMER\_ID = O.CUSTOMER\_ID

WHERE O.ORDER\_ID IS NULL;



**Business Purpose:** Identify high-value customers and customers who have registered but never purchased.



**Order Analysis**



**Query 30 – Order-wise revenue**



SELECT ORDER\_ID,SUM(QUANTITY \* UNIT\_PRICE) AS ORDER\_VALUE

FROM ORDER\_ITEMS

GROUP BY ORDER\_ID

ORDER BY ORDER\_VALUE DESC;



**Query 31 – Highest-value order**



SELECT ORDER\_ID,SUM(QUANTITY \* UNIT\_PRICE) AS ORDER\_VALUE

FROM ORDER\_ITEMS

GROUP BY ORDER\_ID

ORDER BY ORDER\_VALUE DESC

LIMIT 1;



**Query 32 – Lowest-value order**



SELECT ORDER\_ID,SUM(QUANTITY \* UNIT\_PRICE) AS ORDER\_VALUE

FROM ORDER\_ITEMS

GROUP BY ORDER\_ID

ORDER BY ORDER\_VALUE ASC

LIMIT 1;



**Query 33 – Average Order Value**



SELECT AVG(ORDER\_VALUE) AS AVERAGE\_ORDER\_VALUE

FROM (

SELECT ORDER\_ID,SUM(QUANTITY \* UNIT\_PRICE) AS ORDER\_VALUE

FROM ORDER\_ITEMS

GROUP BY ORDER\_ID) AS ORDER\_TOTALS;



**Business Purpose:** Measure typical transaction size and identify unusually high- or low-value orders.



**Order Status Analysis**



**Query 34 – Order count by status**



SELECT ORDER\_STATUS,COUNT(\*) AS ORDER\_COUNT

FROM ORDERS

GROUP BY ORDER\_STATUS

ORDER BY ORDER\_COUNT DESC;



**Query 35 – Revenue by order status**



SELECT O.ORDER\_STATUS,SUM(OI.QUANTITY \* OI.UNIT\_PRICE) AS TOTAL\_REVENUE

FROM ORDERS O

JOIN ORDER\_ITEMS OI

ON O.ORDER\_ID = OI.ORDER\_ID

GROUP BY O.ORDER\_STATUS

ORDER BY TOTAL\_REVENUE DESC;



**Business Purpose:** Monitor completed, pending, and cancelled order activity.














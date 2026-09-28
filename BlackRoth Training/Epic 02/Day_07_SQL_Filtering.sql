USE SALES_ANALYSIS_DB;

SELECT * FROM CUSTOMERS;
SELECT * FROM PRODUCTS;
SELECT * FROM ORDERS;
SELECT * FROM ORDER_ITEMS;

#Find all customers who are from Hyderabad.
SELECT * FROM CUSTOMERS
WHERE CITY = "HYDERABAD";

#Find all customers who are from Chennai.
SELECT * FROM CUSTOMERS
WHERE CITY = "CHENNAI";

#Find products with a price greater than ₹5,000.
SELECT * FROM PRODUCTS
WHERE PRICE>5000;

#Find products with a price less than ₹2,000.
SELECT * FROM PRODUCTS
WHERE PRICE < 2000;

#Find orders with an order amount greater than ₹10,000.
SELECT *,QUANTITY * UNIT_PRICE AS ORDER_VALUE
FROM ORDER_ITEMS
WHERE QUANTITY * UNIT_PRICE > 10000;

#Find orders with an order amount less than or equal to ₹5,000.
SELECT *, QUANTITY * UNIT_PRICE AS ORDER_VALUE FROM ORDER_ITEMS
WHERE QUANTITY * UNIT_PRICE <= 5000;

#Find orders whose status is 'COMPLETED'.
SELECT * FROM ORDERS
WHERE ORDER_STATUS = "COMPLETED";

#Find customers whose state is 'TELANGANA'
SELECT * FROM CUSTOMERS
WHERE STATE = "TELANAGAN";

# Find products that belong to the Electronics category and have a price greater than ₹10,000.
SELECT * FROM PRODUCTS
WHERE CATEGORY = "ELECTRONICS" AND PRICE > 10000;

# Find customers who are from Hyderabad AND belong to the TELANGANA region.
SELECT * FROM CUSTOMERS
WHERE CITY = "HYDERABAD" AND STATE = "TELANGANA";

# Find orders where the order amount is greater than ₹5,000 AND the status is 'COMPLETED'.
SELECT OI.*,OI.QUANTITY*OI.UNIT_PRICE AS ORDER_AMOUNT,O.ORDER_STATUS FROM ORDER_ITEMS OI
JOIN ORDERS O
ON OI.ORDER_ID = O.ORDER_ID
WHERE OI.QUANTITY*OI.UNIT_PRICE > 5000 AND O.ORDER_STATUS = "COMPLETED";

# Find products that belong to either Electronics OR Furniture.
SELECT * FROM PRODUCTS
WHERE CATEGORY = "ELECTRONICS" OR CATEGORY = "FURNITURES";

# Find customers who are NOT from Hyderabad.
SELECT * FROM CUSTOMERS
WHERE CITY != "HYDERABAD";

#Find orders that are NOT cancelled
SELECT * FROM ORDERS
WHERE ORDER_STATUS != "CANCELLED";

#Customers from Hyderabad, Chennai or Bangalore
SELECT * FROM CUSTOMERS
WHERE CITY IN ('HYDERABAD','CHENNAI','BANGALORE');

#Products between ₹5,000 and ₹20,000
SELECT * FROM PRODUCTS
WHERE PRICE BETWEEN 5000 AND 20000;

#Order items between ₹10,000 and ₹50,000
SELECT *,QUANTITY*UNIT_PRICE AS ORDER_VALUE FROM ORDER_ITEMS
WHERE QUANTITY*UNIT_PRICE BETWEEN 10000 AND 50000;

#Customers whose name starts with A
SELECT * FROM CUSTOMERS 
WHERE CUSTOMER_NAME LIKE 'A%';

#Customers whose name contains "an"
SELECT * FROM CUSTOMERS
WHERE CUSTOMER_NAME LIKE '%AN%';

#Customers whose name contains exactly 5 characters
SELECT * FROM CUSTOMERS
WHERE CUSTOMER_NAME LIKE '_____';

#Customers with missing email
SELECT * FROM CUSTOMERS
WHERE EMAIL IS NULL;

#Customers whose email is available
SELECT * FROM CUSTOMERS
WHERE EMAIL IS NOT NULL;

#Customers with missing email OR city
SELECT * FROM CUSTOMERS
WHERE CITY IS NULL OR EMAIL IS NULL;

#Business Questions
#Which orders are above ₹10,000? 
SELECT P.*,OI.ORDER_ID FROM PRODUCTS P
JOIN ORDER_ITEMS OI
ON P.PRODUCT_ID = OI.PRODUCT_ID
WHERE PRICE > 10000;

#Which customers belong to Hyderabad? 
SELECT * FROM CUSTOMERS
WHERE CITY = "HYDERABAD";

# Which products belong to a particular category
SELECT CATEGORY,PRODUCT_NAME,PRICE FROM PRODUCTS
WHERE CATEGORY = 'ELECTRONICS';

#Which orders occurred during a specific month? 
SELECT * FROM ORDERS
WHERE MONTH(ORDER_DATE) = 04 AND YEAR(ORDER_DATE)=2025;

#Which customers have missing information?
SELECT * FROM CUSTOMERS
WHERE EMAIL IS NULL;


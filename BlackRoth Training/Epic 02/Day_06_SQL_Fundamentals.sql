CREATE DATABASE SALES_ANALYSIS_DB;

USE SALES_ANALYSIS_DB;

CREATE TABLE CUSTOMERS (
    Customer_Id INT PRIMARY KEY,
    Customer_Name VARCHAR(100),
    Email VARCHAR(100),
    City VARCHAR(50),
    State VARCHAR(50),
    Registration_Date DATE
);

INSERT INTO CUSTOMERS
(Customer_Id, Customer_Name, Email, City, State, Registration_Date)
VALUES
(1, 'Rahul Sharma', 'rahul@gmail.com', 'Hyderabad', 'Telangana', '2025-01-10'),
(2, 'Priya Reddy', 'priya@gmail.com', 'Bangalore', 'Karnataka', '2025-01-15'),
(3, 'Arjun Kumar', 'arjun@gmail.com', 'Chennai', 'Tamil Nadu', '2025-02-05'),
(4, 'Sneha Patel', 'sneha@gmail.com', 'Mumbai', 'Maharashtra', '2025-02-12'),
(5, 'Vikram Singh', 'vikram@gmail.com', 'Delhi', 'Delhi', '2025-02-20'),
(6, 'Anjali Rao', 'anjali@gmail.com', 'Hyderabad', 'Telangana', '2025-03-01'),
(7, 'Kiran Reddy', 'kiran@gmail.com', 'Pune', 'Maharashtra', '2025-03-10'),
(8, 'Neha Verma', 'neha@gmail.com', 'Delhi', 'Delhi', '2025-03-15'),
(9, 'Rohit Mehta', 'rohit@gmail.com', 'Ahmedabad', 'Gujarat', '2025-03-20'),
(10, 'Pooja Nair', 'pooja@gmail.com', 'Kochi', 'Kerala', '2025-04-01');

SELECT * FROM CUSTOMERS;

CREATE TABLE PRODUCTS (
    Product_Id INT PRIMARY KEY,
    Product_Name VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10,2),
    Stock_Quantity INT
);

INSERT INTO PRODUCTS
(Product_Id, Product_Name, Category, Price, Stock_Quantity)
VALUES
(101, 'Laptop', 'Electronics', 55000.00, 25),
(102, 'Smartphone', 'Electronics', 30000.00, 40),
(103, 'Headphones', 'Accessories', 2500.00, 100),
(104, 'Keyboard', 'Accessories', 1500.00, 80),
(105, 'Mouse', 'Accessories', 800.00, 120),
(106, 'Monitor', 'Electronics', 12000.00, 35),
(107, 'Office Chair', 'Furniture', 8500.00, 20),
(108, 'Desk', 'Furniture', 10000.00, 15),
(109, 'Tablet', 'Electronics', 22000.00, 30),
(110, 'Webcam', 'Accessories', 3500.00, 50);

SELECT * FROM PRODUCTS;

CREATE TABLE ORDERS (
    Order_Id INT PRIMARY KEY,
    Customer_Id INT,
    Order_Date DATE,
    Order_Status VARCHAR(30),
    FOREIGN KEY (Customer_Id) REFERENCES CUSTOMERS(Customer_Id)
);

INSERT INTO ORDERS
(Order_Id, Customer_Id, Order_Date, Order_Status)
VALUES
(1001, 1, '2025-04-05', 'Completed'),
(1002, 2, '2025-04-07', 'Completed'),
(1003, 3, '2025-04-10', 'Pending'),
(1004, 4, '2025-04-12', 'Completed'),
(1005, 5, '2025-04-15', 'Cancelled'),
(1006, 6, '2025-04-18', 'Completed'),
(1007, 7, '2025-04-20', 'Completed'),
(1008, 8, '2025-04-22', 'Pending'),
(1009, 9, '2025-04-25', 'Completed'),
(1010, 10, '2025-04-28', 'Completed');

SELECT * FROM ORDERS;

CREATE TABLE ORDER_ITEMS (
    Order_Item_Id INT PRIMARY KEY,
    Order_Id INT,
    Product_Id INT,
    Quantity INT,
    Unit_Price DECIMAL(10,2),
    FOREIGN KEY (Order_Id) REFERENCES ORDERS(order_id),
    FOREIGN KEY (Product_Id) REFERENCES PRODUCTS(product_id)
);

INSERT INTO ORDER_ITEMS
(Order_Item_Id, Order_Id, Product_Id, Quantity, Unit_Price)
VALUES
(1, 1001, 101, 1, 55000.00),
(2, 1001, 105, 2, 800.00),

(3, 1002, 102, 1, 30000.00),
(4, 1002, 103, 2, 2500.00),

(5, 1003, 109, 1, 22000.00),

(6, 1004, 106, 2, 12000.00),
(7, 1004, 104, 1, 1500.00),

(8, 1005, 107, 1, 8500.00),

(9, 1006, 108, 1, 10000.00),
(10, 1006, 105, 2, 800.00),

(11, 1007, 101, 1, 55000.00),
(12, 1007, 110, 1, 3500.00),

(13, 1008, 103, 3, 2500.00),

(14, 1009, 102, 2, 30000.00),
(15, 1009, 105, 1, 800.00),

(16, 1010, 109, 1, 22000.00),
(17, 1010, 110, 2, 3500.00);

SELECT * FROM ORDER_ITEMS;

# ALL TABLES

SELECT * FROM CUSTOMERS;
SELECT * FROM PRODUCTS;
SELECT * FROM ORDERS;
SELECT * FROM ORDER_ITEMS;

# 20 BASIC SQL QUERIES

# Display only customer_name and city from the customers table
SELECT Customer_Name,City from Customers;

# Display product_name, category, and price from the products table
SELECT Product_Name, Category, Price from Products;

# Display order_id, order_date, and order_status from the orders table
SELECT Order_Id, Order_Date, Order_Status from ORDERS;

# Display customer_name but rename the column 
SELECT Customer_Name as CN FROM CUSTOMERS;

# Display product_name and price but rename them 
SELECT Product_Name AS PN, Price AS Cost FROM PRODUCTS;

# Display all unique product categories from the products table
SELECT DISTINCT(CATEGORY) FROM PRODUCTS;

# Display all unique cities from the customers table
SELECT DISTINCT(CITY) FROM CUSTOMERS;

# Display only the first 5 records from the customers table
SELECT * FROM CUSTOMERS
LIMIT 5;

# Display only the first 3 products from the products table
SELECT * FROM PRODUCTS
LIMIT 3;

# Display only the first 5 orders from the orders table
SELECT * FROM ORDERS
LIMIT 5;

# Display all products sorted by price from lowest to highest
SELECT * FROM PRODUCTS
ORDER BY PRICE ASC;

# Display all customers sorted alphabetically by customer_name
SELECT * FROM CUSTOMERS
ORDER BY CuStomer_Name ASC;

# Display all orders sorted by order_date from oldest to newest
SELECT * FROM ORDERS
ORDER BY Order_Date ASC;

# Display all products sorted by price from highest to lowest
SELECT * FROM PRODUCTS
ORDER BY PRICE DESC;

# Display all products sorted by stock_quantity from highest to lowest.
SELECT * FROM PRODUCTS 
ORDER BY Stock_Quantity DESC;

# Display all customers sorted by registration_date from newest to oldest
SELECT * FROM CUSTOMERS
ORDER BY Registration_Date DESC;

# Display the 3 most expensive products, showing only product_name and price
SELECT Product_Name, Price FROM PRODUCTS
ORDER BY Price DESC
LIMIT 3;

# Display all unique combinations of city and state from customers. Rename city as Customer_City
SELECT DISTINCT(City) AS Customer_City, State FROM CUSTOMERS;

# Display all products with: product_name,category,price and Sort first by category ascending, and within each category sort price descending.
SELECT Product_Name, Category, Price FROM PRODUCTS
ORDER BY Category ASC, Price DESC;
DROP DATABASE IF EXISTS retail_sales_analytics;

CREATE DATABASE retail_sales_analytics;

USE retail_sales_analytics;

-- =====================================================
-- TASK 1 : VERIFY IMPORTED DATA
-- =====================================================

SELECT COUNT(*) AS brands FROM brands;

SELECT COUNT(*) AS categories FROM categories;

SELECT COUNT(*) AS customers FROM customers;

SELECT COUNT(*) AS products FROM products;

SELECT COUNT(*) AS stores FROM stores;

SELECT COUNT(*) AS staffs FROM staffs;

SELECT COUNT(*) AS orders FROM orders;

SELECT COUNT(*) AS order_items FROM order_items;

SELECT COUNT(*) AS stocks FROM stocks;

-- =====================================================
-- TASK 2 : ADD PRIMARY KEYS
-- =====================================================

ALTER TABLE brands
ADD PRIMARY KEY (brand_id);

ALTER TABLE categories
ADD PRIMARY KEY (category_id);

ALTER TABLE customers
ADD PRIMARY KEY (customer_id);

ALTER TABLE stores
ADD PRIMARY KEY (store_id);

ALTER TABLE products
ADD PRIMARY KEY (product_id);

ALTER TABLE staffs
ADD PRIMARY KEY (staff_id);

ALTER TABLE orders
ADD PRIMARY KEY (order_id);

ALTER TABLE order_items
ADD PRIMARY KEY (order_id, item_id);

ALTER TABLE stocks
ADD PRIMARY KEY (store_id, product_id);

-- =====================================================
-- CHECK BRANDS TABLE COLUMN NAMES
-- =====================================================

SHOW COLUMNS FROM brands;

-- =====================================================
-- FIX IMPORTED COLUMN HEADERS
-- =====================================================

ALTER TABLE categories
CHANGE COLUMN `ï»¿category_id` category_id INT;

ALTER TABLE customers
CHANGE COLUMN `ï»¿customer_id` customer_id INT;

ALTER TABLE products
CHANGE COLUMN `ï»¿product_id` product_id INT;

ALTER TABLE stores
CHANGE COLUMN `ï»¿store_id` store_id INT;

ALTER TABLE staffs
CHANGE COLUMN `ï»¿staff_id` staff_id INT;

ALTER TABLE orders
CHANGE COLUMN `ï»¿order_id` order_id INT;

ALTER TABLE order_items
CHANGE COLUMN `ï»¿order_id` order_id INT;

ALTER TABLE stocks
CHANGE COLUMN `ï»¿store_id` store_id INT;

-- =====================================================
-- FIX BRANDS COLUMN NAME
-- =====================================================

ALTER TABLE brands
CHANGE COLUMN `ï»¿brand_id` brand_id INT;

-- =====================================================
-- VERIFY PRIMARY KEYS
-- =====================================================

SHOW INDEX FROM brands;
SHOW INDEX FROM categories;
SHOW INDEX FROM customers;
SHOW INDEX FROM stores;
SHOW INDEX FROM products;
SHOW INDEX FROM staffs;
SHOW INDEX FROM orders;
SHOW INDEX FROM order_items;
SHOW INDEX FROM stocks;

-- =====================================================
-- TASK 3 : ADD FOREIGN KEY CONSTRAINTS
-- =====================================================

-- Products → Brands
ALTER TABLE products
ADD CONSTRAINT fk_products_brand
FOREIGN KEY (brand_id)
REFERENCES brands(brand_id);

-- Products → Categories
ALTER TABLE products
ADD CONSTRAINT fk_products_category
FOREIGN KEY (category_id)
REFERENCES categories(category_id);

-- Staffs → Stores
ALTER TABLE staffs
ADD CONSTRAINT fk_staffs_store
FOREIGN KEY (store_id)
REFERENCES stores(store_id);

-- Staffs → Manager
ALTER TABLE staffs
ADD CONSTRAINT fk_staffs_manager
FOREIGN KEY (manager_id)
REFERENCES staffs(staff_id);

-- Orders → Customers
ALTER TABLE orders
ADD CONSTRAINT fk_orders_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

-- Orders → Stores
ALTER TABLE orders
ADD CONSTRAINT fk_orders_store
FOREIGN KEY (store_id)
REFERENCES stores(store_id);

-- Orders → Staffs
ALTER TABLE orders
ADD CONSTRAINT fk_orders_staff
FOREIGN KEY (staff_id)
REFERENCES staffs(staff_id);

-- Order Items → Orders
ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id);

-- Order Items → Products
ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_product
FOREIGN KEY (product_id)
REFERENCES products(product_id);

-- Stocks → Stores
ALTER TABLE stocks
ADD CONSTRAINT fk_stocks_store
FOREIGN KEY (store_id)
REFERENCES stores(store_id);

-- Stocks → Products
ALTER TABLE stocks
ADD CONSTRAINT fk_stocks_product
FOREIGN KEY (product_id)
REFERENCES products(product_id);

-- =====================================================
-- FIX MANAGER_ID DATATYPE
-- =====================================================

ALTER TABLE staffs
MODIFY COLUMN manager_id INT NULL;

-- =====================================================
-- ADD SELF FOREIGN KEY FOR STAFF MANAGER
-- =====================================================

ALTER TABLE staffs
ADD CONSTRAINT fk_staffs_manager
FOREIGN KEY (manager_id)
REFERENCES staffs(staff_id);

UPDATE staffs
SET manager_id = NULL
WHERE manager_id = 'NULL'
   OR manager_id = '';
   
   -- =====================================================
-- TASK 4 : INNER JOIN FOR ORDER DETAILS
-- =====================================================

SELECT
    o.order_id,
    o.order_date,
    oi.item_id,
    p.product_name,
    oi.quantity,
    oi.list_price,
    oi.discount,
    oi.total_price
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
ORDER BY o.order_id
LIMIT 100;

-- =====================================================
-- TASK 5 : TOTAL SALES BY STORE
-- =====================================================

SELECT
    s.store_id,
    s.store_name,
    ROUND(SUM(oi.total_price), 2) AS total_sales
FROM stores s
INNER JOIN orders o
    ON s.store_id = o.store_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    s.store_id,
    s.store_name
ORDER BY
    total_sales DESC;
    
    
    -- =====================================================
-- TASK 6 : TOP 5 SELLING PRODUCTS
-- =====================================================

SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold,
    ROUND(SUM(oi.total_price), 2) AS total_revenue
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY
    total_quantity_sold DESC
LIMIT 5;

-- =====================================================
-- TASK 7 : CUSTOMER PURCHASE SUMMARY
-- =====================================================

SELECT
    c.customer_id,
    c.frist_name,
    c.last_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity) AS total_items_purchased,
    ROUND(SUM(oi.total_price), 2) AS total_revenue
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY
    c.customer_id,
    c.frist_name,
    c.last_name
ORDER BY
    total_revenue DESC;
    
SELECT * FROM customers LIMIT 5;

-- =====================================================
-- FIX CUSTOMER FIRST NAME COLUMN
-- =====================================================

ALTER TABLE customers
CHANGE COLUMN frist_name first_name TEXT;

-- =====================================================
-- TASK 8 : SEGMENT CUSTOMERS BY TOTAL SPEND
-- =====================================================

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    ROUND(SUM(oi.total_price), 2) AS total_spend,

    CASE
        WHEN SUM(oi.total_price) >= 10000 THEN 'High Value'
        WHEN SUM(oi.total_price) >= 5000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment

FROM customers c

INNER JOIN orders o
    ON c.customer_id = o.customer_id

INNER JOIN order_items oi
    ON o.order_id = oi.order_id

GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name

ORDER BY total_spend DESC;


    -- =====================================================
-- TASK 09 STAFF PERFORMANCE ANALYSIS
-- =====================================================

SELECT
    s.staff_id,
    s.first_name,
    s.last_name,
    COUNT(DISTINCT o.order_id) AS total_orders_handled,
    ROUND(SUM(oi.total_price), 2) AS total_revenue

FROM staffs s

INNER JOIN orders o
    ON s.staff_id = o.staff_id

INNER JOIN order_items oi
    ON o.order_id = oi.order_id

GROUP BY
    s.staff_id,
    s.first_name,
    s.last_name

ORDER BY
    total_revenue DESC;
    
    -- =====================================================
-- TASK 10 : CREATE FINAL CUSTOMER SEGMENTS TABLE
-- =====================================================

CREATE TABLE customer_segments (

    customer_id INT PRIMARY KEY,

    customer_name VARCHAR(100),

    total_spend DECIMAL(12,2),

    segment VARCHAR(20)

);

DESCRIBE customer_segments;

-- ==========================================
-- TASK 10 : CREATE CUSTOMER SEGMENTS TABLE
-- ==========================================

CREATE TABLE customer_segments (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    recency INT,
    frequency INT,
    monetary DECIMAL(12,2),
    segment_label VARCHAR(50)
);
-- ==========================================
-- USE DATABASE
-- ==========================================

USE retail_sales_analytics;


-- =====================================================
-- VERIFY CUSTOMER SEGMENTS TABLE
-- =====================================================

DESCRIBE customer_segments;
USE retail_sales_analytics;

DROP TABLE customer_segments;
CREATE TABLE customer_segments (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    recency INT,
    frequency INT,
    monetary DECIMAL(12,2),
    segment_label VARCHAR(50)
);

SELECT * FROM customer_segments LIMIT 10;

SELECT COUNT(*) FROM customer_segments;

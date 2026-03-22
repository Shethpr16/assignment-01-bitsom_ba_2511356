-- ==========================
-- 3NF Schema Design
-- ==========================

-- Customers
CREATE TABLE customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    customer_name VARCHAR(150) NOT NULL,
    email VARCHAR(200),
    city VARCHAR(100) NOT NULL
);

-- Sales Representatives
CREATE TABLE sales_reps (
    sales_rep_id VARCHAR(10) PRIMARY KEY,
    sales_rep_name VARCHAR(150) NOT NULL,
    email VARCHAR(200),
    office_address TEXT
);

-- Products
CREATE TABLE products (
    product_id VARCHAR(10) PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    category VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL
);

-- Orders
CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    order_date DATE NOT NULL,
    customer_id VARCHAR(10) NOT NULL,
    sales_rep_id VARCHAR(10) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (sales_rep_id) REFERENCES sales_reps(sales_rep_id)
);

-- Order Items
CREATE TABLE order_items (
    order_id VARCHAR(20),
    product_id VARCHAR(10),
    quantity INT NOT NULL,
    unit_price_at_sale DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ==========================
-- Sample INSERT Statements
-- ==========================

-- Customers
INSERT INTO customers VALUES
('C001','Rohan Mehta','rohan@gmail.com','Mumbai'),
('C002','Priya Sharma','priya@gmail.com','Delhi'),
('C003','Amit Verma','amit@gmail.com','Bangalore'),
('C004','Sneha Iyer','sneha@gmail.com','Chennai'),
('C008','Kavya Rao','kavya@gmail.com','Hyderabad');

-- Sales Representatives
INSERT INTO sales_reps VALUES
('SR01','Deepak Joshi','deepak@corp.com','Mumbai HQ, Nariman Point'),
('SR02','Anita Desai','anita@corp.com','Delhi Office, Connaught Place'),
('SR03','Ravi Kumar','ravi@corp.com','MG Road, Bangalore');

-- Products
INSERT INTO products VALUES
('P001','Laptop','Electronics',55000),
('P002','Mouse','Electronics',800),
('P003','Desk Chair','Furniture',8500),
('P004','Notebook','Stationery',120),
('P005','Headphones','Electronics',3200);

-- Orders
INSERT INTO orders VALUES
('ORD1000','2023-05-21','C002','SR03'),
('ORD1012','2023-05-29','C001','SR01'),
('ORD1042','2023-01-11','C004','SR02'),
('ORD1091','2023-07-24','C001','SR01'),
('ORD1185','2023-06-15','C003','SR03');

-- Order Items
INSERT INTO order_items VALUES
('ORD1000','P001',2,55000),
('ORD1012','P002',1,800),
('ORD1042','P001',5,55000),
('ORD1091','P003',3,22000),
('ORD1185','P005',1,3200);

-- =============================================================================
-- SQL Test File with Intentional Errors  
-- Tests for sqlfluff
-- =============================================================================

-- Error: Keywords not uppercase
select * from users where id = 1;
insert into products values (1, 'Product');
delete from orders where status = 'cancelled';

-- Error: Inconsistent capitalization
SELECT * FROM Users WHERE Id = 1;
SeLeCt * FrOm PRODUCTS;

-- Error: Missing spaces around operators
SELECT * FROM users WHERE age>=18 AND status='active';
SELECT price*quantity AS total FROM items;

-- Error: Incorrect indentation
SELECT id, name, email
FROM users
WHERE status = 'active'
AND created_at > '2024-01-01'
ORDER BY name;

-- Error: Comma positioning (leading vs trailing)
SELECT 
    id
    ,name  -- Leading comma (some styles forbid this)
    ,email
    ,created_at
FROM users;

-- Error: Wildcard in production code
SELECT * FROM large_table;
SELECT t1.*, t2.* FROM table1 t1 JOIN table2 t2 ON t1.id = t2.id;

-- Error: Implicit join (old style)
SELECT * FROM users, orders WHERE users.id = orders.user_id;

-- Error: Missing table aliases in join
SELECT users.name, orders.total 
FROM users 
JOIN orders ON users.id = orders.user_id;

-- Error: Ambiguous column references
SELECT id, name FROM users JOIN profiles ON users.id = profiles.user_id;

-- Error: Using HAVING without GROUP BY
SELECT COUNT(*) FROM users HAVING COUNT(*) > 10;

-- Error: ORDER BY with column number (deprecated)
SELECT id, name, email FROM users ORDER BY 2;

-- Error: Incorrect GROUP BY (missing columns)
SELECT department, name, COUNT(*) 
FROM employees 
GROUP BY department;  -- name is not in GROUP BY

-- Error: Using reserved words without quotes
SELECT select, from, where FROM table;  -- Reserved words as columns

-- Error: Missing semicolons
SELECT * FROM users
SELECT * FROM products  -- Missing semicolon

-- Error: Incorrect string quotes
SELECT * FROM users WHERE name = "John";  -- Should use single quotes

-- Error: Date format issues
SELECT * FROM events WHERE date = '2024-1-1';  -- Should be '2024-01-01'
SELECT * FROM events WHERE date = '01/15/2024';  -- Ambiguous format

-- Error: NULL comparison
SELECT * FROM users WHERE email = NULL;  -- Should use IS NULL
SELECT * FROM users WHERE status != NULL;  -- Should use IS NOT NULL

-- Error: Subquery issues
SELECT * FROM users WHERE id IN (SELECT user_id FROM orders WHERE total > 100;)  -- Semicolon in subquery

-- Error: UNION without ALL (performance)
SELECT id FROM users
UNION  -- Should consider UNION ALL if duplicates not an issue
SELECT id FROM customers;

-- Error: Unnecessary DISTINCT
SELECT DISTINCT id FROM users;  -- id is already unique

-- Error: Missing index hints comment
SELECT * FROM huge_table WHERE unindexed_column = 'value';  -- Might need index

-- Error: Cartesian product
SELECT * FROM table1, table2;  -- No join condition

-- Error: Division by zero potential
SELECT total / quantity FROM orders;  -- quantity might be zero

-- Error: CASE statement formatting
SELECT 
CASE WHEN status = 'active' THEN 'Active' WHEN status = 'inactive' THEN 'Inactive' END
FROM users;

-- Error: Inconsistent CASE statement
SELECT 
    CASE status
        WHEN 'active' THEN 1
        WHEN 'inactive' THEN '0'  -- Inconsistent data type
    END
FROM users;

-- Error: Missing ELSE in CASE
SELECT 
    CASE 
        WHEN age < 18 THEN 'Minor'
        WHEN age >= 18 THEN 'Adult'
        -- Missing ELSE clause
    END
FROM users;

-- Error: Bad JOIN conditions
SELECT * FROM users u
JOIN orders o ON 1=1;  -- Always true condition

-- Error: Self join without aliases
SELECT * FROM users JOIN users ON users.manager_id = users.id;

-- Error: Correlated subquery in SELECT (performance)
SELECT 
    u.name,
    (SELECT COUNT(*) FROM orders o WHERE o.user_id = u.id) as order_count
FROM users u;

-- Error: NOT IN with NULL potential
SELECT * FROM users WHERE id NOT IN (SELECT user_id FROM orders);  -- If user_id can be NULL

-- Error: Implicit type conversion
SELECT * FROM users WHERE age = '25';  -- String compared to number

-- Error: Missing WITH (NOLOCK) or transaction isolation
SELECT * FROM users;  -- In SQL Server, might need hints

-- Error: UPDATE without WHERE (dangerous)
UPDATE users SET status = 'inactive';  -- Updates all rows!

-- Error: DELETE without WHERE (dangerous)  
DELETE FROM temp_table;  -- Deletes all rows!

-- Error: INSERT with column count mismatch
INSERT INTO users (id, name) VALUES (1, 'John', 'john@example.com');

-- Error: Transaction not properly handled
BEGIN TRANSACTION;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
-- Missing COMMIT or ROLLBACK

-- Error: Cursor usage (usually discouraged)
DECLARE cursor_name CURSOR FOR SELECT * FROM users;

-- Error: Dynamic SQL without parameters
EXECUTE('SELECT * FROM users WHERE name = ''' + @userName + '''');  -- SQL injection risk

-- Error: Temporary table not cleaned up
CREATE TEMPORARY TABLE temp_data AS SELECT * FROM users;
-- Missing DROP TABLE temp_data;

-- Error: Index not used due to function
SELECT * FROM users WHERE UPPER(email) = 'JOHN@EXAMPLE.COM';

-- Error: Leading wildcard (performance)
SELECT * FROM users WHERE email LIKE '%@example.com';

-- Error: OR in JOIN condition (performance)
SELECT * FROM users u
JOIN orders o ON u.id = o.user_id OR u.email = o.customer_email;

-- Error: Multiple table UPDATE syntax varies
UPDATE users, orders 
SET users.updated = NOW(), orders.updated = NOW()
WHERE users.id = orders.user_id;

-- Error: LIMIT without ORDER BY
SELECT * FROM users LIMIT 10;  -- Non-deterministic results

-- Error: Nested subqueries too deep
SELECT * FROM (
    SELECT * FROM (
        SELECT * FROM (
            SELECT * FROM users
        ) t1
    ) t2
) t3;

-- Error: Comments in wrong places
SELECT id, -- User ID
       name, -- User name  
       email -- User email
FROM users;

-- Error: Float comparison
SELECT * FROM products WHERE price = 19.99;  -- Float equality issues

-- Error: Missing ON DELETE CASCADE consideration
-- Foreign keys without cascade rules documented

-- Error: TRUNCATE without understanding implications
TRUNCATE TABLE important_data;  -- Cannot be rolled back in some DBs

-- Error: Schema not specified
SELECT * FROM users;  -- Should be schema.users

-- Error: Hardcoded values that should be parameters
SELECT * FROM users WHERE created_at > '2024-01-01' AND status = 'active';

-- Error: COUNT(*) vs COUNT(column)
SELECT COUNT(nullable_column) FROM users;  -- Might not count NULLs as expected

-- Error: Mixing aggregate and non-aggregate without GROUP BY
SELECT name, COUNT(*) FROM users;  -- Invalid in most DBs

-- Error: BETWEEN with dates (inclusive)
SELECT * FROM events WHERE date BETWEEN '2024-01-01' AND '2024-01-31';  -- Includes both dates

-- Error: Time zone not considered
SELECT * FROM events WHERE created_at > '2024-01-01 00:00:00';  -- Which timezone?

-- Error: No table aliasing in complex query
SELECT users.id, users.name, orders.id, orders.total, products.name
FROM users
JOIN orders ON users.id = orders.user_id  
JOIN order_items ON orders.id = order_items.order_id
JOIN products ON order_items.product_id = products.id;

-- Error: VARCHAR without length
CREATE TABLE bad_table (
    name VARCHAR,  -- Missing length
    description TEXT
);

-- Error: No primary key defined
CREATE TABLE no_pk_table (
    id INTEGER,
    name VARCHAR(100)
);

-- Error: Spaces in column names
CREATE TABLE "bad table" (
    "user name" VARCHAR(100),
    "created at" TIMESTAMP
);

-- Error: No foreign key constraints
CREATE TABLE orders (
    id INTEGER PRIMARY KEY,
    user_id INTEGER  -- Should have FOREIGN KEY constraint
);

-- Error: Using FLOAT for money
CREATE TABLE products (
    id INTEGER PRIMARY KEY,
    price FLOAT  -- Should use DECIMAL for money
);

-- Error: No NOT NULL constraints where needed
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    email VARCHAR(255)  -- Should be NOT NULL
);

-- Error: Too many indexes
CREATE INDEX idx1 ON users(name);
CREATE INDEX idx2 ON users(email);
CREATE INDEX idx3 ON users(name, email);
CREATE INDEX idx4 ON users(email, name);  -- Redundant

-- Error: Missing ending semicolon
SELECT * FROM users

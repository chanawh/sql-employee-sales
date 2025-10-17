PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;
.

-- Insert departments (explicit IDs to make FK wiring straightforward)
INSERT INTO departments (department_id, department_name, manager_id, location, budget) VALUES
    (1, 'Sales', NULL, 'New York', 250000.00),
    (2, 'Engineering', NULL, 'San Francisco', 500000.00),
    (3, 'Human Resources', NULL, 'Austin', 90000.00),
    (4, 'Marketing', NULL, 'Chicago', 150000.00);

-- Insert manager-level employees first (manager_id = NULL)
INSERT INTO employees (employee_id, first_name, last_name, email, department_id, hire_date, salary, job_title, manager_id) VALUES
    (100, 'Alice', 'Morgan', 'alice.morgan@example.com', 1, '2018-03-12', 120000.00, 'VP Sales', NULL),
    (101, 'Brian', 'Chen', 'brian.chen@example.com', 2, '2016-07-01', 150000.00, 'CTO', NULL),
    (102, 'Carla', 'Diaz', 'carla.diaz@example.com', 4, '2019-10-21', 110000.00, 'VP Marketing', NULL),
    (103, 'David', 'Ng', 'david.ng@example.com', 3, '2017-01-03', 95000.00, 'HR Director', NULL);

-- Insert remaining employees (reference manager employee_ids above)
INSERT INTO employees (employee_id, first_name, last_name, email, department_id, hire_date, salary, job_title, manager_id) VALUES
    (200, 'Emily', 'Stone', 'emily.stone@example.com', 1, '2020-05-15', 80000.00, 'Account Executive', 100),
    (201, 'Frank', 'Li', 'frank.li@example.com', 1, '2021-02-11', 75000.00, 'Account Executive', 100),
    (202, 'Grace', 'Khan', 'grace.khan@example.com', 2, '2019-06-01', 120000.00, 'Senior Engineer', 101),
    (203, 'Hector', 'Ochoa', 'hector.ochoa@example.com', 2, '2022-09-10', 95000.00, 'Engineer', 101),
    (204, 'Ivy', 'Park', 'ivy.park@example.com', 4, '2021-11-01', 72000.00, 'Marketing Specialist', 102),
    (205, 'Jake', 'Wilson', 'jake.wilson@example.com', 4, '2023-01-08', 68000.00, 'Content Producer', 102),
    (206, 'Karen', 'Yusuf', 'karen.yusuf@example.com', 3, '2020-08-20', 65000.00, 'Recruiter', 103);

-- Insert some sales (representative transactions across employees, dates, regions)
INSERT INTO sales (sale_id, employee_id, sale_date, sale_amount, product, region) VALUES
    (1000, 200, '2024-01-10', 12500.00, 'Enterprise Suite', 'North America'),
    (1001, 200, '2024-02-14', 7500.00, 'Analytics Add-on', 'North America'),
    (1002, 201, '2024-01-22', 9800.00, 'Enterprise Suite', 'EMEA'),
    (1003, 201, '2024-03-03', 4500.00, 'Support Package', 'EMEA'),
    (1004, 200, '2024-04-30', 15000.00, 'Enterprise Suite', 'APAC'),
    (1005, 202, '2024-05-05', 0.00, 'Internal', 'NA'),
    (1006, 203, '2024-06-12', 300.00, 'Accessory', 'North America'),
    (1007, 204, '2024-06-15', 4200.00, 'Campaign Services', 'North America'),
    (1008, 200, '2024-07-01', 22000.00, 'Enterprise Suite', 'North America'),
    (1009, 201, '2024-07-02', 17000.00, 'Enterprise Suite', 'EMEA'),
    (1010, 205, '2024-08-11', 800.00, 'Creative Package', 'North America'),
    (1011, 206, '2024-08-20', 0.00, 'Referral Bonus', 'N/A');

-- Example UPSERT: suppose budget needs to be updated or inserted
-- SQLite syntax: ON CONFLICT(column) DO UPDATE SET ...
INSERT INTO departments (department_id, department_name, manager_id, location, budget)
VALUES (1, 'Sales', NULL, 'New York', 300000.00)
ON CONFLICT(department_id) DO UPDATE SET
    -- here we're intentionally increasing the budget if the department exists
    budget = departments.budget + excluded.budget;

-- Create indexes to speed up common analytics
CREATE INDEX IF NOT EXISTS idx_sales_employee ON sales(employee_id);
CREATE INDEX IF NOT EXISTS idx_sales_date ON sales(sale_date);
CREATE INDEX IF NOT EXISTS idx_employees_dept ON employees(department_id);

COMMIT;

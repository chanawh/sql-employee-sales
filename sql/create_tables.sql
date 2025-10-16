-- Create table: departments
CREATE TABLE departments (
    department_id INTEGER PRIMARY KEY,
    department_name TEXT NOT NULL,
    manager_id INTEGER,
    location TEXT,
    budget REAL
);

-- Create table: employees
CREATE TABLE employees (
    employee_id INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    department_id INTEGER,
    hire_date DATE,
    salary REAL,
    job_title TEXT,
    manager_id INTEGER,
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

-- Create table: sales
CREATE TABLE sales (
    sale_id INTEGER PRIMARY KEY,
    employee_id INTEGER,
    sale_date DATE,
    sale_amount REAL,
    product TEXT,
    region TEXT,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);
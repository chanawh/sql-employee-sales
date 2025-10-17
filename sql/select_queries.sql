-- 1. List all employees with department info
SELECT e.employee_id, e.first_name, e.last_name, e.email, e.job_title, d.department_name
FROM employees e
LEFT JOIN departments d ON d.department_id = e.department_id
ORDER BY e.employee_id;

-- 2. List departments with employee count
SELECT d.department_id, d.department_name, COUNT(e.employee_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON e.department_id = d.department_id
GROUP BY d.department_id
ORDER BY d.department_id;

-- 3. Total sales per employee
SELECT e.employee_id, e.first_name || ' ' || e.last_name AS name, COALESCE(SUM(s.sale_amount), 0) AS total_sales
FROM employees e
LEFT JOIN sales s ON e.employee_id = s.employee_id
GROUP BY e.employee_id
ORDER BY total_sales DESC;

-- 4. Total sales per department
SELECT d.department_id, d.department_name, COALESCE(SUM(s.sale_amount), 0) AS dept_sales
FROM departments d
LEFT JOIN employees e ON e.department_id = d.department_id
LEFT JOIN sales s ON s.employee_id = e.employee_id
GROUP BY d.department_id
ORDER BY dept_sales DESC;

-- 5. Top 3 employees by sales (window function)
SELECT employee_id, name, total_sales FROM (
  SELECT e.employee_id,
         e.first_name || ' ' || e.last_name AS name,
         COALESCE(SUM(s.sale_amount), 0) AS total_sales,
         RANK() OVER (ORDER BY COALESCE(SUM(s.sale_amount), 0) DESC) rk
  FROM employees e
  LEFT JOIN sales s ON s.employee_id = e.employee_id
  GROUP BY e.employee_id
) WHERE rk <= 3;

-- 6. Monthly sales trend for 2024
SELECT strftime('%Y-%m', sale_date) AS year_month, SUM(sale_amount) AS month_total
FROM sales
WHERE sale_date BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY year_month
ORDER BY year_month;

-- 7. Sales by region
SELECT region, SUM(sale_amount) AS total_sales, COUNT(*) AS sale_count
FROM sales
GROUP BY region
ORDER BY total_sales DESC;

-- 8. Employees with no sales
SELECT e.employee_id, e.first_name, e.last_name
FROM employees e
LEFT JOIN sales s ON e.employee_id = s.employee_id
WHERE s.sale_id IS NULL;

-- 9. Average salary by department
SELECT d.department_name, AVG(e.salary) AS avg_salary
FROM departments d
LEFT JOIN employees e ON e.department_id = d.department_id
GROUP BY d.department_id
ORDER BY avg_salary DESC;

SELECT s.sale_id, s.sale_date, s.sale_amount, s.product, e.first_name || ' ' || e.last_name AS salesperson
FROM sales s
LEFT JOIN employees e ON e.employee_id = s.employee_id
ORDER BY s.sale_date DESC
LIMIT 5;

-- 11. Employees with Above-Average Salary (Subquery)
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- 12. Departments with More Than 2 Employees (GROUP BY + HAVING)
SELECT d.department_id, d.department_name, COUNT(e.employee_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON e.department_id = d.department_id
GROUP BY d.department_id
HAVING employee_count > 2;

-- 13. Sales with Category (CASE Statement)
SELECT sale_id, sale_amount,
  CASE
    WHEN sale_amount >= 15000 THEN 'Large'
    WHEN sale_amount >= 5000 THEN 'Medium'
    ELSE 'Small'
  END AS sale_category
FROM sales
ORDER BY sale_amount DESC;

-- 14. Employees Who Are Managers (Correlated Subquery)
SELECT e.employee_id, e.first_name, e.last_name
FROM employees e
WHERE EXISTS (
  SELECT 1 FROM employees m WHERE m.manager_id = e.employee_id
);

-- 15. Sales in the Last 30 Days (Date Functions)
SELECT sale_id, sale_date, sale_amount
FROM sales
WHERE sale_date >= date('now', '-30 days');

-- 16. Department with Highest Total Sales (ORDER BY + LIMIT)
SELECT d.department_id, d.department_name, COALESCE(SUM(s.sale_amount), 0) AS dept_sales
FROM departments d
LEFT JOIN employees e ON e.department_id = d.department_id
LEFT JOIN sales s ON s.employee_id = e.employee_id
GROUP BY d.department_id
ORDER BY dept_sales DESC
LIMIT 1;

-- 17. Employee Email Domains (String Functions)
SELECT email, SUBSTR(email, INSTR(email, '@') + 1) AS domain
FROM employees;

-- 18. CTE: Top Salesperson Per Region
WITH region_sales AS (
  SELECT region, employee_id, SUM(sale_amount) AS total_sales
  FROM sales
  GROUP BY region, employee_id
)
SELECT region, employee_id, total_sales
FROM (
  SELECT region, employee_id, total_sales,
         RANK() OVER (PARTITION BY region ORDER BY total_sales DESC) AS rk
  FROM region_sales
)
WHERE rk = 1;

-- 19. Employees Without a Department (NULL Handling)
SELECT employee_id, first_name, last_name
FROM employees
WHERE department_id IS NULL;

-- 20. Sales Count and Average by Product
SELECT product, COUNT(*) AS sale_count, AVG(sale_amount) AS avg_sale
FROM sales
GROUP BY product
ORDER BY sale_count DESC;
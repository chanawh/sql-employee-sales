-- 1. INNER JOIN: Employees and their departments (only matching rows)
SELECT e.employee_id, e.first_name, e.last_name, d.department_name
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id;

-- 2. LEFT JOIN: All employees, with department if available
SELECT e.employee_id, e.first_name, e.last_name, d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id;

-- 3. RIGHT JOIN: All departments, with employees if available (SQLite supports RIGHT JOIN)
SELECT d.department_id, d.department_name, e.first_name, e.last_name
FROM employees e
RIGHT JOIN departments d ON e.department_id = d.department_id;

-- 4. FULL OUTER JOIN: All employees and departments (using UNION for SQLite)
SELECT e.employee_id, e.first_name, e.last_name, d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
UNION
SELECT NULL, NULL, NULL, d.department_name
FROM departments d
WHERE d.department_id NOT IN (SELECT DISTINCT department_id FROM employees WHERE department_id IS NOT NULL);

-- 5. CROSS JOIN: Cartesian product of departments and employees (use with caution)
SELECT d.department_name, e.first_name, e.last_name
FROM departments d
CROSS JOIN employees e
LIMIT 10;  -- Limit to avoid large output

-- 6. Scalar Subquery: Employees with salary above department average
SELECT e.employee_id, e.first_name, e.last_name, e.salary
FROM employees e
WHERE e.salary > (
  SELECT AVG(salary)
  FROM employees
  WHERE department_id = e.department_id
);

-- 7. Correlated Subquery: Employees who have made sales
SELECT e.employee_id, e.first_name, e.last_name
FROM employees e
WHERE EXISTS (
  SELECT 1 FROM sales s WHERE s.employee_id = e.employee_id
);

-- 8. Subquery in FROM: Average sales per department
SELECT dept_name, avg_sale
FROM (
  SELECT d.department_name AS dept_name, AVG(s.sale_amount) AS avg_sale
  FROM departments d
  LEFT JOIN employees e ON e.department_id = d.department_id
  LEFT JOIN sales s ON s.employee_id = e.employee_id
  GROUP BY d.department_id
) AS dept_avg
WHERE avg_sale IS NOT NULL;

-- 9. Nested Subquery: Top department by employee count
SELECT department_name
FROM departments
WHERE department_id = (
  SELECT department_id
  FROM (
    SELECT department_id, COUNT(employee_id) AS emp_count
    FROM employees
    GROUP BY department_id
    ORDER BY emp_count DESC
    LIMIT 1
  )
);

-- 10. JOIN with Subquery: Sales by employees in Sales department
SELECT s.sale_id, s.sale_amount, e.first_name, e.last_name
FROM sales s
INNER JOIN employees e ON s.employee_id = e.employee_id
WHERE e.department_id = (
  SELECT department_id FROM departments WHERE department_name = 'Sales'
);

-- 11. LEFT JOIN with Subquery: Employees and their manager names
SELECT e.employee_id, e.first_name, e.last_name, m.first_name || ' ' || m.last_name AS manager_name
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id;

-- 12. Subquery with IN: Employees in departments with budget > 200000
SELECT employee_id, first_name, last_name
FROM employees
WHERE department_id IN (
  SELECT department_id FROM departments WHERE budget > 200000
);

-- 13. Correlated Subquery with Aggregation: Employees with sales above average for their department
SELECT e.employee_id, e.first_name, e.last_name, SUM(s.sale_amount) AS total_sales
FROM employees e
LEFT JOIN sales s ON e.employee_id = s.employee_id
GROUP BY e.employee_id
HAVING total_sales > (
  SELECT AVG(total_sales)
  FROM (
    SELECT SUM(s2.sale_amount) AS total_sales
    FROM employees e2
    LEFT JOIN sales s2 ON e2.employee_id = s2.employee_id
    WHERE e2.department_id = e.department_id
    GROUP BY e2.employee_id
  )
);

-- 14. FULL JOIN Alternative: All employees and sales (using LEFT and RIGHT)
SELECT e.employee_id, e.first_name, s.sale_id, s.sale_amount
FROM employees e
LEFT JOIN sales s ON e.employee_id = s.employee_id
UNION ALL
SELECT NULL, NULL, s.sale_id, s.sale_amount
FROM sales s
WHERE s.employee_id NOT IN (SELECT employee_id FROM employees);

-- 15. Subquery in SELECT: Employee count per department
SELECT d.department_name,
       (SELECT COUNT(*) FROM employees e WHERE e.department_id = d.department_id) AS emp_count
FROM departments d;

-- 16. JOIN with Multiple Tables: Sales with employee and department info
SELECT s.sale_id, s.sale_amount, e.first_name, e.last_name, d.department_name
FROM sales s
INNER JOIN employees e ON s.employee_id = e.employee_id
INNER JOIN departments d ON e.department_id = d.department_id;

-- 17. Correlated Subquery: Departments with at least one employee
SELECT d.department_id, d.department_name
FROM departments d
WHERE EXISTS (
  SELECT 1 FROM employees e WHERE e.department_id = d.department_id
);

-- 18. Subquery with NOT IN: Departments with no employees
SELECT department_id, department_name
FROM departments
WHERE department_id NOT IN (
  SELECT DISTINCT department_id FROM employees WHERE department_id IS NOT NULL
);

-- 19. JOIN with Aggregation: Total sales by department and employee
SELECT d.department_name, e.first_name, e.last_name, SUM(s.sale_amount) AS total_sales
FROM departments d
INNER JOIN employees e ON e.department_id = d.department_id
LEFT JOIN sales s ON s.employee_id = e.employee_id
GROUP BY d.department_id, e.employee_id
ORDER BY d.department_name, total_sales DESC;

-- 20. Complex Subquery: Employees with sales in multiple regions
SELECT e.employee_id, e.first_name, e.last_name
FROM employees e
WHERE (
  SELECT COUNT(DISTINCT s.region)
  FROM sales s
  WHERE s.employee_id = e.employee_id
) > 1;
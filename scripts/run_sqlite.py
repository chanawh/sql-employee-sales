import os
import sqlite3
import csv

# Optional: Remove old database for a fresh start
if os.path.exists("../practice.db"):
    os.remove("../practice.db")

conn = sqlite3.connect("../practice.db")
cur = conn.cursor()

with open("../sql/create_tables.sql") as f:
    cur.executescript(f.read())
print("Tables created.")

def import_csv_to_table(csv_path, table_name, columns):
    with open(csv_path, newline='', encoding='utf-8') as csvfile:
        reader = csv.DictReader(csvfile)
        rows = [tuple(row[col] for col in columns) for row in reader]
        placeholders = ','.join('?' * len(columns))
        cur.executemany(
            f"INSERT INTO {table_name} ({','.join(columns)}) VALUES ({placeholders})", rows
        )

import_csv_to_table("../data/employees.csv", "employees",
    ["employee_id", "first_name", "last_name", "email", "department_id", "hire_date", "salary", "job_title", "manager_id"]
)
print("Employees imported.")

import_csv_to_table("../data/departments.csv", "departments",
    ["department_id", "department_name", "manager_id", "location", "budget"]
)
print("Departments imported.")

import_csv_to_table("../data/sales.csv", "sales",
    ["sale_id", "employee_id", "sale_date", "sale_amount", "product", "region"]
)
print("Sales imported.")

conn.commit()

# Print all rows from each table
def print_table(cur, table_name):
    print(f"\nTable: {table_name}")
    for row in cur.execute(f"SELECT * FROM {table_name};"):
        print(row)

print_table(cur, "employees")
print_table(cur, "departments")
print_table(cur, "sales")

conn.close()
print("All done.")
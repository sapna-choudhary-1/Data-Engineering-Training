
------------------------------------------------------------------------------
---- Creating required Tables ----
------------------------------------------------------------------------------

CREATE DATABASE [company];
USE [company];

DROP TABLE [empls];
DROP TABLE [depts];
DROP TABLE [gender];

----
CREATE TABLE [gender]
(
id INT CONSTRAINT PK_gender_id PRIMARY KEY,
gender NVARCHAR(10) NOT NULL
);

INSERT INTO gender (id, gender) VALUES (0, 'Unknown');

------------
CREATE TABLE [depts]
(
id INT CONSTRAINT PK_depts_id PRIMARY KEY,
dept_name NVARCHAR(50) NOT NULL
	CONSTRAINT UQ_depts_name UNIQUE (dept_name),
location NVARCHAR(50) NOT NULL,
dept_head NVARCHAR(50) NOT NULL,
	CONSTRAINT UQ_depts_dept_head UNIQUE (dept_head)
);

----
CREATE TABLE [empls]
(
id INT IDENTITY(1,1) CONSTRAINT PK_empls_id PRIMARY KEY,
name NVARCHAR(50) NOT NULL,
--Gender_id INT NOT NULL CONSTRAINT DF_empls_gender DEFAULT 0, --- Not allowed to have 'constraint' added inline, AT TABLE LEVEL
--Gender_id INT NOT NULL DEFAULT 0, --- Only Allowed to have unnamed constraint inline
gender_id INT NOT NULL,
salary INT NOT NULL,
dept_id INT NULL,
join_date DATE NOT NULL,
CONSTRAINT FK_empls_gender_id FOREIGN KEY (gender_id)
	REFERENCES [gender] (id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
CONSTRAINT FK_empls_dept_id FOREIGN KEY (dept_id)
	REFERENCES [depts] (id)
	ON DELETE SET NULL
	ON UPDATE CASCADE,
CONSTRAINT CK_empls_salary CHECK (Salary >= 0),
CONSTRAINT CK_empls_join_date CHECK (join_date <= GETDATE()),
);

ALTER TABLE [empls]
ADD CONSTRAINT DF_empls_gender DEFAULT 0 FOR gender_id;
ALTER TABLE [empls]
ADD CONSTRAINT DF_empls_salary DEFAULT 30000 FOR salary;
ALTER TABLE [empls]
ADD CONSTRAINT DF_empls_join_date DEFAULT GETDATE() FOR join_date;

------------
INSERT INTO [gender] VALUES
(1, 'Male'), (2, 'Female');

----
INSERT INTO [depts] VALUES
(1, 'IT', 'London', 'Rick'),
(2, 'Payroll', 'Delhi', 'Ron'),
(3, 'HR', 'New York', 'Christie'),
(4, 'Other Department', 'Sydney', 'Cindrella');

----

INSERT INTO [empls] (name, gender_id, salary, dept_id) VALUES
('Charls', 1, 2000, 5);  -- ❌ Will fail with 'conflicted with the FOREIGN KEY constraint "FK_empls_dept_id" '

DELETE FROM [empls];

INSERT INTO [empls] (name, gender_id, salary, dept_id, join_date) VALUES
('Tom', 1, 4000, 1, '2025-02-01'),
('Pam', 2, 3000, 3, '2023-05-10'),
('John', 1, 8800, 1, '2021-11-11'),
('Sam', 1, 4500, 2, DEFAULT),
('Todd', 1, 2800, 2, DEFAULT),
('Ben', 1, 7000, 1, '2022-05-30'),
('Sara', 2, 4800, 3, DEFAULT),
('Valarie', 2, 5500, 1, '2022-05-30'),
('James', 1, 6500, NULL, DEFAULT),
('Russell', 1, 3500, NULL, DEFAULT);


------------------------------------------------------------------------------
---- JOINS - on 3 tables ----
------------------------------------------------------------------------------

SELECT e.Name, e.gender_id, g.gender, salary, e.dept_id, d.dept_name
FROM [empls] e
JOIN [gender] AS g ON e.gender_id = g.id
JOIN [depts] AS d ON e.dept_id = d.id;

SELECT e.Name, e.gender_id, g.gender, salary, e.dept_id, d.dept_name
FROM [empls] e
JOIN [depts] AS d ON e.dept_id = d.id
JOIN [gender] AS g ON e.gender_id = g.id;

SELECT e.Name, e.gender_id, g.gender, salary, e.dept_id, d.dept_name
FROM [empls] e
JOIN [gender] AS g ON e.gender_id = g.id
LEFT JOIN [depts] AS d ON e.dept_id = d.id;

SELECT e.Name, e.gender_id, g.gender, salary, e.dept_id, d.dept_name
FROM [empls] e
LEFT JOIN [gender] AS g ON e.gender_id = g.id
JOIN [depts] AS d ON e.dept_id = d.id;

SELECT e.Name, e.gender_id, g.gender, salary, e.dept_id, d.dept_name
FROM [empls] e
LEFT JOIN [gender] AS g ON e.gender_id = g.id
LEFT JOIN [depts] AS d ON e.dept_id = d.id;

SELECT e.Name, e.gender_id, g.gender, salary, e.dept_id, d.dept_name
FROM [empls] e
JOIN [gender] AS g ON e.gender_id = g.id
RIGHT JOIN [depts] AS d ON e.dept_id = d.id;

SELECT e.Name, e.gender_id, g.gender, salary, e.dept_id
FROM [empls] e
RIGHT JOIN [gender] AS g ON e.gender_id = g.id;

SELECT e.Name, e.gender_id, g.gender, salary, e.dept_id, d.dept_name
FROM [empls] e
RIGHT JOIN [gender] AS g ON e.gender_id = g.id
JOIN [depts] AS d ON e.dept_id = d.id;

SELECT e.Name, e.gender_id, g.gender, salary, e.dept_id, d.dept_name
FROM [empls] e
RIGHT JOIN [gender] AS g ON e.gender_id = g.id
RIGHT JOIN [depts] AS d ON e.dept_id = d.id;

SELECT e.Name, e.gender_id, g.gender, salary, e.dept_id, d.dept_name
FROM [empls] e
RIGHT JOIN [gender] AS g ON e.gender_id = g.id
LEFT JOIN [depts] AS d ON e.dept_id = d.id;


------------------------------------------------------------------------------
---- PRACTISE QUERIES ----
------------------------------------------------------------------------------

------- List all employees with their gender and department location -------
SELECT e.Name, g.gender, d.location
FROM [empls] e
LEFT JOIN [gender] AS g ON e.gender_id = g.id
LEFT JOIN [depts] AS d ON e.dept_id = d.id;

------- List all departments and their employees (even if no employee is present) -------
SELECT e.Name, d.dept_name
FROM [empls] e
RIGHT JOIN [depts] AS d ON e.dept_id = d.id;

------- List employees who don’t belong to any department -------
SELECT e.Name, g.gender, d.dept_name
FROM [empls] e
LEFT JOIN [gender] AS g ON e.gender_id = g.id
LEFT JOIN [depts] AS d ON e.dept_id = d.id
WHERE d.id is NULL;

------- List departments with no employees -------
SELECT e.Name, d.dept_name, d.location
FROM [empls] e
RIGHT JOIN [depts] AS d ON e.dept_id = d.id
WHERE e.dept_id is NULL;

SELECT e.Name, d.dept_name, d.location
FROM depts d
LEFT JOIN empls e ON d.id = e.dept_id
WHERE e.id IS NULL;

------- Count employees per department -------
SELECT COUNT(e.Name), d.id, COUNT(d.id), d.dept_name
FROM [empls] e
LEFT JOIN [depts] AS d ON e.dept_id = d.id
GROUP BY d.dept_name, d.id
ORDER BY d.id;

------- Count employees per department except employees with no dept -------
SELECT COUNT(e.Name), d.id, COUNT(d.id), d.dept_name
FROM [empls] e
LEFT JOIN [depts] AS d ON e.dept_id = d.id
WHERE d.dept_name IS NOT NULL
GROUP BY d.dept_name, d.id
ORDER BY d.id;

------- Get average salary per department, only if average salary > 3700 -------
SELECT AVG(e.salary), d.dept_name
FROM [empls] e
JOIN [depts] AS d ON e.dept_id = d.id
GROUP BY d.dept_name
HAVING AVG(e.salary) > 3700;

------- Get the highest paid employee in each department -------
SELECT MAX(e.name), d.dept_name
FROM [empls] e
LEFT JOIN [depts] AS d ON e.dept_id = d.id
GROUP BY d.dept_name
ORDER BY MAX(e.salary) DESC;

------- Get the highest paid employee in each department, along with it's salary -------
SELECT MAX(e.name), MAX(e.salary), d.dept_name
FROM [empls] e
LEFT JOIN [depts] AS d ON e.dept_id = d.id
GROUP BY d.dept_name
ORDER BY MAX(e.salary) DESC;

---????---
SELECT e.name, e.salary, d.dept_name
FROM [empls] e
LEFT JOIN [depts] AS d ON e.dept_id = d.id
WHERE e.salary = (
	SELECT MAX(e2.salary)
	FROM [empls] e2
	WHERE e2.dept_id = e.dept_id
);

------- Get list of employees who joined in or after 2024 and work in 'HR' or 'IT' -------
SELECT e.Name, e.join_date, d.dept_name
FROM [empls] e
LEFT JOIN [depts] AS d ON e.dept_id = d.id
WHERE e.join_date >= '2024-01-01'
	AND d.dept_name IN ('HR', 'IT');

------- List employees and their gender, sorted by salary descending -------
SELECT e.Name, g.gender, e.salary
FROM [empls] e
LEFT JOIN [gender] AS g ON e.gender_id = g.id
ORDER BY e.salary DESC;

------- Get count of employees by gender (even if no employees exist of a gender) -------
SELECT COUNT(e.Name) AS gender_count, g.gender
FROM [empls] e
RIGHT JOIN [gender] AS g ON e.gender_id = g.id
GROUP BY g.gender;

------- Compare employees in same department who have the same salary -------
---?????----
select * from empls;

INSERT INTO [empls] VALUES
('Bruno', 1, 4800, 3, DEFAULT),
('Laura', 2, 6500, NULL, DEFAULT);

INSERT INTO [empls] VALUES
('Maria', 2, 4800, 3, '2023-04-03');

SELECT e1.Name, e2.name, e1.salary, d.dept_name
FROM [empls] e1
JOIN [empls] e2 ON e1.dept_id = e2.dept_id AND e1.id < e2.id AND e1.salary = e2.salary
JOIN [depts] d ON e1.dept_id = d.id;

------- List all departments and their total salary payout, sorted by highest payout -------

SELECT d.dept_name, SUM(e.salary) AS total_salary
FROM [empls] e
JOIN [depts] AS d ON e.dept_id = d.id
GROUP BY d.dept_name
ORDER BY total_salary DESC;

--- List all departments and their total salary payout, sorted by highest payout::- consider all empls, even if they have no dept ---
SELECT d.dept_name, SUM(e.salary) AS total_salary
FROM [empls] e
LEFT JOIN [depts] AS d ON e.dept_id = d.id
GROUP BY d.dept_name
ORDER BY total_salary DESC;

--- List all departments and their total salary payout, sorted by highest payout::- consider all depts, even if they have no empls ---
SELECT d.dept_name, SUM(e.salary) AS total_salary
FROM [empls] e
RIGHT JOIN [depts] AS d ON e.dept_id = d.id
GROUP BY d.dept_name
ORDER BY total_salary DESC;

------- List all employees who earn more than average salary of their department -------
SELECT e.Name, e.salary, d.dept_name
FROM [empls] e
LEFT JOIN [depts] AS d ON e.dept_id = d.id
WHERE e.salary > (
	SELECT AVG(e2.salary)
	FROM [empls] e2
	WHERE e2.dept_id = e.dept_id
);

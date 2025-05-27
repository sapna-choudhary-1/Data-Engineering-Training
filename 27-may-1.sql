
------------------------------------------------------------------------------
---- Creating required Tables ----
------------------------------------------------------------------------------

DROP TABLE [empls];
DROP TABLE [depts];
DROP TABLE [gender];

CREATE DATABASE [company];
USE [company];

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
---- JOINS - only Matching rows + non-matching rows ----
------------------------------------------------------------------------------

SELECT e.Name, e.gender_id, salary, d.dept_name
FROM [empls] e
INNER JOIN [depts] AS d
ON e.dept_id = d.id;

SELECT e.Name, e.gender_id, salary, d.dept_name
FROM [empls] e
LEFT OUTER JOIN [depts] AS d
ON e.dept_id = d.id;

SELECT e.Name, e.gender_id, salary, d.dept_name
FROM [empls] e
RIGHT OUTER JOIN [depts] AS d
ON e.dept_id = d.id;

SELECT e.Name, e.gender_id, salary, d.dept_name
FROM [empls] e
FULL OUTER JOIN [depts] AS d
ON e.dept_id = d.id;

SELECT e.Name, e.gender_id, salary, d.dept_name
FROM [empls] e
CROSS JOIN [depts] AS d;


------------------------------------------------------------------------------
---- JOINS - only non-matching rows ----
------------------------------------------------------------------------------

SELECT e.Name, e.gender_id, salary, d.dept_name
FROM [empls] e
LEFT JOIN [depts] AS d
ON e.dept_id = d.id
WHERE d.id IS NULL;

SELECT e.Name, e.gender_id, salary, d.dept_name
FROM [empls] e
RIGHT JOIN [depts] AS d
ON e.dept_id = d.id
WHERE e.dept_id IS NULL;

SELECT e.Name, e.gender_id, salary, d.dept_name
FROM [empls] e
FULL JOIN [depts] AS d
ON e.dept_id = d.id
WHERE d.id IS NULL
OR e.dept_id IS NULL;


------------------------------------------------------------------------------
---- SELF JOIN ----
------------------------------------------------------------------------------

------- each employee (e) has a manager_id that refers to another employee (m)'s emp_id -------
CREATE TABLE [em]
(
emp_id INT IDENTITY(1,1) CONSTRAINT PK_em_emp_id PRIMARY KEY,
name NVARCHAR(50) NOT NULL,
manager_id INT
);

INSERT INTO [em] VALUES
('Mike', 3),
('Rob', 1),
('Todd', NULL),
('Ben', 1),
('Sam', 1);

----
------- For each employee, find the person whose ID matches their manager_id -------
SELECT e.name AS Employee, m.name AS Manager
FROM [em] AS e
LEFT JOIN [em] AS m
ON e.manager_id = m.emp_id;

SELECT e.name AS Employee, m.name AS Manager
FROM [em] AS e
RIGHT JOIN [em] AS m
ON e.manager_id = m.emp_id;

SELECT e.name AS Employee, m.name AS Manager
FROM [em] AS e
FULL JOIN [em] AS m
ON e.manager_id = m.emp_id;

SELECT e.name AS Employee, m.name AS Manager
FROM [em] AS e
INNER JOIN [em] AS m
ON e.manager_id = m.emp_id;

SELECT e.name AS Employee, m.name AS Manager
FROM [em] AS e
CROSS JOIN [em] AS m;

------- Find all employees who are managers of someone—i.e., where another row's manager_id points to this employee's ID -------
---- similar to right join of above
SELECT e.name AS Manager, m.name AS Employee
FROM [em] AS e
LEFT JOIN [em] AS m
ON e.emp_id = m.manager_id;

SELECT e.name AS Manager, m.name AS Employee
FROM [em] AS e
RIGHT JOIN [em] AS m
ON e.emp_id = m.manager_id;

SELECT e.name AS Manager, m.name AS Employee
FROM [em] AS e
FULL JOIN [em] AS m
ON e.emp_id = m.manager_id;

SELECT e.name AS Manager, m.name AS Employee
FROM [em] AS e
INNER JOIN [em] AS m
ON e.emp_id = m.manager_id;

SELECT e.name AS Manager, m.name AS Employee
FROM [em] AS e
CROSS JOIN [em] AS m;


------------------------------------------------------------------------------
---- Replacing NULL values ----
------------------------------------------------------------------------------

SELECT e.name AS Employee, ISNULL(m.name, 'No Manager') AS Manager
FROM [em] AS e
LEFT JOIN [em] AS m
ON e.manager_id = m.emp_id;

SELECT e.name AS Employee, COALESCE(m.name, 'No Manager') AS Manager
FROM [em] AS e
LEFT JOIN [em] AS m
ON e.manager_id = m.emp_id;

SELECT e.name AS Employee, CASE WHEN m.name IS NULL THEN 'No Manager' ELSE m.name END AS Manager
FROM [em] AS e
LEFT JOIN [em] AS m
ON e.manager_id = m.emp_id;


------------------------------------------------------------------------------
---- QUESTIONNAIRE ----
------------------------------------------------------------------------------

USE company;
CREATE TABLE tbl_a
(
ID INT,
name NVARCHAR(50)
);

CREATE TABLE tbl_b
(
ID INT,
name NVARCHAR(50)
);

INSERT INTO [tbl_a]
VALUES (1, 'a'), (1, 'b'), (1, 'c'), (2, 'a'), (2, 'b'), (3, 'd'), (NULL, 'e');


INSERT INTO [tbl_b]
VALUES (1, 'a'), (1, 'b'), (2, 'a'), (2, 'b'), (2, 'c'), (3, 'a'), (3, 'd'), (NULL, 'e'), (NULL, 'f'), (4, 'z');

SELECT * FROM [tbl_a];
SELECT * FROM [tbl_b];

SELECT a.ID, a.name, b.name
FROM [tbl_a] a
INNER JOIN [tbl_b] b
ON a.ID = b.ID
ORDER BY a.ID, a.name;

SELECT a.ID, a.name, b.name
FROM [tbl_a] a
LEFT JOIN [tbl_b] b
ON a.ID = b.ID
ORDER BY a.ID, a.name;

SELECT a.ID, a.name, b.name
FROM [tbl_a] a
RIGHT JOIN [tbl_b] b
ON a.ID = b.ID
ORDER BY a.ID, a.name;

----
SELECT a.ID, a.name, b.name
FROM [tbl_a] a
INNER JOIN [tbl_b] b
ON a.ID = b.ID
WHERE a.ID IS NOT NULL
ORDER BY a.ID, a.name;

SELECT a.ID, a.name, b.name
FROM [tbl_a] a
LEFT JOIN [tbl_b] b
ON a.ID = b.ID
WHERE a.ID IS NOT NULL
ORDER BY a.ID, a.name;

SELECT a.ID, a.name, b.name
FROM [tbl_a] a
RIGHT JOIN [tbl_b] b
ON a.ID = b.ID
WHERE a.ID IS NOT NULL
ORDER BY a.ID, a.name;

----

SELECT a.ID, a.name, b.name
FROM [tbl_a] a
INNER JOIN [tbl_b] b
ON a.ID = b.ID
AND a.name <> 'a'
ORDER BY a.ID, a.name;

SELECT a.ID, a.name, b.name
FROM [tbl_a] a
LEFT JOIN [tbl_b] b
ON a.ID = b.ID
AND a.name <> 'a'
ORDER BY a.ID, a.name;

SELECT a.ID, a.name, b.name
FROM [tbl_a] a
RIGHT JOIN [tbl_b] b
ON a.ID = b.ID
AND a.name <> 'a'
ORDER BY a.ID, a.name;

----

SELECT a.ID, a.name, b.name
FROM [tbl_a] a
INNER JOIN [tbl_b] b
ON a.ID = b.ID
AND a.name <> 'a'
WHERE a.ID IS NOT NULL
ORDER BY a.ID, a.name;

SELECT a.ID, a.name, b.name
FROM [tbl_a] a
LEFT JOIN [tbl_b] b
ON a.ID = b.ID
AND a.name <> 'a'
WHERE a.ID IS NOT NULL
ORDER BY a.ID, a.name;

SELECT a.ID, a.name, b.name
FROM [tbl_a] a
RIGHT JOIN [tbl_b] b
ON a.ID = b.ID
AND a.name <> 'a'
WHERE a.ID IS NOT NULL
ORDER BY a.ID, a.name;


------------------------------------------------------------------------------
---- COALESCE() function ----
------------------------------------------------------------------------------

USE [company];

CREATE TABLE [name]
(
id INT IDENTITY(1,1),
f_name NVARCHAR(50),
m_name NVARCHAR(50),
l_name NVARCHAR(50),
);

INSERT INTO [name] VALUES
('Sam', NULL, NULL),
(NULL, 'Todd', 'Tanzan'),
(NULL, NULL, 'Sara'),
('Ben', 'Parker', NULL),
(NULL, NULL, NULL),
('James', 'Nick', 'Nancy');

SELECT id, f_name
FROM [name];

SELECT id, COALESCE(f_name, m_name, l_name) AS name
FROM [name];

SELECT id, COALESCE(f_name, m_name, l_name, 'No name') AS name
FROM [name];

------------------------------------------------------------------------------
---- UNION ----
------------------------------------------------------------------------------

USE [company];

CREATE TABLE [tblIndiaCustomers]
(
--id INT IDENTITY(1,1), -- ❌ Will fail with 'An explicit value for the identity column in table 'tblIndiaCustomers' can only be specified when a column list is used and IDENTITY_INSERT is ON'
id INT,
name NVARCHAR(50),
email NVARCHAR(50)
);

CREATE TABLE [tblUKCustomers]
(
id INT,
name NVARCHAR(50),
email NVARCHAR(50)
);

CREATE TABLE [tblSpainCustomers]
(
id INT,
name NVARCHAR(50),
email NVARCHAR(50)
);

INSERT INTO [tblIndiaCustomers] VALUES
(1, 'Raj', 'r@r.com'),
(2, 'Sam', 's@s.com');

INSERT INTO [tblUKCustomers] VALUES
(1, 'Ben', 'b@b.com'),
(2, 'Sam', 's@s.com');

INSERT INTO [tblSpainCustomers] VALUES
(1, 'Juan', 'j@j.com'),
(2, 'Sam', 's@s.com'),
(3, 'Ben', 'b@b.com'),
(4, 'Raj', 'r@r.com');

----
SELECT * FROM [tblIndiaCustomers]
UNION
SELECT * FROM [tblUKCustomers];

SELECT * FROM [tblIndiaCustomers]
UNION ALL
SELECT * FROM [tblUKCustomers];

SELECT * FROM [tblIndiaCustomers]
UNION
SELECT * FROM [tblUKCustomers]
UNION
SELECT * FROM [tblSpainCustomers];

SELECT * FROM [tblIndiaCustomers]
UNION ALL
SELECT * FROM [tblUKCustomers]
UNION ALL
SELECT * FROM [tblSpainCustomers];

----
SELECT * FROM [tblIndiaCustomers]
ORDER BY name
UNION ALL
SELECT * FROM [tblUKCustomers]; -- ❌ Will fail with 'Incorrect syntax near the keyword 'UNION', i.e. only allowed to add the order-by clause on the last table'

SELECT * FROM [tblIndiaCustomers]
UNION ALL
SELECT * FROM [tblUKCustomers]
ORDER BY name;

SELECT * FROM [tblIndiaCustomers]
UNION ALL
SELECT * FROM [tblUKCustomers]
UNION ALL
SELECT * FROM [tblSpainCustomers]
ORDER BY name;




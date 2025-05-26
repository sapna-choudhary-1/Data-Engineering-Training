------------------------------------------------------------------------------
---- SELECT Query ----
------------------------------------------------------------------------------

SELECT * FROM [dbo].[depts]; -- ❌ Will fail with 'Invalid object name 'dbo.depts' since different session'

SELECT * FROM [company].[dbo].[depts];

USE [company];
SELECT * FROM [dbo].[empls];  -- Will pass

INSERT INTO [empls] (emp_name, age, salary, dept_id) VALUES
('Charlie', 29, 70000, 2);

INSERT INTO [empls] (emp_name, age, salary) VALUES
('Charls', 32, 75000);

INSERT INTO [empls] VALUES
('Anna', 24, 50000, 1, '2021-10-01');


------------------------------------------------------------------------------
---- AGGREGATE FUNCTIONS ----
------------------------------------------------------------------------------

SELECT COUNT(*) AS total_empls
FROM [empls];

SELECT SUM(salary) AS total_empls
FROM [empls];

SELECT AVG(salary) AS total_empls
FROM [empls];

SELECT MIN(age) AS min_age, MAX(age) AS max_age
FROM [empls];


------------------------------------------------------------------------------
---- GROUP BY ----
------------------------------------------------------------------------------

SELECT dept_id, SUM(salary) AS dept_salary
FROM [empls]
GROUP BY dept_id;

SELECT dept_id, COUNT(*) AS dept_empls
FROM [empls]
GROUP BY dept_id;

SELECT COUNT(*) AS it_empls
FROM [empls]
WHERE dept_id = 2;

SELECT SUM(salary) AS hr_salary
FROM [empls]
WHERE dept_id = 1;

SELECT TOP 1 dept_id, SUM(salary) AS max_dept_salary
FROM [empls]
GROUP BY dept_id
ORDER BY max_dept_salary DESC;

SELECT dept_id, SUM(salary) AS dept_total_salary, AVG(salary) AS dept_avg_salary
FROM [empls]
GROUP BY dept_id;


------------------------------------------------------------------------------
---- GROUP BY - multiple columns & multiple aggregate functions ----
------------------------------------------------------------------------------

SELECT dept_id, join_date, SUM(salary) AS total_salary
FROM [empls]
GROUP BY dept_id, join_date;

SELECT dept_id, join_date, SUM(salary) AS total_salary, COUNT(*) AS total_empls
FROM [empls]
GROUP BY dept_id, join_date;

SELECT dept_id, join_date, SUM(salary) AS total_salary, COUNT(*) AS "total empls"
FROM [empls]
GROUP BY dept_id, join_date
ORDER BY dept_id;

SELECT join_date, dept_id, SUM(salary) AS total_salary, COUNT(*) AS [total empls]
FROM [empls]
GROUP BY join_date, dept_id
ORDER BY dept_id;


------------------------------------------------------------------------------
---- GROUP BY Filtering ----
------------------------------------------------------------------------------

SELECT dept_id, SUM(salary) AS each_dept_total_salary
FROM [empls]
WHERE dept_id <> 3
GROUP BY dept_id;

SELECT dept_id, SUM(salary) AS each_dept_total_salary
FROM [empls]
GROUP BY dept_id
HAVING dept_id <> 3;

----

SELECT dept_id, COUNT(*) AS more_than_1_empl_dept
FROM [empls]
GROUP BY dept_id
HAVING COUNT(*) > 1;

SELECT dept_id, AVG(salary) AS dept_avg_salary
FROM [empls]
GROUP BY dept_id
HAVING AVG(salary) >= 60000;

SELECT dept_id, age, SUM(salary) AS 
FROM [empls]
GROUP BY dept_id
HAVING AVG(salary) >= 60000;


------------------------------------------------------------------------------
---- JOINS ----
------------------------------------------------------------------------------

DROP TABLE [empls];
DROP TABLE [depts];
DROP TABLE [gender];

----
CREATE TABLE [gender]
(
ID INT CONSTRAINT PK_gender_id PRIMARY KEY,
gender NVARCHAR(10) NOT NULL
);

INSERT INTO gender (ID, gender) VALUES (0, 'Unknown');

----
CREATE TABLE [depts]
(
ID INT CONSTRAINT PK_depts_id PRIMARY KEY,
Name NVARCHAR(50) NOT NULL,
	CONSTRAINT UQ_depts_name UNIQUE (Name),
Location NVARCHAR(50) NOT NULL,
DeptHead NVARCHAR(50) NOT NULL,
	CONSTRAINT UQ_depts_dept_head UNIQUE (DeptHead)
);

----
CREATE TABLE [empls]
(
ID INT IDENTITY(1,1) CONSTRAINT PK_empls_id PRIMARY KEY,
Name NVARCHAR(50) NOT NULL,

Dept_id INT NULL,
--Gender_id INT NOT NULL CONSTRAINT DF_empls_gender DEFAULT 0, --- Not allowed to have 'constraint' added inline
--Gender_id INT NOT NULL DEFAULT 0, --- Only Allowed to have unnamed constraint inline
Gender_id INT NOT NULL,
Salary INT NOT NULL,
Join_date DATE NOT NULL,

CONSTRAINT FK_empls_gender_id FOREIGN KEY (Gender_id)
	REFERENCES [gender] (ID)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	
CONSTRAINT FK_empls_dept_id FOREIGN KEY (Dept_id)
	REFERENCES [depts] (ID)
	ON DELETE SET NULL
	ON UPDATE CASCADE,

CONSTRAINT CK_empls_salary CHECK (Salary >= 0),
CONSTRAINT CK_empls_join_date CHECK (Join_date <= GETDATE()),

CONSTRAINT DF_empls_gender DEFAULT 0 FOR Gender_id,
CONSTRAINT DF_empls_salary DEFAULT 30000 FOR Salary,
CONSTRAINT DF_empls_join_date DEFAULT GETDATE() FOR Join_date,
);
----




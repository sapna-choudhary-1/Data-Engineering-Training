-- ✅ ❌ ➡️ ❓❗➤ --
 
USE [db1];

DROP TABLE [depts];

CREATE TABLE [depts] (
	id INT IDENTITY(1,1) 
		CONSTRAINT pk_depts_id PRIMARY KEY,
	dept_name NVARCHAR(20)
);

CREATE TABLE [empls] (
	id INT 
		CONSTRAINT pk_empls_id PRIMARY KEY,
	name NVARCHAR(50) NOT NULL,
	gender NVARCHAR(10)
		CONSTRAINT df_empls_gender DEFAULT 'Male',
	dept_id INT
		CONSTRAINT fk_empls_dept_id 
		FOREIGN KEY (dept_id)
		REFERENCES [depts] (id)
);

INSERT INTO [depts]
VALUES ('IT'), ('Payroll'), ('HR'), ('Admin');

INSERT INTO [empls] VALUES
(1, 'John', 'Female', 3),
(2, 'Mike', DEFAULT, 2),
(3, 'Pam', 'Female', 1),
(4, 'Todd', DEFAULT, 4),
(5, 'Sara', 'Female', 1),
(6, 'Ben', DEFAULT, 3);


------------------------------------------------------------------------------
---- CTEs ----
------------------------------------------------------------------------------

------------------------------------------------------------------------------
---- USING VIEWS ----

DROP VIEW [vW_EmplsByDepts];

CREATE VIEW [vW_EmplsByDepts]
AS
SELECT dept_name, dept_id, COUNT(dept_name) AS total_empls
FROM [empls] e
JOIN [depts] d
ON e.dept_id = d.id
GROUP BY dept_name, dept_id;

SELECT * FROM [vW_EmplsByDepts]
WHERE total_empls >= 2;


------------------------------------------------------------------------------
---- USING TEMP TABLES ----

DROP TABLE [#TempEmplCount];

SELECT dept_name, dept_id, COUNT(dept_name) AS total_empls
INTO [#TempEmplCount]  --❗❗Structure is automatically inferred based on the select statement
FROM [empls] e
JOIN [depts] d
ON e.dept_id = d.id
GROUP BY dept_name, dept_id;

SELECT * FROM [#TempEmplCount]
WHERE total_empls >= 2;


------------------------------------------------------------------------------
---- USING TABLE VARIABLES ----

--❗❗Run the whole block altogether 
DECLARE @tblEmplCount TABLE (dept_name NVARCHAR(20), dept_id INT, total_empls INT);

INSERT @tblEmplCount
SELECT dept_name, dept_id, COUNT(dept_name) AS total_empls
FROM [empls] e
JOIN [depts] d
ON e.dept_id = d.id
GROUP BY dept_name, dept_id;

SELECT * FROM @tblEmplCount
WHERE total_empls >= 2;


------------------------------------------------------------------------------
---- USING DERIVED TABLE ----

SELECT * 
FROM (
	SELECT dept_name, dept_id, COUNT(dept_name) AS total_empls
	FROM [empls] e
	JOIN [depts] d
	ON e.dept_id = d.id
	GROUP BY dept_name, dept_id
	)
AS [dvTblEmplCount]
WHERE total_empls >= 2;


------------------------------------------------------------------------------
---- USING CTEs ----

--❗❗Run the whole block altogether 
WITH [cteTblEmplCount] (dept_name, dept_id, total_empls)
AS (
	SELECT dept_name, dept_id, COUNT(dept_name) AS total_empls
	FROM [empls] e
	JOIN [depts] d
	ON e.dept_id = d.id
	GROUP BY dept_name, dept_id
)
-- ❌ Will give syntax error if ended with a semicolon

SELECT * FROM [cteTblEmplCount]
WHERE total_empls >= 2;

---- Another way of above query ----
WITH [cteTblEmplCount2] (dept_id, total_empls)
AS (
	SELECT dept_id, COUNT(dept_id) AS total_empls
	FROM [empls] e
	GROUP BY dept_id
)

-- If the select statement using the cteTbl is not the immediate select statement
--SELECT 'Hello'-- ❌ Will give error 'Common table expression defined but not used'

SELECT dept_name, total_empls
FROM [cteTblEmplCount2] c
JOIN [depts] d
ON c.dept_id = d.id
WHERE total_empls >= 2
ORDER BY total_empls;


---- MULTIPLE CTEs WITH ONLY ONE 'WITH' CLAUSES ----
WITH [cteTblEmplCountBy_Payroll_IT_Dept] (dept_name, total_empls)
AS (
	SELECT dept_name, COUNT(*) AS total_empls
	FROM [empls] e
	JOIN [depts] d
	ON e.dept_id = d.id
	WHERE dept_name IN ('Payroll', 'IT')
	GROUP BY dept_name
),
[cteTblEmplCountBy_HR_Admin_Dept] (dept_name, total_empls)
AS (
	SELECT dept_name, COUNT(*) AS total_empls
	FROM [empls] e
	JOIN [depts] d
	ON e.dept_id = d.id
	WHERE dept_name IN ('HR', 'Admin')
	GROUP BY dept_name
)

SELECT * FROM [cteTblEmplCountBy_HR_Admin_Dept]
UNION
SELECT * FROM [cteTblEmplCountBy_Payroll_IT_Dept];



------------------------------------------------------------------------------
---- UPDATABLE CTEs ----

---- With one base table ----
SELECT * FROM [empls];

WITH [cteTblEmpl]
AS (
	SELECT id, name, gender
	FROM [empls]
	)
UPDATE [cteTblEmpl]
SET name = 'Sarah' WHERE name = 'Sara';

---- chk the changes ----
WITH [cteTblEmpl]
AS (
	SELECT id, name, gender
	FROM [empls]
	)
SELECT * FROM [cteTblEmpl];

SELECT * FROM [empls];

--------------------------------------------
---- chk with dept_id (foreign key col) ----
WITH [cteTblEmpl]
AS (
	SELECT *
	FROM [empls]
	)
UPDATE [cteTblEmpl]
SET dept_id = 4 WHERE name = 'Sarah';

WITH [cteTblEmpl]
AS (
	SELECT *
	FROM [empls]
	)
SELECT * FROM [cteTblEmpl];

SELECT * FROM [empls];
SELECT * FROM [depts];

-----------------------------------------------------------------
---- With more than one base table: impacts only one ----
SELECT * FROM [empls];
SELECT * FROM [depts];

WITH [cteTblEmpl]
AS (
	SELECT id, name, gender, dept_name
	FROM [empls] e
	JOIN [depts] d
	ON e.dept_id = d.id
	)
UPDATE [cteTblEmpl]
SET name = 'Sarah' WHERE name = 'Sara';

SELECT * FROM [empls];

--------------------------------------------
---- chk with dept_id (foreign key col) ----
-- ✅ Worked
WITH [cteTblEmpl]
AS (
	SELECT e.id, name, gender, dept_name, dept_id
	FROM [empls] e
	JOIN [depts] d
	ON e.dept_id = d.id
	)
UPDATE [cteTblEmpl]
--❗❗dept_id column must be present in the cte
--SET dept_id = 3 WHERE name = 'Sarah';
SET dept_name = 'IT' WHERE name = 'Sarah';

-- chk results
WITH [cteTblEmpl]
AS (
	SELECT e.id, name, gender, dept_name, dept_id
	FROM [empls] e
	JOIN [depts] d
	ON e.dept_id = d.id
	)
SELECT * FROM [cteTblEmpl];
SELECT * FROM [empls];
SELECT * FROM [depts];

--------------------------------------------
---- chk with dept_id (foreign key col) updating 'dept_name' ----
-- ❌ Didn't work correctly
WITH [cteTblEmpl]
AS (
	SELECT e.id, name, gender, dept_name, dept_id
	FROM [empls] e
	JOIN [depts] d
	ON e.dept_id = d.id
	)
SELECT * FROM [cteTblEmpl];
SELECT * FROM [depts];

WITH [cteTblEmpl]
AS (
	SELECT e.id, name, gender, dept_name, dept_id
	FROM [empls] e
	JOIN [depts] d
	ON e.dept_id = d.id
	)
UPDATE [cteTblEmpl]
-- ❌ will change in the depts table directly => also change for 'Pam'
-- because dept_name changed for dept_id=1 in depts tbl to HR, 
-- however we wanted that dept_id in empls tbl change to 3 (which would change dept_name in empls) 
-- infact: dept_id didn't got impacted
SET dept_name = 'HR' WHERE name = 'Sarah';

-- chk results
WITH [cteTblEmpl]
AS (
	SELECT e.id, name, gender, dept_name, dept_id
	FROM [empls] e
	JOIN [depts] d
	ON e.dept_id = d.id
	)
SELECT * FROM [cteTblEmpl];
SELECT * FROM [empls];
SELECT * FROM [depts];

-- REVERT
WITH [cteTblEmpl]
AS (
	SELECT e.id, name, gender, dept_name, dept_id
	FROM [empls] e
	JOIN [depts] d
	ON e.dept_id = d.id
	)
UPDATE [cteTblEmpl]
SET dept_name = 'IT' WHERE name = 'Sarah';

-- chk results
WITH [cteTblEmpl]
AS (
	SELECT e.id, name, gender, dept_name, dept_id
	FROM [empls] e
	JOIN [depts] d
	ON e.dept_id = d.id
	)
SELECT * FROM [cteTblEmpl];
SELECT * FROM [empls];
SELECT * FROM [depts];

--------------------------------------------
---- chk with dept_name (col that affects more than 1 base table) ----
-- ❌ Will give error with 'View or function 'cteTblEmpl' is not updatable because the modification affects multiple base tables.''
WITH [cteTblEmpl]
AS (
	SELECT e.id, name, gender, dept_name, dept_id
	FROM [empls] e
	JOIN [depts] d
	ON e.dept_id = d.id
	)
UPDATE [cteTblEmpl]
SET name = 'Sara', dept_name = 'HR' WHERE name = 'Sarah';

---------------------------------------------------
----❓❓ RECURSIVE CTEs ❓❓----

CREATE TABLE [tblEm]
	(
	eid INT PRIMARY KEY,
	name NVARCHAR(30),
	mid INT
	);
INSERT INTO [tblEm] VALUES
(1, 'Tom', 2),
(2, 'Josh', NULL),
(3, 'Mike', 2),
(4, 'John', 3),
(5, 'Pam', 1),
(6, 'Mary', 3),
(7, 'James', 1),
(8, 'Sam', 5),
(9, 'Simon', 1);

SELECT * FROM [tblEm];

---- Using Self Join ----
SELECT e.name AS "Employee Name", ISNULL(m.name, 'Super Boss') AS "Manager Name"
FROM [tblEm] e
LEFT JOIN [tblEm] m
ON e.mid = m.eid;

---- Using Recursive CTE ----
WITH
	[cteTblEmplManager] (eid, name, mid, [Level])
	AS
	(
		SELECT eid, name, mid, 1
		FROM [tblEm]
		WHERE mid IS NULL
		
		UNION ALL 
		
		SELECT e.eid, e.name, e.mid, [cteTblEmplManager].[Level] + 1
		FROM [tblEm] e
		JOIN [cteTblEmplManager] c
		ON e.mid = c.eid
	)
	
SELECT e.name AS "Employee Name", ISNULL(m.name, 'Super Boss') AS "Manager Name"
FROM [cteTblEmplManager] e
LEFT JOIN [cteTblEmplManager] m
ON e.mid = m.eid;
	










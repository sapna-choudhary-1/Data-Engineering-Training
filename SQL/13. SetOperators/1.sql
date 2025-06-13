
------------------------------------------------------------------------------
---- MERGE STATEMENT ----
------------------------------------------------------------------------------
USE [db1]

DROP TABLE [tblSrc];
DROP TABLE [tblTarget];

CREATE TABLE [tblSrc]
(
	id INT,
	name NVARCHAR(20)
);
CREATE TABLE [tblTarget]
(
	id INT,
	name NVARCHAR(20)
);

INSERT INTO [tblSrc] VALUES
(1, 'Mike'),
(2, 'Sara');
INSERT INTO [tblTarget] VALUES
(1, 'Mike M'),
(3, 'John');

SELECT * FROM [tblSrc];
SELECT * FROM [tblTarget];

------------------------------------------------------------------------------
---------- Merge  ----------
MERGE tblTarget AS t
USING tblSrc AS s
	ON t.ID = s.ID
WHEN MATCHED
	THEN
		UPDATE
		SET t.name = s.name
WHEN NOT MATCHED BY TARGET
	THEN
		INSERT (id, name)
		VALUES (s.id, s.name)
WHEN NOT MATCHED BY SOURCE
	THEN
		DELETE;

SELECT * FROM [tblSrc];
SELECT * FROM [tblTarget];


---------- After redefining the tables: Only update and insert  ----------
MERGE tblTarget AS t
USING tblSrc AS s
	ON t.ID = s.ID
WHEN MATCHED
	THEN
		UPDATE
		SET t.name = s.name
WHEN NOT MATCHED BY TARGET
	THEN
		INSERT (id, name)
		VALUES (s.id, s.name);

SELECT * FROM [tblSrc];
SELECT * FROM [tblTarget];


---------- After redefining the tables: Only update  ----------
MERGE tblTarget AS t
USING tblSrc AS s
	ON t.ID = s.ID
WHEN MATCHED
	THEN
		UPDATE
		SET t.name = s.name;

SELECT * FROM [tblSrc];
SELECT * FROM [tblTarget];


---------- After redefining the tables: Only insert  ----------
MERGE tblTarget AS t
USING tblSrc AS s
	ON t.ID = s.ID
WHEN NOT MATCHED BY TARGET
	THEN
		INSERT (id, name)
		VALUES (s.id, s.name);

SELECT * FROM [tblSrc];
SELECT * FROM [tblTarget];


---------- After redefining the tables: Only delete ----------
MERGE tblTarget AS t
USING tblSrc AS s
	ON t.ID = s.ID
WHEN NOT MATCHED BY SOURCE
	THEN
		DELETE;

SELECT * FROM [tblSrc];
SELECT * FROM [tblTarget];



------------------------------------------------------------------------------
---- EXCEPT OPERATOR ----
------------------------------------------------------------------------------
USE [db1]

DROP TABLE [TableA];
DROP TABLE [TableB];
DROP TABLE [TableC];

CREATE TABLE TableA (Id INT, Name NVARCHAR(50), Gender NVARCHAR(10));
INSERT INTO TableA VALUES
(1, 'Mark', 'Male'),
(2, 'Mary', 'Female'),
(3, 'Steve', 'Male'),
(4, 'John', 'Male'),
(5, 'Sara', 'Female'),
(6, NULL, 'Female'),
(7, 'Sara', NULL),
(8, NULL, NULL),
(NULL, 'Sara', 'Female'),
(NULL, NULL, NULL),
--
(11, 'Sarah', NULL),
(12, NULL, NULL),
(13, 'Max', 'Male'),
(NULL, 'Sarah', 'Female'),
(NULL, NULL, NULL);

CREATE TABLE TableB (Id INT, Name NVARCHAR(50), Gender NVARCHAR(10));
INSERT INTO TableB VALUES
(4, 'John', 'Male'),
(5, 'Sara', 'Female'),
(6, 'Pam', 'Female'),
(7, 'Rebeka', 'Female'),
(8, 'Jordan', 'Male'),
(6, NULL, 'Female'),
(7, 'Sara', NULL),
(8, NULL, NULL),
(NULL, 'Sara', 'Female'),
(NULL, NULL, NULL),
--
(10, NULL, 'Male');

CREATE TABLE TableC (Id INT identity, Name NVARCHAR(100), Gender NVARCHAR(10), Salary INT);
INSERT INTO TableC VALUES
('Mark', 'Male', 52000),
('Mary', 'Female', 55000),
('Steve', 'Male', 45000),
('John', 'Male', 40000),
('Sara', 'Female', 48000),
('Pam', 'Female', 60000),
('Tom', 'Male', 58000),
('George', 'Male', 65000),
('Tina', 'Female', 67000),
('Ben', 'Male', 80000);

SELECT * FROM [TableA];
SELECT * FROM [TableB];
SELECT * FROM [TableC];

------------------------------------------------------------------------------
---------- TableA - TableB ----------
SELECT Id, Name, Gender
FROM TableA
EXCEPT
SELECT Id, Name, Gender
FROM TableB


---------- TableB - TableA ----------
SELECT Id, Name, Gender
FROM TableB
EXCEPT
SELECT Id, Name, Gender
FROM TableA


------------------------------------------------------------------------------
---------- TableC ----------
SELECT * FROM [TableC]
WHERE Salary >= 50000;

SELECT * FROM [TableC]
WHERE Salary >= 60000;

----------  ----------
SELECT Id, Name, Gender, Salary
FROM TableC
WHERE Salary >= 50000
EXCEPT
SELECT Id, Name, Gender, Salary
FROM TableC
WHERE Salary >= 60000;

----------  ----------
SELECT Id, Name, Gender, Salary
FROM TableC
WHERE Salary >= 50000
EXCEPT
SELECT Id, Name, Gender, Salary
FROM TableC
WHERE Salary >= 60000
ORDER BY Name DESC


------------------------------------------------------------------------------
---- EXCEPT VS. NOT IN OPERATOR ----
------------------------------------------------------------------------------
SELECT Id, Name, Gender
FROM TableA
EXCEPT
SELECT Id, Name, Gender
FROM TableB

---------- ❗Doesn't return any output, since entire Not In condition fails upon encounter to NULL ----------
SELECT Id, Name, Gender
FROM TableA
WHERE id NOT IN
(
	SELECT Id
	FROM TableB
)

---------- ➡️ Hence ----------
SELECT Id, Name, Gender
FROM TableA
WHERE id NOT IN
(
	SELECT Id
	FROM TableB
	WHERE id IS NOT NULL
)


------------------------------------------------------------------------------
---- INTERSECT Vs. IN Operator VS. INNER JOIN OPERATOR ----
------------------------------------------------------------------------------
SELECT Id, Name, Gender
FROM TableA
INTERSECT
SELECT Id, Name, Gender
FROM TableB
ORDER BY id

----------  ----------
SELECT Id, Name, Gender
FROM TableA
WHERE id IN
(
	SELECT Id
	FROM TableB
)

----------  ----------
SELECT A.Id, A.Name, A.Gender
FROM TableA AS A
JOIN TableB AS B
ON A.ID = B.ID
ORDER BY A.id;

----------  ----------
SELECT DISTINCT A.Id, A.Name, A.Gender
FROM TableA AS A
JOIN TableB AS B
ON A.ID = B.ID
ORDER BY A.id;




------------------------------------------------------------------------------
---- APPLY OPERATOR ----
------------------------------------------------------------------------------
CREATE TABLE testDepartment (Id INT PRIMARY KEY, DepartmentName NVARCHAR(50));
INSERT INTO testDepartment VALUES
(1, 'IT'),
(2, 'HR'),
(3, 'Payroll'),
(4, 'Administration'),
(5, 'Sales');

CREATE TABLE testEmployee (Id INT PRIMARY KEY, Name NVARCHAR(50), Gender NVARCHAR(10), Salary INT, DepartmentId INT FOREIGN KEY REFERENCES testDepartment(id));
INSERT INTO testEmployee VALUES
(1, 'Mark', 'Male', 50000, 1),
(2, 'Mary', 'Female', 60000, 3),
(3, 'Steve', 'Male', 45000, 2),
(4, 'John', 'Male', 56000, 1),
(5, 'Sara', 'Female', 39000, 2);

SELECT * FROM [testDepartment];
SELECT * FROM [testEmployee];


----------  ----------
SELECT d.DepartmentName, e.Name, e.Gender, e.Salary
FROM testDepartment AS d
JOIN testEmployee AS e
ON d.ID = e.DepartmentId
ORDER BY d.id;

----------  ----------
SELECT d.DepartmentName, e.Name, e.Gender, e.Salary
FROM testDepartment AS d
LEFT JOIN testEmployee AS e
ON d.ID = e.DepartmentId
ORDER BY d.id;

---------- Creating Table-Valued Function ----------
CREATE FUNCTION fn_GetEmployeesByDepartmentId (@DepartmentId INT)
RETURNS TABLE
AS
RETURN (
		SELECT Id, Name, Gender, Salary, DepartmentId
		FROM testEmployee
		WHERE DepartmentId = @DepartmentId
		)

----------  ----------
SELECT *
FROM fn_GetEmployeesByDepartmentId(1)

---------- ❌ Error: The multi-part identifier "d.Id" could not be bound.
SELECT d.DepartmentName, e.Name, e.Gender, e.Salary
FROM testDepartment AS d
JOIN fn_GetEmployeesByDepartmentId(d.Id) AS e
ON d.ID = e.DepartmentId
ORDER BY d.id;

---------- ❌ ----------
SELECT d.DepartmentName, e.Name, e.Gender, e.Salary
FROM testDepartment AS d
LEFT JOIN fn_GetEmployeesByDepartmentId(d.Id) AS e
ON d.ID = e.DepartmentId
ORDER BY d.id;


---------- ✅ Hence Cross Apply and Outer Apply works now ----------

SELECT d.DepartmentName, e.Name, e.Gender, e.Salary
FROM testDepartment d
CROSS APPLY fn_GetEmployeesByDepartmentId(d.Id) e

----------  ----------
SELECT d.DepartmentName, e.Name, e.Gender, e.Salary
FROM testDepartment d
OUTER APPLY fn_GetEmployeesByDepartmentId(d.Id) e






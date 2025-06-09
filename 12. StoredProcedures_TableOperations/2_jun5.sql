------------------------------------------------------------------------------
---- TABLE OPERATIONS ----
------------------------------------------------------------------------------

USE master;

SELECT * 
FROM sys.tables;

SELECT *
FROM INFORMATION_SCHEMA.TABLES ;

EXEC sp_help;

EXEC sp_tables;


------------------------------------------------------------------------------
---- LIST ALL TABLES ----
------------------------------------------------------------------------------
USE [db1]

SELECT * FROM SYSOBJECTS WHERE XTYPE = 'U';
SELECT DISTINCT XTYPE FROM SYSOBJECTS;
SELECT * FROM SYSOBJECTS;

SELECT name FROM SYS.TABLES;
SELECT name FROM SYS.PROCEDURES;

SELECT table_name FROM INFORMATION_SCHEMA.TABLES;
SELECT table_name FROM INFORMATION_SCHEMA.VIEWS;
-- STORED PROCEDURES
SELECT specific_name FROM INFORMATION_SCHEMA.ROUTINES;

---------- Chk if the obj exists already ----------
SELECT OBJECT_ID('tblEmpls');

-- 
IF OBJECT_ID('tblEmpls') IS NOT NULL
	BEGIN
		PRINT 'Tbl exists already'
	END
ELSE
	BEGIN
		PRINT 'Tbl dont exists'
	END


---------- Chk if the obj exists already ----------
IF EXISTS (
SELECT * FROM INFORMATION_SCHEMA.TABLES
WHERE table_name = 'tblEmpls'
)
	BEGIN
		PRINT 'Tbl exists already'
	END
ELSE
	BEGIN
		PRINT 'Tbl dont exists'
END



------------------------------------------------------------------------------
------------------------------------------------------------------------------
---- OPERATIONS ON TABLE COLUMN ----
------------------------------------------------------------------------------
------------------------------------------------------------------------------
USE [db1]

DROP TABLE [tblTest]

CREATE TABLE [tblTest] (
	id INT IDENTITY(1,1),
    name NVARCHAR(50),
    gender NVARCHAR(10),
    dept_id NVARCHAR(10)
)

INSERT INTO [tblTest] VALUES
('John', 'Male', 3),
('Mike', 'Male', 2)

SELECT * FROM [tblTest]

------------------------------------------------------------------------------
---------- Add new column ----------
ALTER TABLE [tblTest]
ADD salary INT;

ALTER TABLE [tblTest]
ADD salary2 INT;

SELECT * FROM [tblTest]

------------------------------------------------------------------------------
---------- Drop column ----------
ALTER TABLE [tblTest]
DROP COLUMN salary2;

SELECT * FROM [tblTest]

------------------------------------------------------------------------------
---------- Add Default constraint ----------
ALTER TABLE tblTest
ADD CONSTRAINT DF_tblTest_salary DEFAULT 30000 FOR salary;

SELECT * FROM [tblTest]


------------------------------------------------------------------------------
---------- Drop Default constraint ----------

SELECT name
FROM sys.default_constraints
WHERE parent_object_id = OBJECT_ID('tblTest');

ALTER TABLE tblTest
DROP CONSTRAINT DF__tblTest__salary__6442E2C9;

SELECT * FROM [tblTest]

------------------------------------------------------------------------------
---------- Add default constraint ----------
ALTER TABLE tblTest
ADD CONSTRAINT DF_tblTest_Salary DEFAULT 30000 FOR salary;

SELECT * FROM [tblTest]

------------------------------------------------------------------------------
---------- Set default constraint value to already existing rows as well ----------
UPDATE tblTest
SET salary = 30000
WHERE salary IS NULL;

SELECT * FROM [tblTest]

------------------------------------------------------------------------------
---------- Alter table's col dt and/or {NULL} property ----------
ALTER TABLE tblTest
ALTER COLUMN dept_id INT NOT NULL

SELECT * FROM [tblTest]

------------------------------------------------------------------------------
---------- Add Different Constraints ----------

---- PRIMARY KEY ----
ALTER TABLE tblTest
ADD CONSTRAINT PK_tblTest_Id PRIMARY KEY (id);

---- UNIQUE ----
ALTER TABLE tblTest
ADD CONSTRAINT UQ_tblTest_email UNIQUE (name);

---- CHECK ----
ALTER TABLE tblTest
ADD CONSTRAINT CHK_tblTest_salary CHECK (salary >= 0);

---- FOREIGN KEY ----
ALTER TABLE tblTest
ADD CONSTRAINT FK_tblTest_dept FOREIGN KEY (dept_id)
REFERENCES depts(id);


------------------------------------------------------------------------------
---------- Check column info ----------
EXEC sp_help 'tblTest'

-- View col names and dts --
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'tblTest';

------------------------------------------------------------------------------
---------- See the Different Constraints of Table ----------
SELECT name, type_desc
FROM sys.objects
WHERE parent_object_id = OBJECT_ID('tblTest');


SELECT name, type_desc
FROM sys.default_constraints
WHERE parent_object_id = OBJECT_ID('tblTest');


SELECT name, type_desc
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID('tblTest');

------------------------------------------------------------------------------
---------- Check If Column EXISTS ----------
IF EXISTS (
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE COLUMN_NAME = 'salary'
)
BEGIN
	PRINT 'Column EXISTS'
END
ELSE
BEGIN
	PRINT 'Column NOT EXISTS'
END

---- Using COL_LENGTH() Function ----
IF COL_LENGTH('tblTest', 'salary') IS NOT NULL
BEGIN
	PRINT 'Column EXISTS'
END
ELSE
BEGIN
	PRINT 'Column NOT EXISTS'
END


------------------------------------------------------------------------------
------------------------------------------------------------------------------
---- SELECT INTO ----
------------------------------------------------------------------------------
------------------------------------------------------------------------------
USE [db1]

SELECT * FROM [tblTest]

SELECT * INTO [tblTestBackup]
FROM [tblTest]

SELECT * FROM [tblTestBackup];
DROP TABLE [tblTestBackup];


------------------------------------------------------------------------------
---------- Select cols from 2 or more tables ----------
SELECT t1.*, t2.dept_name INTO [tblTestBackup]
FROM [tblTest] t1
JOIN [depts] t2
ON t1.dept_id = t2.id;

SELECT * FROM [tblTestBackup];
DROP TABLE [tblTestBackup];

------------------------------------------------------------------------------
---------- Add Only the cols and datatypes of existing table, not the data ----------
SELECT * INTO [tblTestBackup]
FROM [tblTest]
WHERE 1 <> 1;

SELECT * FROM [tblTestBackup];
DROP TABLE [tblTestBackup];


------------------------------------------------------------------------------
---------- To add data into already existing table ----------
-- ❌ Will give error 'There is already an object named 'tblTest2' in the database.'
SELECT * INTO [tblTest]
FROM [tblTestBackup]

-- ❌ Will give error 'An explicit value for the identity column in table 'tblTestBackup' can only be specified when a column list is used and IDENTITY_INSERT is ON.'
INSERT INTO [tblTestBackup]
SELECT *
FROM [tblTest];

-- ✅ --
INSERT INTO [tblTestBackup] (name, gender, dept_id, salary)
SELECT name, gender, dept_id, salary
FROM [tblTest];

SELECT * FROM [tblTestBackup];
SELECT * FROM [tblTest];

------------------------------------------------------------------------------
---------- Remove data from table ----------
TRUNCATE TABLE [tblTestBackup];
DELETE FROM [tblTestBackup];





------------------------------------------------------------------------------
------------------------------------------------------------------------------
---- OBJECT REFERENCING ----
------------------------------------------------------------------------------
------------------------------------------------------------------------------
USE [db1]

---------- Create empty table ----------
DROP TABLE [tblTestEmpls];
DROP TABLE [tblTestDepts];

CREATE TABLE [tblTestDepts] (
	deptId INT PRIMARY KEY IDENTITY(1,1),
    deptName NVARCHAR(50)
);

CREATE TABLE [tblTestEmpls] (
	id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(50),
    dept_id INT FOREIGN KEY	REFERENCES [tblTestDepts] (deptId)
);


SELECT * FROM [tblTestEmpls];
SELECT * FROM [tblTestDepts];


------------------------------------------------------------------------------
---------- Check the foreign key dependencies ----------
SELECT
    OBJECT_NAME(fk.parent_object_id) AS TableName,
    OBJECT_NAME(fk.referenced_object_id) AS TableName,
    fk.name AS ForeignKey,
    *
FROM 
    sys.foreign_keys AS fk
WHERE 
    fk.referenced_object_id = OBJECT_ID('dbo.tblTestDepts');

SELECT OBJECT_NAME(referenced_column_id),
	OBJECT_NAME(referenced_object_id),
	OBJECT_NAME(constraint_column_id),
	*
FROM 
    sys.foreign_key_columns
WHERE 
    referenced_object_id = OBJECT_ID('dbo.tblTestDepts');

----  ----
SELECT 
    fk.name AS ForeignKey,
    OBJECT_NAME(fk.parent_object_id) AS ReferencingTable,
    c1.name AS ReferencingColumn,
    OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable,
    c2.name AS ReferencedColumn
FROM 
    sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fkc
    ON fk.object_id = fkc.constraint_object_id
INNER JOIN sys.columns AS c1
    ON fkc.parent_object_id = c1.object_id AND fkc.parent_column_id = c1.column_id
INNER JOIN sys.columns AS c2
    ON fkc.referenced_object_id = c2.object_id AND fkc.referenced_column_id = c2.column_id;



------------------------------------------------------------------------------
---- Checking Table level dependencies ----
-- ❌ Will give error:- Could not drop object 'tblTestDepts' because it is referenced by a FOREIGN KEY constraint.
DROP TABLE [tblTestDepts];


------------------------------------------------------------------------------
---- Creating Dependencies ----
DROP PROCEDURE spGetEmpls

CREATE PROCEDURE spGetEmpls
AS
BEGIN
	SELECT *
	FROM tblTestEmpls
END

EXEC spGetEmpls


----  ----
DROP PROCEDURE spGetEmplsandDepts

CREATE PROCEDURE spGetEmplsandDepts
AS
BEGIN
	SELECT tblTestEmpls.name AS EmployeeName, tblTestDepts.deptName AS DepartmentName
	FROM tblTestEmpls
	JOIN tblTestDepts
		ON tblTestEmpls.dept_id = tblTestDepts.deptId
END;

EXEC spGetEmplsandDepts


----  ----
DROP VIEW VwDepts
DROP VIEW VwEmpls

CREATE VIEW VwDepts
AS
SELECT *
FROM tblTestDepts

CREATE VIEW VwEmpls
AS
SELECT *
FROM tblTestEmpls

SELECT * FROM [VwDepts];
SELECT * FROM [VwEmpls];

------------------------------------------------------------------------------
---------- Checking the object dependencies ----------
SELECT referencing_entity_name
FROM sys.dm_sql_referencing_entities('dbo.tblTestEmpls', 'Object')

SELECT referencing_entity_name
FROM sys.dm_sql_referencing_entities('dbo.tblTestDepts', 'Object')

SELECT referencing_entity_name
FROM sys.dm_sql_referencing_entities('dbo.spGetEmpls', 'Object')

SELECT referencing_entity_name
FROM sys.dm_sql_referencing_entities('dbo.spGetEmplsandDepts', 'Object')

SELECT referencing_entity_name
FROM sys.dm_sql_referencing_entities('dbo.VwDepts', 'Object')


----  ----
SELECT referenced_entity_name, referenced_minor_name
FROM sys.dm_sql_referenced_entities('dbo.tblTestEmpls', 'Object')

SELECT referenced_entity_name, referenced_minor_name
FROM sys.dm_sql_referenced_entities('dbo.tblTestDepts', 'Object')

SELECT referenced_entity_name, referenced_minor_name
FROM sys.dm_sql_referenced_entities('dbo.spGetEmpls', 'Object')

SELECT referenced_entity_name, referenced_minor_name
FROM sys.dm_sql_referenced_entities('dbo.spGetEmplsandDepts', 'Object')

SELECT referenced_entity_name, referenced_minor_name
FROM sys.dm_sql_referenced_entities('dbo.VwDepts', 'Object')

----  ----
EXEC sp_depends 'tblTestEmpls';
EXEC sp_depends 'tblTestDepts';
EXEC sp_depends 'spGetEmpls';
EXEC sp_depends 'spGetEmplsandDepts';
EXEC sp_depends 'VwDepts';


------------------------------------------------------------------------------
---- Checking Table level dependencies ----
-- ➡️ Will NOT give error -> will delete the tables. Since, Schemabinding option not ON on depts table
DROP TABLE [tblTestEmpls];
DROP TABLE [tblTestDepts];


---- Adding schemabinding option ---
ALTER VIEW VwDepts
WITH SCHEMABINDING
AS
SELECT deptId, deptName
FROM dbo.tblTestDepts;


---- ➡️ Now even if testEmpls is deleted, testDepts can't be ----
-- ❗❗ Will give error:- Cannot DROP TABLE 'tblTestDepts' because it is being referenced by object 'VwDepts'.
DROP TABLE [tblTestEmpls];
DROP TABLE [tblTestDepts];










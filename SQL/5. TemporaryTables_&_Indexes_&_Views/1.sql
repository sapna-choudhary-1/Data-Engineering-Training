USE db1;
SELECT * FROM info;

------------------------------------------------------------------------------
---- TEMPORARY TABLES ----
------------------------------------------------------------------------------

DROP TABLE IF EXISTS #tempTbl;

CREATE TABLE #tempTbl (id INT, name VARCHAR(20));

INSERT INTO [#tempTbl] VALUES
(1, 'Mike'), (2, 'Sara');

SELECT * FROM [#tempTbl];

SELECT * FROM tempdb..sysobjects
WHERE name LIKE '#tempTbl%';

-----
CREATE TABLE ##globalTempTbl (id INT, name VARCHAR(20));

INSERT INTO [##globalTempTbl] VALUES
(1, 'Mike'), (2, 'Sara');

SELECT * FROM [##globalTempTbl];

SELECT * FROM tempdb..sysobjects
WHERE name LIKE '##globalTempTbl';



------------------------------------------------------------------------------
-- Create a temp table
CREATE TABLE #CleanData (
    id INT,
    name NVARCHAR(50)
);

-- Insert filtered data from another table
INSERT INTO #CleanData
SELECT id, name
FROM RawTable
WHERE is_active = 1;


------------------------------------------------------------------------------
---- INDEXES ----
------------------------------------------------------------------------------

CREATE NONCLUSTERED INDEX IX_info_name
ON info(name DESC);

sp_Helpindex [info];

------------------------------------------------------------------------------
---- ???----
------------------------------------------------------------------------------
SELECT DB_NAME(PageDetail.database_id)
AS              DatabaseName, 
        OBJECT_NAME(PageDetail.object_id)
AS              TableName, 
        ind.Name IndexName, 
        allocated_page_page_id
FROM sys.dm_db_database_page_allocations
(DB_ID('NewData'), OBJECT_ID('TestDublicate'), 1, NULL, 'DETAILED') PageDetail
LEFT OUTER JOIN
sys.indexes ind
ON ind.object_id = PageDetail.object_id AND 
    ind.index_id = PageDetail.index_id
WHERE is_allocated = 1 AND 
        page_type IN
(1, 
    2)
ORDER BY page_level DESC, 
            is_allocated DESC, 
            previous_page_page_id;

------------------------------------------------------------------------------
---- VIEWS ----
------------------------------------------------------------------------------
USE [company];

SELECT * FROM [depts];
SELECT * FROM [empls];

CREATE VIEW vWEmployeeByDepartment
AS
SELECT e.id, name, salary, dept_name, location
FROM [empls] e
JOIN [depts] d
ON e.dept_id = d.id;

SELECT * FROM [vWEmployeeByDepartment];
DROP VIEW [vWEmployeeByDepartment];

-- Add row-lvl security: view empls of particular dept only --
CREATE VIEW vWITEmployee
AS
SELECT e.id, name, salary, dept_name, location
FROM [empls] e
JOIN [depts] d
ON e.dept_id = d.id
WHERE dept_name = 'IT';

SELECT * FROM [vWITEmployee];

-- Add col-lvl security: not allow to view the salary of empls --
CREATE VIEW vWNonConfidentialData
AS
SELECT e.id, name, dept_name, location
FROM [empls] e
JOIN [depts] d
ON e.dept_id = d.id;

SELECT * FROM [vWNonConfidentialData];

-- Alter view --
CREATE VIEW [vWShowGender]
AS
SELECT e.id, name, salary, dept_name, location
FROM [empls] e
JOIN [depts] d ON e.dept_id = d.id;

SELECT * FROM [vWShowGender];

ALTER VIEW [vWShowGender]
AS
SELECT e.id, name, salary, g.gender, dept_name, location
FROM [empls] e
JOIN [depts] d ON e.dept_id = d.id
JOIN [gender] g ON e.gender_id = g.id;

SELECT * FROM [vWShowGender];

-- Drop View --
DROP VIEW [vWShowGender];

-- helptext --
sp_helptext [vWShowGender];
EXEC sp_helptext [vWShowGender];

-- Rename View --
EXEC sp_rename 'vWShowGender', 'vWshowGender';
SELECT * FROM [vWshowGender];

EXEC sp_rename [vWshowGender], [vWShowGender];
SELECT * FROM [vWShowGender];


------------------------------------------------------------------------------
---- UPDATEABLE VIEWS ----
------------------------------------------------------------------------------

CREATE VIEW [vWempls]
AS
SELECT id, name, dept_id FROM [empls];

SELECT * FROM [vWempls];

INSERT INTO [vWempls] VALUES ('Ron', 4);
INSERT INTO [vWempls] VALUES ('Ronny', 4);
SELECT * FROM [vWempls] ORDER BY id DESC;
SELECT * FROM [empls] ORDER BY id DESC;

-- but if made on view of more than 2 joined tables --
SELECT * FROM [vWEmployeeByDepartment] ORDER BY id DESC;

UPDATE [vWEmployeeByDepartment] 
SET dept_name='Other' 
WHERE name='Ronny'; -- ❌ Will make change in the depts table too & for all the empls with dept_id=4, & not for just 'Ronny'

SELECT * FROM [vWEmployeeByDepartment] ORDER BY id DESC;
SELECT * FROM [empls] ORDER BY id DESC; -- ❌ dept_id changed for both Ronny and Ron
SELECT * FROM [depts] ORDER BY id DESC; -- ❌ dept_name changed to 'Other'


------------------------------------------------------------------------------
---- INDEXED VIEWS ----
------------------------------------------------------------------------------

CREATE TABLE [prods]
(prod_id INT, name VARCHAR(20), unit_price INT);
CREATE TABLE [sales]
(prod_id INT, qty_sold INT);

INSERT INTO [prods] VALUES 
(1, 'books', 20),
(2, 'pens', 14),
(3, 'pencils', 11),
(4, 'clips', 10);
INSERT INTO [sales] VALUES 
(1, 10), (3, 23), (4, 21), (2, 12), (1, 13), (3, 12), (4, 13), (1, 11), (2, 12), (1, 14);

DROP TABLE [prods];
DROP TABLE [sales];

SELECT * FROM [prods];
SELECT * FROM [sales];

CREATE VIEW [vWTotalSalesByProducts]
AS
SELECT name, SUM((qty_sold * unit_price)) AS total_sales, COUNT(name) AS total_transactions
FROM [prods] p
JOIN sales s
ON p.prod_id = s.prod_id
GROUP BY name;

DROP VIEW [vWTotalSalesByProducts];

SELECT * FROM [vWTotalSalesByProducts];


-- correct way --
CREATE VIEW [vWIndexedTotalSalesByProducts]
WITH SCHEMABINDING -- Guideline 1
AS
SELECT name, SUM(ISNULL((qty_sold * unit_price), 0)) AS total_sales, COUNT_BIG(*) AS total_transactions -- Guideline 2,3
FROM [dbo].[prods] -- Guideline 3
JOIN [dbo].[sales]
ON [dbo].[prods].prod_id = [dbo].[sales].prod_id
GROUP BY name;

SELECT * FROM [vWIndexedTotalSalesByProducts];
DROP VIEW [vWIndexedTotalSalesByProducts];

CREATE UNIQUE CLUSTERED INDEX UIX_vWIndexedTotalSalesByProducts_name
ON [vWIndexedTotalSalesByProducts] (name DESC);

SELECT * FROM [vWIndexedTotalSalesByProducts];


------------------------------------------------------------------------------
---- LIMITATIONS OF VIEWS ----
------------------------------------------------------------------------------

------ 1 ------
-- parameterized views not allowed --
CREATE VIEW [vWParameterised] (@name_like VARCHAR(10))
AS
SELECT name, unit_price FROM [prods]
WHERE name LIKE @name_like; -- ❌ Will fail with 'Incorrect syntax near '@name_like' '

-- way-around --
CREATE VIEW [vWParameterised]
AS
SELECT name, unit_price FROM [prods];

SELECT * FROM [vWParameterised]
WHERE name LIKE 'p%';

-- Replacement: Inline table-valued fn --
CREATE FUNCTION parameterized_vw (@name_like VARCHAR(10))
RETURNS Table
AS
RETURN (
		SELECT name, unit_price FROM [prods]
		WHERE name LIKE @name_like
	);

SELECT * FROM [dbo].[parameterized_vw]('p%');

------ 2 ------
-- order by not allowed --
CREATE VIEW [vWempls2]
AS
SELECT id, name, dept_id FROM [empls]
ORDER BY id DESC; -- ❌ Will fail with 'The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified. ''

-- way-around --
CREATE VIEW [vWempls2]
AS
SELECT id, name, dept_id FROM [empls];

SELECT * FROM [vWempls2] ORDER BY id DESC;

-- correct-way: Use top, offset, or For XML --
CREATE VIEW [vWempls3]
AS
SELECT TOP 10 id, name, dept_id FROM [empls]
ORDER BY id DESC;

SELECT * FROM [vWempls3];

drop view [vWempls3];

















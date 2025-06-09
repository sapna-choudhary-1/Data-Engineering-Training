
------------------------------------------------------------------------------
---- NEW SQL FUNCTIONS ----
------------------------------------------------------------------------------
USE [db1];

DROP TABLE [tblEmployees];

CREATE TABLE [tblEmployees] (id INT PRIMARY KEY identity, name NVARCHAR(10), genderId INT, dob DATE);

INSERT INTO [tblEmployees] VALUES
('Mark', 1, '01/11/1980'),
('John', 1, '12/12/1981'),
('Amy', 2, '11/21/1979'),
('Ben', 1, '05/14/1978'),
('Sara', 2, '03/17/1970'),
('David', 1, '04/05/1978');

SELECT * FROM [tblEmployees];



------------------------------------------------------------------------------
------------------------------------------------------------------------------
---------- CHOOSE() ----------
------------------------------------------------------------------------------
------------------------------------------------------------------------------
SELECT CHOOSE(2, 'India', 'US', 'UK'),
	CHOOSE(0, 'India', 'US', 'UK'),
	CHOOSE(6, 'India', 'US', 'UK')
AS country;

------------------------------------------------------------------------------
--(Q1) Display Month name along with employee Name and Date of Birth ----
------------------------------------------------------------------------------

---- Method-1: Using CASE-WHEN ----
SELECT name, dob,
	CASE DATEPART(MM, dob)
		WHEN 1 THEN 'JAN'
		WHEN 2 THEN 'FEB'
		WHEN 3 THEN 'MAR'
		WHEN 4 THEN 'APR'
		WHEN 5 THEN 'MAY'
		WHEN 6 THEN 'JUN'
		WHEN 7 THEN 'JULY'
		WHEN 8 THEN 'AUG'
		WHEN 9 THEN 'SEP'
		WHEN 10 THEN 'OCT'
		WHEN 11 THEN 'NOV'
		WHEN 12 THEN 'DEC'
	END
	AS [month]
FROM [tblEmployees]
ORDER BY DATEPART(MM, dob);

------------------------------------------------------------------------------
---- Method-2: Using CHOOSE()----
SELECT name, dob,
	CHOOSE(DATEPART(MM, dob), 'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC') AS [month]
FROM [tblEmployees]
ORDER BY DATEPART(MM, dob);



------------------------------------------------------------------------------
------------------------------------------------------------------------------
---------- IIF() ----------
------------------------------------------------------------------------------
------------------------------------------------------------------------------
DECLARE @Gender INT
SET @Gender = 1
SELECT IIF(@Gender = 1, 'Male', 'Female') AS Gender;

------------------------------------------------------------------------------
--(Q1) Return gender for genderIds ----
------------------------------------------------------------------------------

---- Method-1: Using CASE-WHEN ----
SELECT name, genderId, 
	CASE WHEN genderId=1
		THEN 'Male'
		ELSE 'Female'
	END AS gender
FROM [tblEmployees];

------------------------------------------------------------------------------
---- Method-2: Using IIF() ----
SELECT name, genderId,
	IIF(genderId = 1, 'Male', 'Female') AS gender
FROM [tblEmployees];



------------------------------------------------------------------------------
------------------------------------------------------------------------------
---------- TRY_PARSE() ----------
------------------------------------------------------------------------------
------------------------------------------------------------------------------
SELECT TRY_PARSE('99' AS INT),
	TRY_PARSE('ABC' AS INT) AS Result;

---- Replacing NULL with specific value ----
SELECT 
	CASE 
		WHEN TRY_PARSE('99' AS INT) IS NULL
		THEN 'Conversion Failed'
		ELSE 'Conversion Successful'
	END AS Result1,
--
	CASE 
		WHEN TRY_PARSE('ABC' AS INT) IS NULL
		THEN 'Conversion Failed'
		ELSE 'Conversion Successful'
	END AS Result2;

----  ----
SELECT 
	IIF(TRY_PARSE('99' AS INT) IS NULL,
		'Conversion Failed',
		'Conversion Successful'
		) AS Result1,
	IIF(TRY_PARSE('ABC' AS INT) IS NULL,
		'Conversion Failed',
		'Conversion Successful'
		) AS Result2;


------------------------------------------------------------------------------
---------- PARSE() ----------
------------------------------------------------------------------------------

----➤ ➤  Returns error upon failure ----
SELECT PARSE('99' AS INT),
	PARSE('ABC' AS INT) AS Result;



------------------------------------------------------------------------------
------------------------------------------------------------------------------
---------- TRY_CONVERT() ----------
------------------------------------------------------------------------------
------------------------------------------------------------------------------
SELECT TRY_CONVERT(INT, '99'),
	TRY_CONVERT(INT, 'ABC'),
	TRY_CONVERT(XML, '<root><child/></root>') AS Result;

---- Replacing NULL with specific value ----
SELECT 
	CASE 
		WHEN TRY_CONVERT(INT, '99') IS NULL
		THEN 'Conversion Failed'
		ELSE 'Conversion Successful'
	END AS Result1,
--
	CASE 
		WHEN TRY_CONVERT(INT, 'ABC') IS NULL
		THEN 'Conversion Failed'
		ELSE 'Conversion Successful'
	END AS Result2;

----  ----
SELECT 
	IIF(TRY_CONVERT(INT, '99') IS NULL,
		'Conversion Failed',
		'Conversion Successful'
		) AS Result1,
	IIF(TRY_CONVERT(INT, 'ABC') IS NULL,
		'Conversion Failed',
		'Conversion Successful'
		) AS Result2;

------------------------------------------------------------------------------
---------- CONVERT() ----------
------------------------------------------------------------------------------

----➤ ➤  Returns error upon failure ----
SELECT CONVERT(INT, '99'),
	CONVERT(INT, 'ABC') AS Result;




------------------------------------------------------------------------------
------------------------------------------------------------------------------
---------- EOMONTH() ----------
------------------------------------------------------------------------------
------------------------------------------------------------------------------
SELECT EOMONTH('02/02/2015'), -- leap year
	EOMONTH('02/02/2016'),
	EOMONTH('11/20/2015'),
	EOMONTH('08/20/2015', 4),
	EOMONTH('11/20/2015', 4),
	EOMONTH('11/20/2015', -1) AS Result;

----  ----
SELECT name, dob, EOMONTH(dob) AS LastDay, DATEPART(DD, EOMONTH(dob)), MONTH(EOMONTH(dob))
FROM [tblEmployees];



------------------------------------------------------------------------------
------------------------------------------------------------------------------
---- DATEFROMPARTS(), DATETIMEFROMPARTS(), SMALLDATETIMEFROMPARTS(), DATETIME2FROMPARTS(), TIMEFROMPARTS(), DATALENGTH() ----
------------------------------------------------------------------------------
------------------------------------------------------------------------------
SELECT DATEFROMPARTS(2015, 02, 01);
SELECT DATEFROMPARTS(2015, 22, 01);
SELECT DATEFROMPARTS(1899, 01, 01);
SELECT DATEFROMPARTS(2080, 06, 06);

SELECT DATETIMEFROMPARTS(2015, 12, 01, 20, 12, 23, 343);
SELECT DATETIMEFROMPARTS(2015, NULL, 01, 25, 12, 23, 343);
SELECT DATETIMEFROMPARTS(2015, 12, 01, 25, 12, 23, 343);

SELECT SMALLDATETIMEFROMPARTS(2015, 12, 01, 20, 12);
SELECT SMALLDATETIMEFROMPARTS(2015, NULL, 01, 20, 12);
SELECT SMALLDATETIMEFROMPARTS(2015, 12, 01, 25, 12);


SELECT DATETIME2FROMPARTS(2015, 12, 01, 20, 12, 23, 0, 0);
SELECT DATETIME2FROMPARTS(2015, 12, 01, 20, 12, 23, 5, 0);
SELECT DATETIME2FROMPARTS(2015, 12, 01, 20, 12, 23, 5, 3);
SELECT DATETIME2FROMPARTS(2015, 12, 01, 20, 12, 23, 5, 7);
SELECT DATETIME2FROMPARTS(2015, 12, 01, 20, 12, 23, 5, 6);
SELECT DATETIME2FROMPARTS(2015, NULL, 01, 20, 12, 23, 0, 0);


SELECT TIMEFROMPARTS(20, 12, 23, 0, 0);
SELECT TIMEFROMPARTS(20, 12, 23, 5, 0);
SELECT TIMEFROMPARTS(20, 12, 23, 5, 3);
SELECT TIMEFROMPARTS(20, 12, 23, 5, 7);
SELECT TIMEFROMPARTS(20, 12, 23, 5, 6);
SELECT TIMEFROMPARTS(20, NULL, 23, 0, 0);


SELECT DATALENGTH(DATETIME2FROMPARTS(2015, 12, 01, 20, 12, 23, 5, 7));
SELECT DATALENGTH(DATETIME2FROMPARTS(2015, 12, 01, 20, 12, 23, 5, 3));
SELECT DATALENGTH(DATETIME2FROMPARTS(2015, 12, 01, 20, 12, 23, 5, 1));
SELECT DATALENGTH(DATETIMEFROMPARTS(2015, 12, 01, 20, 12, 23, 345));
SELECT DATALENGTH(TIMEFROMPARTS(20, 12, 23, 5, 7));



------------------------------------------------------------------------------
------------------------------------------------------------------------------
---- OFFSET, FETCH () ----
------------------------------------------------------------------------------
------------------------------------------------------------------------------
USE [db1];

DROP TABLE [tblSales2];

CREATE TABLE [tblSales2]
(
id INT IDENTITY(1,1) PRIMARY KEY,
agent NVARCHAR(20),
country NVARCHAR(20),
amt INT
);

INSERT INTO [tblSales2] VALUES
('Tom', 'UK', 200),
('John', 'US', 180),
('John', 'UK', 260),
('David', 'India', 450),
('Tom', 'India', 350),
('David', 'US', 200),
('John', 'India', 540),
('John', 'UK', 120),
('David', 'UK', 220),
('John', 'UK', 420),
('David', 'US', 320),
('Tom', 'UK', 660),
('John', 'India', 430),
('David', 'India', 230),
('David', 'India', 280),
('Tom', 'UK', 480),
('John', 'US', 360),
('David', 'UK', 140);

SELECT * FROM [tblSales2];


----  ----
SELECT * 
FROM [tblSales2]
ORDER BY id
OFFSET 2 ROWS
FETCH NEXT 10 ROWS ONLY;
-- OR
SELECT * 
FROM [tblSales2]
ORDER BY id
OFFSET 2 ROWS
FETCH FIRST 10 ROW ONLY;


---- CREATE Stored Procedure For Implementing 'PAGING' Feature ----

DROP PROC spGetRowsByPageNumAndPageSize;

CREATE PROC spGetRowsByPageNumAndPageSize
@PageNum INT,
@PageSize INT
AS
BEGIN
	SELECT * FROM [tblSales2]
	ORDER BY id
	OFFSET (@PageNum -1) * @PageSize ROWS
	FETCH NEXT @PageSize ROWS ONLY
END

----  ----
EXEC spGetRowsByPageNumAndPageSize 5, 3;
EXEC spGetRowsByPageNumAndPageSize 2, 5;
EXEC spGetRowsByPageNumAndPageSize 10, 1;
EXEC spGetRowsByPageNumAndPageSize 5, 0;




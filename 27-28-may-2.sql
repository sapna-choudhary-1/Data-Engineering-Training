USE [company];

------------------------------------------------------------------------------
---- STRING in-built functions ----
------------------------------------------------------------------------------

SELECT ASCII('a');
SELECT ASCII('ABC');
SELECT ASCII('0');

----
SELECT CHAR(65);
---- Printing all eng alphabets ----
DECLARE @Start INT
SET @Start = 65
WHILE (@Start <= 90)
BEGIN
	PRINT CHAR(@Start)
	SET @Start = @Start + 1
END;

DECLARE @Start INT
SET @Start = 48
WHILE (@Start <= 57)
BEGIN
	PRINT CHAR(@Start)
	SET @Start = @Start + 1
END;

----
SELECT LTRIM('     Hello            ');
SELECT RTRIM('     Hello            ');
SELECT RTRIM(LTRIM('     Hello            '));

----
SELECT UPPER('Hello There');
SELECT LOWER('Hello There');

SELECT REVERSE('Hello There');

SELECT LEN('Hello There');
SELECT LEN('  Hello There  ');

SELECT LEFT('Hello There', 7);
SELECT RIGHT('Hello There', 7);

----
DELETE FROM [tblMail];
DROP TABLE [tblMail];

CREATE TABLE [tblMail]
(
id INT,
f_name VARCHAR(20),
l_name VARCHAR(20),
email VARCHAR(20),
registered_date DATETIME
);

INSERT INTO [tblMail] VALUES
(1, 'Sam', 'Sony', 'sam@aaa.com', '2012-08-24 11:04:30.230'),
(2, 'Ram', 'Bray', 'ram@aaa.com', '2012-08-25 14:04:29.780'),
(3, 'Sara', 'Sonosky', 'sara@ccc.com', '2012-08-25 15:04:29.780'),
(4, 'Todd', 'Gartner', 'todd@bbb.com', '2012-08-24 15:04:30.730'),
(5, 'John', 'Grover', 'john@aaa.com', '2012-08-24 15:05:30.330'),
(6, 'Sana', 'Lenin', 'sana@ccc.com', '2011-08-26 16:05:30.330'),
(7, 'James', 'Bond', 'james@bbb.com', '2012-08-26 12:06:30.430'),
(8, 'Rob', 'Wilson', 'rob@ccc.com', '2010-08-24 04:01:30.555');

----
SELECT f_name + SPACE(5) + l_name AS full_name
FROM [tblMail];

SELECT REPLICATE('Hello There ', 3);

SELECT f_name,
		SUBSTRING(email, 1, 2) + REPLICATE('*', 5) + 
		SUBSTRING(email, CHARINDEX('@', email), LEN(email) - CHARINDEX('@', email)+1 ) AS email
FROM [tblMail];

----
SELECT CHARINDEX('@', 'abc@def@g.com');
SELECT CHARINDEX('@', 'abc@def@g.com', 5);
SELECT CHARINDEX('!', 'abc@def@g.com');

SELECT SUBSTRING('abc@def@g.com', CHARINDEX('@', 'abc@def@g.com') );
SELECT SUBSTRING('abc@def@g.com', CHARINDEX('@', 'abc@def@g.com')+1 );
SELECT SUBSTRING('abc@def@g.com', CHARINDEX('@', 'abc@def@g.com')+1, 7 );

SELECT email, PATINDEX('%a.com', email)
FROM [tblMail]
WHERE PATINDEX('%a.com', email) > 0;

SELECT email, REPLACE(email, '.com', '.net') AS ConvertedEmail
FROM [tblMail];

SELECT email, STUFF(email, 2, 3, '*****' ) AS ConvertedEmail
FROM [tblMail];

SELECT email, STUFF(email, 2, LEN(email)-CHARINDEX('@', email), '*****' ) AS ConvertedEmail
FROM [tblMail];


----
SELECT f_name, SUBSTRING(email, CHARINDEX('@', email)+1, LEN(email) - CHARINDEX('@', email)+1 ) AS email_domain
FROM [tblMail];

SELECT COUNT(email) AS total
FROM [tblMail];

SELECT SUBSTRING(email, CHARINDEX('@', email)+1, LEN(email) - CHARINDEX('@', email)+1 ) AS email_domain, COUNT(email) AS total
FROM [tblMail]; -- ❌ Will fail with 'Column 'tblMail.email' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause'

SELECT SUBSTRING(email, CHARINDEX('@', email)+1, LEN(email) - CHARINDEX('@', email)+1 ) AS email_domain, COUNT(email) AS total
FROM [tblMail]
GROUP BY SUBSTRING(email, CHARINDEX('@', email)+1, LEN(email) - CHARINDEX('@', email)+1);


------------------------------------------------------------------------------
---- DATETIME in-built functions ----
------------------------------------------------------------------------------

CREATE TABLE [tblDateTime]
(
 [c_time] [time](7) NULL,
 [c_date] [date] NULL,
 [c_smalldatetime] [smalldatetime] NULL,
 [c_datetime] [datetime] NULL,
 [c_datetime2] [datetime2](7) NULL,
 [c_datetimeoffset] [datetimeoffset](7) NULL
);

INSERT INTO tblDateTime VALUES 
(GETDATE(),GETDATE(),GETDATE(),GETDATE(),GETDATE(),GETDATE()),
(CURRENT_TIMESTAMP,GETUTCDATE(),GETDATE(),SYSDATETIME(),SYSUTCDATETIME(),SYSDATETIMEOFFSET());

DELETE FROM [tblDateTime];

SELECT * FROM [tblDateTime];

SELECT GETDATE() AS 'GETDATE()', 
	CURRENT_TIMESTAMP AS 'CURRENT_TIMESTAMP',
	GETUTCDATE() AS 'GETUTCDATE',
	SYSDATETIME() AS 'SYSDATETIME',
	SYSUTCDATETIME() AS 'SYSUTCDATETIME',
	SYSDATETIMEOFFSET() AS 'SYSDATETIMEOFFSET';

-----
SELECT ISDATE('Hello'),
	ISDATE(GETDATE()),
	ISDATE(CURRENT_TIMESTAMP),
	ISDATE('2025-05-28 13:36:42.540'),
	ISDATE('2025-05-28 13:36:42.543 +0530'),
	ISDATE('2025-05-28 13:36:42.5405678'),
--	ISDATE(time),
	ISDATE(c_smalldatetime),
	ISDATE(c_datetime)
--	ISDATE(c_datetime2),
--	ISDATE(c_datetimeoffset)
FROM [tblDateTime];


----
SELECT DAY(GETDATE()), 
	MONTH(GETDATE()), 
	YEAR(GETDATE()),
	YEAR('01/31/2024');

SELECT DATENAME(DAY, GETDATE()),
	DATENAME(WEEKDAY, GETDATE()),
	DATENAME(MONTH, GETDATE()),
	DATENAME(QUARTER, GETDATE()),
	DATENAME(DAYOFYEAR, GETDATE()),
	DATENAME(MINUTE, GETDATE()),
	DATENAME(MILLISECOND, GETDATE()),
	DATENAME(ms, GETDATE()),
	DATENAME(MICROSECOND, GETDATE()),
	DATENAME(NANOSECOND, GETDATE());

SELECT DATEPART(DAY, GETDATE()),
	DATEPART(WEEKDAY, GETDATE()),
	DATEPART(MONTH, GETDATE()),
	DATEPART(QUARTER, GETDATE()),
	DATEPART(DAYOFYEAR, GETDATE()),
	DATEPART(MINUTE, GETDATE()),
	DATEPART(MILLISECOND, GETDATE()),
	DATEPART(ms, GETDATE()),
	DATEPART(MICROSECOND, GETDATE()),
	DATEPART(NANOSECOND, GETDATE());

SELECT GETDATE(), 
	DATEADD(DAY, 20, GETDATE()),
	DATEADD(DAY, -20, GETDATE()),
	DATEADD(MONTH, 10, GETDATE()),
	DATEADD(QUARTER, 1, GETDATE()),
	DATEADD(DAY, 100, GETDATE()),
	DATEADD(DAYOFYEAR, 100, GETDATE());

SELECT GETDATE(), 
	DATEDIFF(DAY, GETDATE(), '12/01/2024'),
	DATEDIFF(DAY, '12/01/2024', GETDATE()),
	DATEDIFF(DAY, '12/01/2024', GETDATE()),
	DATEDIFF(MONTH, '12/01/2024', GETDATE()),
	DATEDIFF(YEAR, '12/01/2024', GETDATE()),
	DATEDIFF(WEEK, '12/01/2024', GETDATE());


------------------------------------------------------------------------------
---- CAST & CONVERT functions ----
------------------------------------------------------------------------------

SELECT GETDATE(),
	CAST(GETDATE() AS NVARCHAR (10)),
	CAST(GETDATE() AS VARCHAR (10)),
	CAST(GETDATE() AS NVARCHAR (5)),
	CAST(GETDATE() AS NVARCHAR (20)),
	CAST(GETDATE() AS DATE),
	CONVERT(NVARCHAR, GETDATE()),
	CONVERT(NVARCHAR, GETDATE(), 102),
	CONVERT(NVARCHAR, GETDATE(), 105),
	CONVERT(NVARCHAR, GETDATE(), 101),
	CONVERT(DATE, GETDATE());

SELECT id, name, name + '-' + id AS [Name-Id]
FROM [empls]; -- ❌ Will fail with 'Conversion failed when converting the nvarchar value 'Tom_' to data type int'

SELECT id, name, name + '-' + CAST(id AS NVARCHAR) AS [Name-Id]
FROM [empls];

------- group by the date part from the registered_date column, with count -------
SELECT CONVERT(NVARCHAR, registered_date, 105) AS registered_date, COUNT(id)
FROM [tblMail]
GROUP BY CONVERT(NVARCHAR, registered_date, 105)
ORDER BY COUNT(id) DESC;

SELECT CAST(registered_date AS DATE), COUNT(id)
FROM [tblMail]
GROUP BY CONVERT(DATE, registered_date)
ORDER BY COUNT(id) DESC;

------------------------------------------------------------------------------
---- MATHEMATICAL in-built functions ----
------------------------------------------------------------------------------

SELECT -16.5, ABS(-16.5);

SELECT -16.4, CEILING(-16.4), 16.4, CEILING(16.4);
SELECT -16.6, FLOOR(-16.6), 16.6, FLOOR(16.6);

SELECT POWER(3, 2), SQUARE(3), SQRT(9);

-----
SELECT RAND(), RAND(1), RAND(0), RAND(-5);
SELECT RAND()*100, FLOOR(RAND()*100);

---- Printing 10 random no.s between 1-1000 ----
DECLARE @Cntr INT
SET @Cntr = 1
WHILE(@Cntr <= 10)
BEGIN
	PRINT FLOOR(RAND() * 1000)
	SET @Cntr = @Cntr + 1
END;

----
SELECT ROUND(843.5742326, -1, 0),
	ROUND(846.5742326, -1, 0),
	ROUND(843.4742326, -0, 0),
	ROUND(843.5742326, -2, 0),
	ROUND(843.5742326, -1, 1),
	ROUND(843.5742326, 2, 0);

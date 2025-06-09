USE [company];
10.13
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


------------------------------------------------------------------------------
---- SCALAR user-defined functions ----
------------------------------------------------------------------------------

CREATE FUNCTION calc_age (@dob DATE)
RETURNS INT
AS
BEGIN
--	...
--	RETURN
--  or --
--  RETURN (SELECT col_name FROM tblMail WHERE id = @id)
END

SELECT dbo.calc_age('16/11/2001')

sp_helptext calc_age

ALTER FUNCTION calc_age (@dob DATE)
RETURNS INT
WITH ENCRYPTION
AS
BEGIN
--	...
--	RETURN
--  or --
--  RETURN (SELECT col_name FROM tblMail WHERE id = @id)
END

------------------------------------------------------------------------------
---- INLINE TABLE-VALUED user-defined functions ----
------------------------------------------------------------------------------

CREATE FUNCTION tbl_fn (@gender VARCHAR(10))
RETURNS TABLE
AS
RETURN (
		SELECT id, gender
		FROM [tblMail]
		WHERE gender = @gender
	)
	
SELECT * FROM tbl_fn(gender)
	

------------------------------------------------------------------------------
---- MULTI-STATEMENT TABLE-VALUED user-defined functions ----
------------------------------------------------------------------------------

CREATE FUNCTION tbl_fn2 (@gender VARCHAR(10))
RETURNS @table TABLE (id INT, name NVARCHAR(20))
AS
BEGIN
	INSERT INTO @table
	SELECT id, name
	FROM [tblMail]
	
	RETURN
END

	
SELECT * FROM tbl_fn(gender)












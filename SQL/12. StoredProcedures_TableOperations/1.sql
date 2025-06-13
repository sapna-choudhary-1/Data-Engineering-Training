
------------------------------------------------------------------------------
---- STORED PROCEDURES ----
------------------------------------------------------------------------------
USE [db1]

DROP TABLE [tblEmpls]

CREATE TABLE [tblEmpls] (
	id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(50),
    gender NVARCHAR(10),
    dept_id INT
)

INSERT INTO [tblEmpls] VALUES
('John', 'Male', 3),
('Mike', 'Male', 2),
('Pam', 'Female', 1),
('Todd', 'Male', 4),
('Sarah', 'Female', 1),
('Brianna', 'Female', 3),
('Brian', 'Male', 2)

SELECT * FROM [tblEmpls]

------------------------------------------------------------------------------
---------- Create ----------
------------------------------------------------------------------------------
DROP PROCEDURE [spEmplByGenderAndDept]

CREATE PROCEDURE [spEmplByGenderAndDept]
@gender NVARCHAR(10)
AS
BEGIN
	SELECT *
	FROM [tblEmpls]
	WHERE gender = @gender
END

---- Execute ----
[spEmplByGenderAndDept] 'Female'
EXECUTE [spEmplByGenderAndDept] 'Female'
EXEC [spEmplByGenderAndDept] 'Female'

---- Alter ----
ALTER PROCEDURE [spEmplByGenderAndDept]
@gender NVARCHAR(10), @deptId INT
AS
BEGIN
	SELECT *
	FROM [tblEmpls]
	WHERE gender = @gender AND dept_id = @deptId
END


EXEC [spEmplByGenderAndDept] 'Female', 3;

---------- ❌ Will give error 'Error converting data type varchar to int.' ❌ ----------
EXEC [spEmplByGenderAndDept] 3, 'Female';

---------- ✅ Specify var_names ✅ ----------
EXEC [spEmplByGenderAndDept] @deptId = 3, @gender = 'Female';



------------------------------------------------------------------------------
---- View Text ----
sp_helptext [spEmplByGenderAndDept];

---- Encrypt Text of the sp ----
ALTER PROCEDURE [spEmplByGenderAndDept]
@gender NVARCHAR(10),
@deptId INT
WITH ENCRYPTION
AS
BEGIN
	SELECT *
	FROM [tblEmpls]
	WHERE gender = @gender AND dept_id = @deptId
END

----------❗Can't view the text anymore❗----------
sp_helptext [spEmplByGenderAndDept];

---- To View Information of the sp ----
sp_help [spEmplByGenderAndDept];

---- To View Dependencies of the sp ----
sp_depends [spEmplByGenderAndDept];


------------------------------------------------------------------------------
---- Output Parameters ----
------------------------------------------------------------------------------
DROP PROCEDURE [spEmplCntByGender];

CREATE PROCEDURE [spEmplCntByGender]
@gender NVARCHAR(10),
@emplCnt INT OUTPUT
WITH ENCRYPTION
AS
BEGIN
    SELECT @emplCnt = COUNT(id) FROM [tblEmpls]
    WHERE gender = @gender
END

sp_help [spEmplCntByGender]

----  ----
DECLARE @cnt INT
EXEC [spEmplCntByGender] 'Female', @cnt OUTPUT
PRINT @cnt

-- No Output (since stores null)
DECLARE @cnt INT
--EXEC [spEmplCntByGender] 'Female', @cnt
SET @cnt = NULL
IF(@cnt IS NULL)
	PRINT '@cnt is Null'
ELSE
	PRINT '@cnt is ' + @cnt;
---- ----


------------------------------------------------------------------------------
---- RETURN VALUE ----
------------------------------------------------------------------------------
DROP PROCEDURE [spEmplCntByGender2]

CREATE PROCEDURE [spEmplCntByGender2]
@gender NVARCHAR(10)
WITH ENCRYPTION
AS
BEGIN
    RETURN (
    	SELECT COUNT(id) FROM [tblEmpls]
	    WHERE gender = @gender
	)
END

sp_help [spEmplCntByGender2]

----  ----
DECLARE @cnt INT
EXEC @cnt = [spEmplCntByGender2] 'Male'
PRINT @cnt



---- Error if returned value with dt other than Int ----
DROP PROCEDURE [spEmplCntByGender3]

CREATE PROCEDURE [spEmplCntByGender3]
@id INT
WITH ENCRYPTION
AS
BEGIN
    RETURN (
    	SELECT name FROM [tblEmpls]
	    WHERE id = @id
	)
END

sp_help [spEmplCntByGender3]

---- ❌ ERROR: Conversion failed when converting the nvarchar value 'John' to data type int ❌ ----
EXEC [spEmplCntByGender3] 1


------------------------------------------------------------------------------
---- OPTIONAL PARAMETERS ----
------------------------------------------------------------------------------
DROP PROC [spSearchEmployees]

CREATE PROC [spSearchEmployees]
@name NVARCHAR(50) = NULL,
@gender NVARCHAR(50) = 'Male'
AS
BEGIN
	SELECT *
	FROM [tblEmpls]
	WHERE (name = @name OR @name IS NULL) AND (gender = @gender)
END

EXEC [spSearchEmployees];
EXEC [spSearchEmployees] @gender = 'Female';
EXEC [spSearchEmployees] @name = 'Brian';
---- No Result: Since default gender=Male:- clashing condition in WHERE clause ----
EXEC [spSearchEmployees] @name = 'Brianna';




------------------------------------------------------------------------------
------------------------------------------------------------------------------
---- TABLE VALUED PARAMETERS In Stored Procedures ----
------------------------------------------------------------------------------
------------------------------------------------------------------------------
USE [db1]

---------- Create empty table ----------
DROP TABLE [tblTest3];

CREATE TABLE [tblTest3] (
	id INT,
    name NVARCHAR(50),
    gender_id INT
);

SELECT * FROM [tblTest3]

---------- Create user-defined table Type ----------
CREATE TYPE TypeName AS TABLE 
(
	id INT,
    name NVARCHAR(50),
    gender_id INT
);

---------- Create the stored procedure ----------
CREATE PROC spTypeName
@spVar TypeName READONLY
AS
BEGIN
	INSERT INTO [tblTest3]
	SELECT * FROM @spVar
END

---------- Declare a table variable -> insert data rows into it -> pass it as a parameter to the stored procedure ----------
DECLARE @tblVar TypeName
INSERT INTO @tblVar VALUES
(1, 'A', 1),
(2, 'B', 2),
(3, 'C', 1),
(4, 'D', 2)
----------  ----------
EXEC spTypeName @tblVar;

---------- Check the results ----------
SELECT * FROM [tblTest3]



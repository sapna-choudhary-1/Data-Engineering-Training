
------------------------------------------------------------------------------
---- SEQUENCE OBJECT ----
------------------------------------------------------------------------------
USE [db1];

DROP TABLE [tblTmp1];
DROP TABLE [tblTmp2];

CREATE TABLE [tblTmp1] (identityId INT IDENTITY(1,1), seqId INT);
CREATE TABLE [tblTmp2] (identityId INT IDENTITY(1,1), seqId INT);

SELECT * FROM [tblTmp1];
SELECT * FROM [tblTmp2];

------------------------------------------------------------------------------
---- Create Object ----
CREATE SEQUENCE seqObj
AS INT
START WITH 1
INCREMENT BY 1;

------------------------------------------------------------------------------
---- Drop Object ----
DROP SEQUENCE seqObj;

------------------------------------------------------------------------------
---- Fetch current val of Object ----
SELECT current_value FROM sys.sequences
WHERE name = 'seqObj';

------------------------------------------------------------------------------
---- Increment obj value ----
SELECT NEXT VALUE FOR seqObj;

------------------------------------------------------------------------------
---- Reset Object ----
ALTER SEQUENCE seqObj RESTART WITH 1;

------------------------------------------------------------------------------
---- Using sequence object to add values to tblTmp1, tblTmp2 ----
INSERT INTO [tblTmp1] VALUES
(NEXT VALUE FOR seqObj),
(NEXT VALUE FOR seqObj),
(NEXT VALUE FOR seqObj),
(NEXT VALUE FOR seqObj);

INSERT INTO [tblTmp2] VALUES
(NEXT VALUE FOR seqObj),
(NEXT VALUE FOR seqObj);


SELECT * FROM [tblTmp1];
SELECT * FROM [tblTmp2];

------------------------------------------------------------------------------
---- Create Sequence Object with CYCLE option ----
------------------------------------------------------------------------------
CREATE SEQUENCE seqObj2
AS INT
START WITH 1
INCREMENT BY 1
MINVALUE 1
MAXVALUE 3
CYCLE;

---- Drop Object ----
DROP SEQUENCE seqObj2;

---- Fetch current val of Object ----
SELECT current_value FROM sys.sequences
WHERE name = 'seqObj2';

---- Increment obj value: chk the value after 3 ----
SELECT NEXT VALUE FOR seqObj2;


------------------------------------------------------------------------------
---- GUID DataType----
------------------------------------------------------------------------------

---- Create GUID----
DECLARE @Id1 UNIQUEIDENTIFIER
SET @Id1 = NEWID()
SELECT @Id1
PRINT @Id1

------------------------------------------------------------------------------
---- EMPTY GUID ----
SELECT CAST('00000000-0000-0000-0000-000000000000' AS UNIQUEIDENTIFIER);
SELECT CAST( CAST(0 AS BINARY) AS UNIQUEIDENTIFIER);
SELECT CAST(0x0 AS UNIQUEIDENTIFIER);


------------------------------------------------------------------------------
---- IF GUID IS NULL----
DECLARE @Id UNIQUEIDENTIFIER;
SET @Id = NULL;

IF (@Id IS NULL)
	BEGIN
		PRINT 'GUID was NULL'
		SET @Id = NEWID()
	END
ELSE
	BEGIN
		PRINT 'GUID is NOT NULL'
	END;

-- OR

DECLARE @Id2 UNIQUEIDENTIFIER;
SELECT ISNULL(@Id2, NEWID());


------------------------------------------------------------------------------
---- IDENTITY() VS GUID ----
------------------------------------------------------------------------------
USE [db1];

DROP TABLE [tblTmp1];
DROP TABLE [tblTmp2];
DROP TABLE [company].[dbo].[tblTmp3];

CREATE TABLE [tblTmp1] (
	id INT IDENTITY(1,1) PRIMARY KEY, 
	name NVARCHAR(10)
);
CREATE TABLE [tblTmp2] (
	id INT IDENTITY(1,1) PRIMARY KEY, 
	name NVARCHAR(10)
);
---- Using different db ----
CREATE TABLE [company].[dbo].[tblTmp3] (
	id INT IDENTITY(1,1) PRIMARY KEY, 
	name NVARCHAR(10)
);


INSERT INTO [tblTmp1] VALUES
('Mike'), ('John');
INSERT INTO [tblTmp2] VALUES
('Anna'), ('Sarah');
INSERT INTO [company].[dbo].[tblTmp3] VALUES
('Bruno'), ('Briana');


---- Same Ids for Id column in all the tables ----
SELECT * FROM [tblTmp1];
SELECT * FROM [tblTmp2];
SELECT * FROM [company].[dbo].[tblTmp3];

---- Trying to insert values into new table, with union ----
-- ❌ Will give error with 'Violation of PRIMARY KEY constraint 'PK__tblNew__3213E83FBFA55BF8'. Cannot insert duplicate key in object 'dbo.tblNew'. The duplicate key value is (1).''
DROP TABLE [tblNew]

CREATE TABLE [tblNew]
(
	id INT PRIMARY KEY,
	name NVARCHAR(20)
);


INSERT INTO [tblNew]
SELECT * FROM [tblTmp1]
UNION
SELECT * FROM [tblTmp2]
UNION
SELECT * FROM [company].[dbo].[tblTmp3];


------------------------------------------------------------------------------
---- If Used GUID ----
------------------------------------------------------------------------------

DROP TABLE [tblTmp1];
DROP TABLE [tblTmp2];
DROP TABLE [company].[dbo].[tblTmp3];

CREATE TABLE [tblTmp1] (
	id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	name NVARCHAR(10)
);
CREATE TABLE [tblTmp2] (
	id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	name NVARCHAR(10)
);
---- Using different db ----
CREATE TABLE [company].[dbo].[tblTmp3] (
	id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	name NVARCHAR(10)
);


INSERT INTO [tblTmp1] VALUES
(DEFAULT, 'Mike'), 
(DEFAULT, 'John');

INSERT INTO [tblTmp2] VALUES
(DEFAULT, 'Anna'), 
(DEFAULT, 'Sarah');

INSERT INTO [company].[dbo].[tblTmp3] VALUES
(DEFAULT, 'Bruno'), 
(DEFAULT, 'Briana');


---- Same Ids for Id column in all the tables ----
SELECT * FROM [tblTmp1];
SELECT * FROM [tblTmp2];
SELECT * FROM [company].[dbo].[tblTmp3];

---- Trying to insert values into new table, with union ----
-- ✅ Worked
DROP TABLE [tblNew]

CREATE TABLE [tblNew]
(
	id UNIQUEIDENTIFIER PRIMARY KEY,
	name NVARCHAR(20)
);

INSERT INTO [tblNew]
SELECT * FROM [tblTmp1]
UNION
SELECT * FROM [tblTmp2]
UNION
SELECT * FROM [company].[dbo].[tblTmp3];

SELECT * FROM [tblNew];








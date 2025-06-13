
------------------------------------------------------------------------------
---- TRANSACTIONS ----
------------------------------------------------------------------------------
USE [db1];

DROP TABLE [tblMailingAddress];
DROP TABLE [tblPhysicalAddress];

CREATE TABLE tblMailingAddress 
(AddressId INT NOT NULL PRIMARY KEY, EmployeeNumber INT, HouseNumber NVARCHAR(50), StreetAddress NVARCHAR(50), City NVARCHAR(10), PostalCode NVARCHAR(50));

INSERT INTO tblMailingAddress
VALUES (1, 101, '#10', 'King Street', 'Londoon', 'CR27DW');

CREATE TABLE tblPhysicalAddress 
(AddressId INT NOT NULL PRIMARY KEY, EmployeeNumber INT, HouseNumber NVARCHAR(50), StreetAddress NVARCHAR(50), City NVARCHAR(10), PostalCode NVARCHAR(50));

INSERT INTO tblPhysicalAddress
VALUES (1, 101, '#10', 'King Street', 'Londoon', 'CR27DW');

SELECT * FROM [tblMailingAddress];
SELECT * FROM [tblPhysicalAddress];

------------------------------------------------------------------------------
---- CORRECT CODE ----
DROP PROCEDURE [spUpdateAddress];

CREATE PROCEDURE spUpdateAddress
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
		
		PRINT 'In transaction'

		UPDATE tblMailingAddress
		SET City = 'LONDON'
		WHERE AddressId = 1 AND EmployeeNumber = 101

		UPDATE tblPhysicalAddress
		SET City = 'LONDON'
		WHERE AddressId = 1 AND EmployeeNumber = 101

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		PRINT 'In commit'
		ROLLBACK TRANSACTION
	END CATCH
END

EXEC [spUpdateAddress];
SELECT * FROM [tblMailingAddress];
SELECT * FROM [tblPhysicalAddress];


------------------------------------------------------------------------------
---- WHEN UPDATING WITH FAILING CODE: No change received ----
ALTER PROCEDURE spUpdateAddress
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
		
		PRINT 'In transaction'

		UPDATE tblMailingAddress
		SET City = 'LONDON2'
		WHERE AddressId = 1 AND EmployeeNumber = 101

		UPDATE tblPhysicalAddress
--		make the length of val getting updated in city >10 characters
		SET City = 'LONDON LONDON'
		WHERE AddressId = 1 AND EmployeeNumber = 101

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		PRINT 'In commit'
		ROLLBACK TRANSACTION
	END CATCH
END

EXEC [spUpdateAddress];
SELECT * FROM [tblMailingAddress];
SELECT * FROM [tblPhysicalAddress];








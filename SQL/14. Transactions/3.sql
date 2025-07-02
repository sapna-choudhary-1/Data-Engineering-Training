
------------------------------------------------------------------------------
---- TRANSACTION 1 ----
------------------------------------------------------------------------------
USE [db1];

DROP TABLE [tblInventory];

CREATE TABLE tblInventory 
(
	id INT,
	product NVARCHAR(20),
	stock INT
);

INSERT INTO tblInventory
VALUES (1, 'phone', 10);

SELECT * FROM [tblInventory];


------------------------------------------------------------------------------
---- DIRTY READ ----
------------------------------------------------------------------------------

UPDATE tblInventory SET stock = 10
WHERE id = 1;

SELECT * FROM tblInventory;

BEGIN TRANSACTION
	UPDATE tblInventory SET stock = 9
	WHERE id = 1
	SELECT *, '1-1' FROM tblInventory
	
	WAITFOR DELAY '00:00:05'
	PRINT 'End after 5 seconds'
	SELECT *, '1-2' FROM tblInventory
	ROLLBACK TRAN


------------------------------------------------------------------------------
---- LOST UPDATES ----
------------------------------------------------------------------------------
UPDATE tblInventory SET stock = 10 WHERE id = 1;
SELECT * FROM tblInventory;


DECLARE @initialStock INT;
--SELECT @initialStock = stock FROM tblInventory WHERE id = 1;
BEGIN TRAN;
	SELECT @initialStock = stock FROM tblInventory WHERE id = 1;
	SELECT *, '1-1' FROM tblInventory (NOLOCK) WHERE id = 1;
	
	WAITFOR DELAY '00:00:10'
--	UPDATE tblInventory SET stock = stock-1 WHERE id = 1;
	UPDATE tblInventory SET stock = @initialStock - 1 WHERE id = 1;
	
	SELECT *, '1-2' FROM tblInventory (NOLOCK) WHERE id = 1;
COMMIT TRAN;







	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
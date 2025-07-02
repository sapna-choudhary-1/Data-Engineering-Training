
------------------------------------------------------------------------------
---- TRANSACTION 2 ----
------------------------------------------------------------------------------

USE [db1];

SELECT * FROM [tblInventory];


------------------------------------------------------------------------------
---- Allow DIRTY READ ----
------------------------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SELECT *, '2-1' FROM tblInventory WHERE id = 1;

-- OR

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SELECT * FROM tblInventory (NOLOCK);


------------------------------------------------------------------------------
---- Allow LOST UPDATES ----
------------------------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN;
	SELECT *, '2-1' FROM tblInventory (NOLOCK) WHERE id = 1;
	
	UPDATE tblInventory SET stock = 5 WHERE id = 1;
	
	SELECT *, '2-2' FROM tblInventory (NOLOCK) WHERE id = 1;
COMMIT TRAN;



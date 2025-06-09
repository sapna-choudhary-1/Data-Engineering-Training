
------------------------------------------------------------------------------
---- ERROR HANDLING ----
------------------------------------------------------------------------------
USE [db1];

DROP TABLE [tblProduct];
DROP TABLE [tblProductSales];

CREATE TABLE [tblProduct] (
	ProductId INT NOT NULL PRIMARY KEY,
	Name NVARCHAR(50),
	UnitPrice INT,
	QtyAvailable INT
	);

INSERT INTO [tblProduct] VALUES 
(1,'Laptops',2340,100),
(2,'Desktops',3467,50);

CREATE TABLE [tblProductSales] (
	ProductSalesId INT PRIMARY KEY,
	ProductId INT,
	QuantitySold INT
	);

SELECT * FROM [tblProduct];
SELECT * FROM [tblProductSales];

------------------------------------------------------------------------------
---- @@ERROR ----
------------------------------------------------------------------------------
DROP PROCEDURE [spSellProduct];

CREATE PROCEDURE spSellProduct @ProductId INT, @QuantityToSell INT
AS
BEGIN
	-- Check the stock available, for the product we want to sell
	DECLARE @StockAvailable INT

	SELECT @StockAvailable = QtyAvailable
	FROM tblProduct
	WHERE ProductId = @ProductId

	-- Throw an error to the calling application, if enough stock is not available
	IF (@StockAvailable < @QuantityToSell)
	BEGIN
		RAISERROR ('Not enough stock available', 16, 1)
	END
			-- If enough stock available
	ELSE
	BEGIN
		BEGIN TRAN

		-- First reduce the quantity available
		UPDATE tblProduct
		SET QtyAvailable = (QtyAvailable - @QuantityToSell)
		WHERE ProductId = @ProductId

		DECLARE @MaxProductSalesId INT

		-- Calculate MAX ProductSalesId  
		SELECT @MaxProductSalesId = CASE 
				WHEN MAX(ProductSalesId) IS NULL
					THEN 0
				ELSE MAX(ProductSalesId)
				END
		FROM tblProductSales

		-- Increment @MaxProductSalesId by 1, so we don't get a primary key violation
		SET @MaxProductSalesId = @MaxProductSalesId + 1

		INSERT INTO tblProductSales
		VALUES (@MaxProductSalesId, @ProductId, @QuantityToSell)

		COMMIT TRAN
	END
END;

EXECUTE [spSellProduct] 1, 10;

SELECT * FROM [tblProduct];
SELECT * FROM [tblProductSales];

------------------------------------------------------------------------------
---- INCORRECT RESULT WHEN 'SET' OPERATION IS COMMENTED OUT ----
----❌ no entry was generated in tableProductSales, however qty was reduced from tblProduct ❌----

ALTER PROCEDURE spSellProduct @ProductId INT, @QuantityToSell INT
AS
BEGIN
	-- Check the stock available, for the product we want to sell
	DECLARE @StockAvailable INT

	SELECT @StockAvailable = QtyAvailable
	FROM tblProduct
	WHERE ProductId = @ProductId

	-- Throw an error to the calling application, if enough stock is not available
	IF (@StockAvailable < @QuantityToSell)
	BEGIN
		RAISERROR ('Not enough stock available', 16, 1)
	END
			-- If enough stock available
	ELSE
	BEGIN
		BEGIN TRAN

			-- First reduce the quantity available
			UPDATE tblProduct
			SET QtyAvailable = (QtyAvailable - @QuantityToSell)
			WHERE ProductId = @ProductId
	
			DECLARE @MaxProductSalesId INT
	
			-- Calculate MAX ProductSalesId  
			SELECT @MaxProductSalesId = CASE 
					WHEN MAX(ProductSalesId) IS NULL
						THEN 0
					ELSE MAX(ProductSalesId)
					END
			FROM tblProductSales
	
			-- Increment @MaxProductSalesId by 1, so we don't get a primary key violation
	--		SET @MaxProductSalesId = @MaxProductSalesId + 1
	
			INSERT INTO tblProductSales
			VALUES (@MaxProductSalesId, @ProductId, @QuantityToSell)

		COMMIT TRAN
	END
END;

EXECUTE [spSellProduct] 1, 10;

SELECT * FROM [tblProduct];
SELECT * FROM [tblProductSales];

------------------------------------------------------------------------------
---- CORRECT RESULT WHEN 'SET' OPERATION IS COMMENTED OUT ----
----✅ no entry was generated in tableProductSales, and qty not reduced from tblProduct ✅----

ALTER PROCEDURE spSellProduct @ProductId INT, @QuantityToSell INT
AS
BEGIN
	-- Check the stock available, for the product we want to sell
	DECLARE @StockAvailable INT

	SELECT @StockAvailable = QtyAvailable
	FROM tblProduct
	WHERE ProductId = @ProductId

	-- Throw an error to the calling application, if enough stock is not available
	IF (@StockAvailable < @QuantityToSell)
	BEGIN
		RAISERROR ('Not enough stock available', 16, 1)
	END
	-- If enough stock available
	ELSE
	BEGIN
		BEGIN TRAN
			-- First reduce the quantity available
			UPDATE tblProduct
			SET QtyAvailable = (QtyAvailable - @QuantityToSell)
			WHERE ProductId = @ProductId
	
			DECLARE @MaxProductSalesId INT
	
			-- Calculate MAX ProductSalesId  
			SELECT @MaxProductSalesId = CASE 
					WHEN MAX(ProductSalesId) IS NULL
						THEN 0
					ELSE MAX(ProductSalesId)
					END
			FROM tblProductSales
	
			-- Increment @MaxProductSalesId by 1, so we don't get a primary key violation
			--➤ Try commenting this line to see the impact
	--		SET @MaxProductSalesId = @MaxProductSalesId + 1
	
			INSERT INTO tblProductSales
			VALUES (@MaxProductSalesId, @ProductId, @QuantityToSell)
	
			IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN
					PRINT 'Rolled Back Transaction'
				END
			ELSE
				BEGIN
					COMMIT TRAN
					PRINT 'Committed Transaction'
				END
	END
END

EXECUTE [spSellProduct] 1, 10;

SELECT * FROM [tblProduct];
SELECT * FROM [tblProductSales];



------------------------------------------------------------------------------
---- TRY-CATCH ----
------------------------------------------------------------------------------

DROP PROCEDURE [spSellProduct2];

CREATE PROCEDURE [spSellProduct2] @ProductId INT, @QuantityToSell INT
AS
BEGIN
	-- Check the stock available, for the product we want to sell
	DECLARE @StockAvailable INT

	SELECT @StockAvailable = QtyAvailable
	FROM tblProduct
	WHERE ProductId = @ProductId

	-- Throw an error to the calling application, if enough stock is not available
	IF (@StockAvailable < @QuantityToSell)
	BEGIN
		RAISERROR ('Not enough stock available', 16, 1)
	END
			-- If enough stock available
	ELSE
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION

			-- First reduce the quantity available
			UPDATE tblProduct
			SET QtyAvailable = (QtyAvailable - @QuantityToSell)
			WHERE ProductId = @ProductId

			DECLARE @MaxProductSalesId INT

			-- Calculate MAX ProductSalesId  
			SELECT @MaxProductSalesId = CASE 
					WHEN MAX(ProductSalesId) IS NULL
						THEN 0
					ELSE MAX(ProductSalesId)
					END
			FROM tblProductSales

			--Increment @MaxProductSalesId by 1, so we don't get a primary key violation
			SET @MaxProductSalesId = @MaxProductSalesId + 1

			INSERT INTO tblProductSales
			VALUES (@MaxProductSalesId, @ProductId, @QuantityToSell)

			COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			ROLLBACK TRANSACTION
			SELECT ERROR_NUMBER() AS ErrorNumber, 
				ERROR_MESSAGE() AS ErrorMessage, 
				ERROR_PROCEDURE() AS ErrorProcedure, 
				ERROR_STATE() AS ErrorState, 
				ERROR_SEVERITY() AS ErrorSeverity, 
				ERROR_LINE() AS ErrorLine
		END CATCH
	END
END

EXECUTE [spSellProduct2] 1, 10;

SELECT * FROM [tblProduct];
SELECT * FROM [tblProductSales];


------------------------------------------------------------------------------
---- RESULT WHEN 'SET' OPERATION IS COMMENTED OUT ----

ALTER PROCEDURE [spSellProduct2] @ProductId INT, @QuantityToSell INT
AS
BEGIN
	-- Check the stock available, for the product we want to sell
	DECLARE @StockAvailable INT

	SELECT @StockAvailable = QtyAvailable
	FROM tblProduct
	WHERE ProductId = @ProductId

	-- Throw an error to the calling application, if enough stock is not available
	IF (@StockAvailable < @QuantityToSell)
	BEGIN
		RAISERROR ('Not enough stock available', 16, 1)
	END
			-- If enough stock available
	ELSE
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION

			-- First reduce the quantity available
			UPDATE tblProduct
			SET QtyAvailable = (QtyAvailable - @QuantityToSell)
			WHERE ProductId = @ProductId

			DECLARE @MaxProductSalesId INT

			-- Calculate MAX ProductSalesId  
			SELECT @MaxProductSalesId = CASE 
					WHEN MAX(ProductSalesId) IS NULL
						THEN 0
					ELSE MAX(ProductSalesId)
					END
			FROM tblProductSales

			--Increment @MaxProductSalesId by 1, so we don't get a primary key violation
--			SET @MaxProductSalesId = @MaxProductSalesId + 1

			INSERT INTO tblProductSales
			VALUES (@MaxProductSalesId, @ProductId, @QuantityToSell)

			COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			ROLLBACK TRANSACTION
			SELECT ERROR_NUMBER() AS ErrorNumber, 
				ERROR_MESSAGE() AS ErrorMessage, 
				ERROR_PROCEDURE() AS ErrorProcedure, 
				ERROR_STATE() AS ErrorState, 
				ERROR_SEVERITY() AS ErrorSeverity, 
				ERROR_LINE() AS ErrorLine
		END CATCH
	END
END

EXECUTE [spSellProduct2] 1, 10;

SELECT * FROM [tblProduct];
SELECT * FROM [tblProductSales];












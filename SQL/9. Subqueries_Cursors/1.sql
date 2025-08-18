------------------------------------------------------------------------------
---- SUBQUERIES ----
------------------------------------------------------------------------------

DROP TABLE [tblProducts];
DROP TABLE [tblProductSales];

CREATE TABLE tblProducts ([Id] INT identity PRIMARY KEY, [Name] NVARCHAR(50), [Description] NVARCHAR(250));

CREATE TABLE tblProductSales (Id INT PRIMARY KEY identity, ProductId INT FOREIGN KEY REFERENCES tblProducts(Id), UnitPrice INT, QuantitySold INT);

INSERT INTO tblProducts VALUES
('TV', '52 inch black color LCD TV'),
('Laptop', 'Very thin black color acer laptop'),
('Des_keytop', 'HP high performance des_keytop');

INSERT INTO tblProductSales VALUES
(3, 450, 5),
(2, 250, 7),
(3, 450, 4),
(3, 450, 9);

SELECT * FROM [tblProducts];
SELECT * FROM [tblProductSales];


------------------------------------------------------------------------------
--(Q1) Write a query to retrieve products that are not at all sold?
------------------------------------------------------------------------------
SELECT a.id, name, description
FROM tblProducts a
LEFT JOIN tblProductSales b
ON a.id = b.productid
WHERE b.id IS NULL;
--OR
SELECT id, name, description
FROM tblProducts
WHERE id NOT IN (
	SELECT DISTINCT productid
	FROM tblProductSales
);


------------------------------------------------------------------------------
--(Q2) Write a query to retrieve the NAME and TOTALQUANTITY sold
------------------------------------------------------------------------------

---- CORRELATED SUBQUERIES ----
------------------------------------------------------------------------------

SELECT a.id, name, ISNULL(SUM(quantitysold), 0) AS totalQtySold
FROM tblProducts a
LEFT JOIN tblProductSales b
ON a.id = b.productid
GROUP BY a.id, name
ORDER BY a.id;
--OR
SELECT id, name, 
	(
		SELECT ISNULL(SUM(quantitysold), 0) AS totalQtySold
		FROM [tblProductSales]
		WHERE productid = a.id
	)
FROM tblProducts a;




------------------------------------------------------------------------------
---- Drop table if exists & Recreate as large tables----
------------------------------------------------------------------------------

SELECT *
FROM [information_schema].[tables];

IF EXISTS(
		SELECT *
		FROM [information_schema].[tables]
		WHERE table_name = 'tblProductSales'
	)
	BEGIN
		DROP TABLE [tblProductSales]
	END

IF EXISTS(
		SELECT *
		FROM [information_schema].[tables]
		WHERE table_name = 'tblProducts'
	)
	BEGIN
		DROP TABLE [tblProducts]
	END

------------------------------------------------------------------------------
---- Recreate tables ----
CREATE TABLE tblProducts ([Id] INT identity PRIMARY KEY, [Name] NVARCHAR(50), [Description] NVARCHAR(250))

CREATE TABLE tblProductSales (Id INT PRIMARY KEY identity, ProductId INT FOREIGN KEY REFERENCES tblProducts(Id), UnitPrice INT, QuantitySold INT)

------------------------------------------------------------------------------
---- Insert Sample data into tblProducts table ----

DECLARE @Id INT

SET @Id = 1

WHILE (@Id <= 300000)
BEGIN
	INSERT INTO tblProducts
	VALUES ('Product - ' + CAST(@Id AS NVARCHAR(20)), 'Product - ' + CAST(@Id AS NVARCHAR(20)) + ' Description')

	COMMIT

	-- Avoid printing each row
	IF @Id % 10000 = 0
		PRINT 'Inserted ' + CAST(@Id AS NVARCHAR(20)) + ' rows';

	SET @Id = @Id + 1
END

-- Declare variables to hold a random ProductId, UnitPrice and QuantitySold
DECLARE @RandomProductId INT
DECLARE @RandomUnitPrice INT
DECLARE @RandomQuantitySold INT

-- Declare and set variables to generate a random ProductId between 1 and 100000
DECLARE @UpperLimitForProductId INT
DECLARE @LowerLimitForProductId INT

SET @LowerLimitForProductId = 1
SET @UpperLimitForProductId = 100000

-- Declare and set variables to generate a random UnitPrice between 1 and 100
DECLARE @UpperLimitForUnitPrice INT
DECLARE @LowerLimitForUnitPrice INT

SET @LowerLimitForUnitPrice = 1
SET @UpperLimitForUnitPrice = 100

-- Declare and set variables to generate a random QuantitySold between 1 and 10
DECLARE @UpperLimitForQuantitySold INT
DECLARE @LowerLimitForQuantitySold INT

SET @LowerLimitForQuantitySold = 1
SET @UpperLimitForQuantitySold = 10


------------------------------------------------------------------------------
---- Insert Sample data into tblProductSales table ----

DECLARE @Counter INT

SET @Counter = 1

WHILE (@Counter <= 450000)
BEGIN
	SELECT @RandomProductId = Round(((@UpperLimitForProductId - @LowerLimitForProductId) * Rand() + @LowerLimitForProductId), 0)

	SELECT @RandomUnitPrice = Round(((@UpperLimitForUnitPrice - @LowerLimitForUnitPrice) * Rand() + @LowerLimitForUnitPrice), 0)

	SELECT @RandomQuantitySold = Round(((@UpperLimitForQuantitySold - @LowerLimitForQuantitySold) * Rand() + @LowerLimitForQuantitySold), 0)

	INSERT INTO tblProductsales
	VALUES (@RandomProductId, @RandomUnitPrice, @RandomQuantitySold)

	PRINT @Counter

	SET @Counter = @Counter + 1
END Finally, CHECK the data IN the tables using a SIMPLE

SELECT query TO make sure the data has been inserted AS expected.


------------------------------------------------------------------------------
---- Fetching data from bith the tables ----

SELECT *
FROM tblProducts

SELECT *
FROM tblProductSales

------------------------------------------------------------------------------
---- CURSORS ----
------------------------------------------------------------------------------

------------------------------------------------------------------------------
---- Using Cursors ----
DECLARE @ProductId INT

-- Declare the cursor using the declare keyword
DECLARE ProductIdCursor CURSOR
FOR
SELECT ProductId
FROM tblProductSales

-- Open statement, executes the SELECT statment
-- and populates the result set
OPEN ProductIdCursor

-- Fetch the row from the result set into the variable
FETCH NEXT
FROM ProductIdCursor
INTO @ProductId

-- If the result set still has rows, @@FETCH_STATUS will be ZERO
WHILE (@@FETCH_STATUS = 0)
BEGIN
	DECLARE @ProductName NVARCHAR(50)

	SELECT @ProductName = Name
	FROM tblProducts
	WHERE Id = @ProductId

	IF (@ProductName = 'Product - 55')
	BEGIN
		UPDATE tblProductSales
		SET UnitPrice = 55
		WHERE ProductId = @ProductId
	END
	ELSE IF (@ProductName = 'Product - 65')
	BEGIN
		UPDATE tblProductSales
		SET UnitPrice = 65
		WHERE ProductId = @ProductId
	END
	ELSE IF (@ProductName LIKE 'Product - 100%')
	BEGIN
		UPDATE tblProductSales
		SET UnitPrice = 1000
		WHERE ProductId = @ProductId
	END

	FETCH NEXT
	FROM ProductIdCursor
	INTO @ProductId
END

-- Release the row set
CLOSE ProductIdCursor

-- Deallocate, the resources associated with the cursor
DEALLOCATE ProductIdCursor


---- Check Results ----
SELECT Name, UnitPrice
FROM tblProducts
JOIN tblProductSales ON tblProducts.Id = tblProductSales.ProductId
WHERE (Name = 'Product - 55' OR Name = 'Product - 65' OR Name LIKE 'Product - 100%')



------------------------------------------------------------------------------
---- Using Joins ----

UPDATE tblProductSales
SET UnitPrice = CASE 
		WHEN Name = 'Product - 55'
			THEN 155
		WHEN Name = 'Product - 65'
			THEN 165
		WHEN Name LIKE 'Product - 100%'
			THEN 10001
		ELSE
			UnitPrice
		END
FROM tblProductSales
JOIN tblProducts ON tblProducts.Id = tblProductSales.ProductId
WHERE Name = 'Product - 55' OR Name = 'Product - 65' OR Name LIKE 'Product - 100%'

---- Check Results ----
SELECT Name, UnitPrice
FROM tblProducts
JOIN tblProductSales ON tblProducts.Id = tblProductSales.ProductId
WHERE (Name = 'Product - 55' OR Name = 'Product - 65' OR Name LIKE 'Product - 100%')




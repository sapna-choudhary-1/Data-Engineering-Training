/*
=============================================================================================
Stored Procedure: Load data into Bronze Layer Tables (Source -> Bronze)
=============================================================================================
Purpose:
	- This stored procedure loads data (initial/ new-batch) into the 'bronze' schema, in the 'DWH' database, from external CSV files
	- It performs following operations:
		- Truncates existing data in the tables before loading new data
		- Uses BULK INSERT to load data from CSV files located in the specified directory
		- Handles errors during the loading process and prints relevant messages
		- Prints the duration of each loading operation and the total duration at the end

Parameters:
	- None
	- The procedure does not take any parameters or return any values

Usage Example:
	- EXEC bronze.sp_load_bronze
=============================================================================================
*/

CREATE OR ALTER PROCEDURE bronze.sp_load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
	SET @batch_start_time = GETDATE()
	BEGIN TRY
		PRINT '========================================================'
		PRINT 'Loading the data in the Bronze layer'
		PRINT '========================================================'
		
		PRINT '------------------------------------------------------------'
		SET @start_time = GETDATE()
		PRINT ' >>>> Truncating Table: DWH.bronze.FactSales <<<< '
		TRUNCATE TABLE DWH.bronze.FactSales
		
		PRINT ' >>>> Inserting Data Into Table: DWH.bronze.FactSales'
		BULK INSERT DWH.bronze.FactSales
		FROM '/var/opt/mssql/data/DWH_raw_dataset/fact_sales.csv'
		WITH (
			FIRSTROW = 2,
			FORMAT = 'CSV',
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		SET @end_time = GETDATE()
		PRINT ' >>>> Loading Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds'
		PRINT '------------------------------------------------------------'
		
		
		PRINT '------------------------------------------------------------'
		SET @start_time = GETDATE()
		PRINT ' >>>> Truncating Table: DWH.bronze.CustomerInfo <<<< '
		TRUNCATE TABLE DWH.bronze.CustomerInfo
		
		PRINT ' >>>> Inserting Data Into Table: DWH.bronze.CustomerInfo'
		BULK INSERT DWH.bronze.CustomerInfo
		FROM '/var/opt/mssql/data/DWH_raw_dataset/dim_customer.csv'
		WITH (
			FIRSTROW = 2,
			FORMAT = 'CSV',
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		SET @end_time = GETDATE()
		PRINT ' >>>> Loading Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds'
		PRINT '------------------------------------------------------------'
		
		
		PRINT '------------------------------------------------------------'
		SET @start_time = GETDATE()
		PRINT ' >>>> Truncating Table: DWH.bronze.ProductInfo <<<< '
		TRUNCATE TABLE DWH.bronze.ProductInfo
		
		PRINT ' >>>> Inserting Data Into Table: DWH.bronze.ProductInfo'
		BULK INSERT DWH.bronze.ProductInfo
		FROM '/var/opt/mssql/data/DWH_raw_dataset/dim_product.csv'
		WITH (
			FIRSTROW = 2,
			FORMAT = 'CSV',
			FIELDTERMINATOR = ',',
			TABLOCK,
			KEEPNULLS
		)
		SET @end_time = GETDATE()
		PRINT ' >>>> Loading Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds'
		PRINT '------------------------------------------------------------'
		
		
		PRINT '------------------------------------------------------------'
		SET @start_time = GETDATE()
		PRINT ' >>>> Truncating Table: DWH.bronze.ProductType <<<< '
		TRUNCATE TABLE DWH.bronze.ProductType
		
		PRINT ' >>>> Inserting Data Into Table: DWH.bronze.ProductType'
		BULK INSERT DWH.bronze.ProductType
		FROM '/var/opt/mssql/data/DWH_raw_dataset/dim_product_type.csv'
		WITH (
			FIRSTROW = 2,
			FORMAT = 'CSV',
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		SET @end_time = GETDATE()
		PRINT ' >>>> Loading Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds'
		PRINT '------------------------------------------------------------'
		
		
		PRINT '------------------------------------------------------------'
		SET @start_time = GETDATE()
		PRINT ' >>>> Truncating Table: DWH.bronze.OrderInfo <<<< '
		TRUNCATE TABLE DWH.bronze.OrderInfo
		
		PRINT ' >>>> Inserting Data Into Table: DWH.bronze.OrderInfo'
		BULK INSERT DWH.bronze.OrderInfo
		FROM '/var/opt/mssql/data/DWH_raw_dataset/dim_order.csv'
		WITH (
			FIRSTROW = 2,
			FORMAT = 'CSV',
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		SET @end_time = GETDATE()
		PRINT ' >>>> Loading Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds'
		PRINT '------------------------------------------------------------'
		
		
		PRINT '------------------------------------------------------------'
		SET @start_time = GETDATE()
		PRINT ' >>>> Truncating Table: DWH.bronze.Category <<<< '
		TRUNCATE TABLE DWH.bronze.Category
		
		PRINT ' >>>> Inserting Data Into Table: DWH.bronze.Category'
		BULK INSERT DWH.bronze.Category
		FROM '/var/opt/mssql/data/DWH_raw_dataset/dim_category.csv'
		WITH (
			FIRSTROW = 2,
			FORMAT = 'CSV',
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		SET @end_time = GETDATE()
		PRINT ' >>>> Loading Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds'
		PRINT '------------------------------------------------------------'
		
		
		PRINT '------------------------------------------------------------'
		SET @start_time = GETDATE()
		PRINT ' >>>> Truncating Table: DWH.bronze.DateInfo <<<< '
		TRUNCATE TABLE DWH.bronze.DateInfo
		
		PRINT ' >>>> Inserting Data Into Table: DWH.bronze.DateInfo'
		BULK INSERT DWH.bronze.DateInfo
		FROM '/var/opt/mssql/data/DWH_raw_dataset/dim_date.csv'
		WITH (
			FIRSTROW = 2,
			FORMAT = 'CSV',
			FIELDTERMINATOR = ',',
			TABLOCK,
			KEEPNULLS
		)
		SET @end_time = GETDATE()
		PRINT ' >>>> Loading Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds'
		PRINT '------------------------------------------------------------'
		
	PRINT '========================================================'
	SET @batch_end_time = GETDATE()
	PRINT 'Loading Bronze Layer is Completed'
	PRINT ' >>>> Total Loading Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + 'seconds'
	PRINT '========================================================'
		
	END TRY
	BEGIN CATCH
		PRINT '============================================================'
		PRINT 'ERROR OCCURED During Loading of the data in the BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE()
		PRINT 'Error Number' + CAST(ERROR_NUMBER() AS NVARCHAR)
		PRINT 'Error State' + CAST(ERROR_STATE() AS NVARCHAR)
		PRINT '============================================================'
	END CATCH
END

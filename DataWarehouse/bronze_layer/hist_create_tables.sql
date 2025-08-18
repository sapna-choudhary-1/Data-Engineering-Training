/*
=========================================================================================================
  Description:
  - This stored procedure creates the bronze layer tables in the 'associatetraining' database.
  - It drops the tables if they already exist to avoid duplication.
  - It also creates a 'tbl_csv_mapping' table to map CSV files to their respective table names for automated data loading.
  - Finally, it executes [bronze].[bronze_load] to initiate the batch loading from CSVs.
=========================================================================================================
*/

USE [associatetraining];
CREATE OR ALTER PROCEDURE [bronze].[usp_create_tables_hist] AS
BEGIN

-- =========================================================================================================
-- CUSTOMER TABLES
-- =========================================================================================================
  IF OBJECT_ID('[bronze].[customer_hist]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [bronze].[customer_hist]
    END;

  BEGIN
    CREATE TABLE [bronze].[customer_hist] (
      [customer_id] NVARCHAR(15), -- SCD-0 
      [signup_date] NVARCHAR(15), -- SCD-0 
      [gender] NVARCHAR(10), -- SCD-0 
      [customer_dob] NVARCHAR(15), -- SCD-0 

      [customer_name] NVARCHAR(100), -- SCD-1
      [marital_status] NVARCHAR(10), -- SCD-1

      [customer_type] NVARCHAR(50), -- SCD-3
      [account_status] NVARCHAR(20), -- SCD-3

      [country] NVARCHAR(50), -- SCD-2
      [state] NVARCHAR(50), -- SCD-2
      [city] NVARCHAR(50), -- SCD-2
      [postal code] NVARCHAR(50), -- SCD-2
      [region] NVARCHAR(50), -- SCD-2
      [email] NVARCHAR(100), -- SCD-2
      [phone] NVARCHAR(50), -- SCD-2

      -- metadata for audit
      [batch_id] INT, -- SCD-0
      [load_timestamp] DATETIME DEFAULT GETDATE()
    )
  END;


-- =========================================================================================================
-- PRODUCT TABLES
-- =========================================================================================================
  IF OBJECT_ID('[bronze].[product_hist]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [bronze].[product_hist]
    END;

  BEGIN
    CREATE TABLE [bronze].[product_hist] (
      [product_id] NVARCHAR(50), -- SCD-0
      [product_name] NVARCHAR(1000), -- SCD-1
      
      [brand_tier] NVARCHAR(50), -- SCD-0/1
      [brand_name] NVARCHAR(50), -- SCD-0/1
      [brand_country] NVARCHAR(50), -- SCD-0/1
      
      [main_category] NVARCHAR(50), -- SCD-2
      [sub_category] NVARCHAR(50), -- SCD-2
      [discount_percent] NVARCHAR(50), -- SCD-2
      [actual_price] NVARCHAR(50), -- SCD-2
      [rating] NVARCHAR(50), -- SCD-3
      [no of ratings] NVARCHAR(15), -- SCD-3
      
      -- metadata for audit
      [batch_id] INT, -- SCD-0
      [load_timestamp] DATETIME DEFAULT GETDATE()
    )
  END;

-- =========================================================================================================
-- ORDER TABLES
-- =========================================================================================================
  IF OBJECT_ID('[bronze].[order_hist]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [bronze].[order_hist]
    END;

  BEGIN -- SCD-0
    CREATE TABLE [bronze].[order_hist] (
      [order_id] NVARCHAR(50),
      [customer_id] NVARCHAR(15),
      [product_id] NVARCHAR(50),

      [shipping_type] NVARCHAR(50),
      [payment_src] NVARCHAR(50),
      [lead_type] NVARCHAR(50),
      [order_status] NVARCHAR(50),

      [order_date] NVARCHAR(15),
      [shipping_date] NVARCHAR(15),
      [expected_delivery_date] NVARCHAR(15),
      [delivery_date] NVARCHAR(15),
      [return_date] NVARCHAR(15),
      [refund_date] NVARCHAR(15),
      [quantity] NVARCHAR(10),
      [unit_price] NVARCHAR(50),

      [is_gift] BIT,
      [gift_message] NVARCHAR(500),
      [has_coupon] BIT,
      [coupon_code] NVARCHAR(50),
      
      -- metadata for audit
      [batch_id] INT, -- SCD-0
      [load_timestamp] DATETIME DEFAULT GETDATE()
    )
  END;

-- ----------------------------------------------------------------------------------------
  IF OBJECT_ID('[bronze].[shipping_type_hist]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [bronze].[shipping_type_hist]
    END;

  BEGIN -- SCD-1
    CREATE TABLE [bronze].[shipping_type_hist] (
      [shipping_type_id] NVARCHAR(50),
      [shipping_type] NVARCHAR(50),
      [delivery_estimate] NVARCHAR(50),
      
      -- metadata for audit
      [batch_id] INT, -- SCD-0
      [load_timestamp] DATETIME DEFAULT GETDATE()
    )
  END;


-- =========================================================================================================
-- Batch_audit TABLE
-- =========================================================================================================
  IF OBJECT_ID('[bronze].[batch_audit]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [bronze].[batch_audit]
    END;

  BEGIN
	CREATE TABLE [bronze].[batch_audit] (
	  [batch_id] INT IDENTITY(1,1) PRIMARY KEY,
	  [load_name] NVARCHAR(100),
	  [load_timestamp] DATETIME DEFAULT GETDATE()
	);
	END;
END;

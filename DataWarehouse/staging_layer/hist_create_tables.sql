/*
=========================================================================================================
  Description:
  - This stored procedure creates the staging layer tables in the 'associatetraining' database.
  - It drops the tables if they already exist to avoid duplication.
  - It also creates a 'tbl_csv_mapping' table to map CSV files to their respective table names for automated data loading.
  - Finally, it executes [staging].[staging_load] to initiate the batch loading from CSVs.
=========================================================================================================
*/
USE [associatetraining];

CREATE OR ALTER PROCEDURE [staging].[usp_create_tables_hist]
AS
BEGIN

-- =========================================================================================================

-- Batch_audit TABLE
-- =========================================================================================================
  IF OBJECT_ID('[staging].[batch_audit]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [staging].[batch_audit];
    END

  BEGIN
    CREATE TABLE [staging].[batch_audit] (
      [batch_id] INT IDENTITY(1,1) PRIMARY KEY,
      [load_name] NVARCHAR(100),
      [load_timestamp] DATETIME DEFAULT GETDATE()
    )
  END

-- =========================================================================================================
-- =========================================================================================================
-- ======================================= CUSTOMER DIMENSION TABLE =======================================
-- =========================================================================================================
  IF OBJECT_ID('[staging].[customer_hist]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [staging].[customer_hist];
    END

  BEGIN
--    CREATE TABLE IF NOT EXISTS [staging].[customer] (
    CREATE TABLE [staging].[customer_hist] (
      [customer_id] INT
        CONSTRAINT [PK_customer_hist] PRIMARY KEY,
      [signup_date] DATETIME,
      [gender] NVARCHAR(10),

      [customer_dob] DATE,
      [customer_name] NVARCHAR(100),
      [marital_status] NVARCHAR(10),
      [email] NVARCHAR(100),
      [phone] NVARCHAR(50),

      [customer_type] NVARCHAR(50),
      [account_status] NVARCHAR(20),

      [country] NVARCHAR(50),
      [state] NVARCHAR(50),
      [city] NVARCHAR(50),
      [postal_code] NVARCHAR(50),
      [region] NVARCHAR(50),

      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE()
    )
  END


-- =========================================================================================================
-- =========================================================================================================
-- =========================================================================================================
-- ======================================= PRODUCT DIMENSION TABLES =======================================
-- =========================================================================================================
  IF OBJECT_ID('[staging].[product_hist]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [staging].[product_hist]
    END

  BEGIN
    CREATE TABLE [staging].[product_hist] (
      [product_id] NVARCHAR(50)
        CONSTRAINT [PK_product_hist] PRIMARY KEY,
      [product_name] NVARCHAR(100),
      
      [brand_tier] NVARCHAR(50),
      [brand_name] NVARCHAR(50),
      [brand_country] NVARCHAR(50),
      
      [main_category] NVARCHAR(50),
      [sub_category] NVARCHAR(50),
      [discount_percent] DECIMAL(10,2),
      [actual_price] DECIMAL(10,2),
      
      [rating] DECIMAL(3,2),
      [no_of_ratings] INT,
      
      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE()
    )
  END

-- =========================================================================================================
-- ======================================= SHIPPING TYPE TABLES=======================================
-- =========================================================================================================
  IF OBJECT_ID('[staging].[shipping_type_hist]', 'U') IS NOT NULL
  BEGIN
    DROP TABLE [staging].[shipping_type_hist];
  END

  BEGIN
    CREATE TABLE [staging].[shipping_type_hist] (
      [shipping_type] NVARCHAR(50),
      [delivery_estimate] NVARCHAR(50),
        
      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE()
    )
  END
END;


-- =========================================================================================================
-- ======================================= ORDER DIMENSION TABLES =======================================
-- =========================================================================================================
  IF OBJECT_ID('[staging].[order_hist]', 'U') IS NOT NULL
  BEGIN
    DROP TABLE [staging].[order_hist];
  END

  BEGIN
    CREATE TABLE [staging].[order_hist] (
      [order_id] NVARCHAR(50)
        CONSTRAINT [PK_order_hist] PRIMARY KEY,
      [customer_id] INT,
      [product_id] NVARCHAR(50),

      -- [shipping_type_id] INT,
      [shipping_type] NVARCHAR(50),
      [payment_source] NVARCHAR(50),
      [lead_type] NVARCHAR(50),
      [order_status] NVARCHAR(50),

      [order_date] DATETIME,
      [shipping_date] DATETIME,
      [expected_delivery_date] DATETIME,
      [delivery_date] DATETIME,
      [return_date] DATETIME,
      [refund_date] DATETIME,
      [quantity]  INT,
      [unit_price] DECIMAL(10,2),

      [is_gift]  BIT,
      [gift_message] NVARCHAR(500),
      [has_coupon] BIT,
      [coupon_code] NVARCHAR(50),
        
      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE()
    )
  END

-- =========================================================================================================



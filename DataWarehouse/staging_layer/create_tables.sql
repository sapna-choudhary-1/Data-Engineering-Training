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

CREATE OR ALTER PROCEDURE [staging].[usp_create_tables]
AS
BEGIN
  IF OBJECT_ID('[staging].[order]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [staging].[order]
    END;
  IF OBJECT_ID('[staging].[shipping_type]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [staging].[shipping_type]
    END;
  IF OBJECT_ID('[staging].[product]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [staging].[product]
    END;
  IF OBJECT_ID('[staging].[customer]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [staging].[customer]
    END;

-- =========================================================================================================
-- CUSTOMER TABLES
-- =========================================================================================================

  BEGIN
--    CREATE TABLE IF NOT EXISTS [staging].[customer] (
    CREATE TABLE [staging].[customer] (
      [customer_id] INT
        CONSTRAINT [PK_customer] PRIMARY KEY, -- SCD-0 
      [signup_date] DATETIME NOT NULL, -- SCD-0 
      [gender] NVARCHAR(10) NOT NULL, -- SCD-0 

      [customer_dob] DATE NULL, -- SCD-1
      [customer_name] NVARCHAR(100) NULL, -- SCD-1
      [marital_status] NVARCHAR(10) NOT NULL, -- SCD-1
      [email] NVARCHAR(100) NULL, -- SCD-1
      [phone] NVARCHAR(50) NULL, -- SCD-1

      [customer_type] NVARCHAR(50) NOT NULL, -- SCD-3
      [account_status] NVARCHAR(20) NOT NULL, -- SCD-3

      [country] NVARCHAR(50) NOT NULL, -- SCD-2
      [state] NVARCHAR(50) NOT NULL, -- SCD-2
      [city] NVARCHAR(50) NOT NULL, -- SCD-2
      [postal_code] NVARCHAR(50) NOT NULL, -- SCD-2
      [region] NVARCHAR(50) NOT NULL, -- SCD-2

      -- metadata for audit
      [load_timestamp] DATETIME DEFAULT GETDATE()
    )
  END


-- =========================================================================================================
-- PRODUCT TABLES
-- =========================================================================================================

  BEGIN
    CREATE TABLE [staging].[product] (
      [product_id] NVARCHAR(50)
        CONSTRAINT [PK_product] PRIMARY KEY, -- SCD-0
      [product_name] NVARCHAR(100) NOT NULL, -- SCD-1
      
      [brand_tier] NVARCHAR(50) NOT NULL, -- SCD-2
      [brand_name] NVARCHAR(50) NOT NULL, -- SCD-2
      [brand_country] NVARCHAR(50) NOT NULL, -- SCD-2
      
      [main_category] NVARCHAR(50) NOT NULL, -- SCD-2
      [sub_category] NVARCHAR(50) NOT NULL, -- SCD-2
      [discount_percent] DECIMAL(10,2) NOT NULL
        CONSTRAINT [CHK_dim_product_discount_percent] CHECK ([discount_percent] >= 0 AND [discount_percent] <= 100), -- SCD-2
      [actual_price] DECIMAL(10,2) NULL
        CONSTRAINT [CHK_dim_product_actual_price] CHECK ([actual_price] >= 0), -- SCD-2
      
      [rating] DECIMAL(3,2) NULL
        CONSTRAINT [CHK_dim_product_rating] CHECK ([rating] >= 0), -- SCD-3
      [no_of_ratings] INT NULL
        CONSTRAINT [CHK_dim_product_no_of_ratings] CHECK ([no_of_ratings] >= 0), -- SCD-3
      
      -- metadata for audit
      [load_timestamp] DATETIME DEFAULT GETDATE()
    )
  END


-- =========================================================================================================
-- SHIPPING TYPE TABLES
-- =========================================================================================================

  BEGIN -- SCD-1
    CREATE TABLE [staging].[shipping_type] (
      -- [shipping_type_id] INT IDENTITY(1,1)
      --   CONSTRAINT [PK_dim_shipping_type] PRIMARY KEY,
      [shipping_type] NVARCHAR(50) NOT NULL,
      [delivery_estimate] NVARCHAR(50) NOT NULL,
      
      -- metadata for audit
      [load_timestamp] DATETIME DEFAULT GETDATE()
    )
  END

-- =========================================================================================================
-- ORDER TABLES
-- =========================================================================================================

  BEGIN
    CREATE TABLE [staging].[order] (
      [order_id] NVARCHAR(50)
        CONSTRAINT [PK_dim_order] PRIMARY KEY, -- SCD-0
      [customer_id] INT NOT NULL, -- SCD-0
      [product_id] NVARCHAR(50) NOT NULL, -- SCD-0

      -- [shipping_type_id] INT NOT NULL,
      [shipping_type] NVARCHAR(50) NOT NULL, -- SCD-1
      [payment_source] NVARCHAR(50) NOT NULL, -- SCD-1
      [lead_type] NVARCHAR(50) NOT NULL, -- SCD-1
      [order_status] NVARCHAR(50) NOT NULL, -- SCD-2

      [order_date] DATETIME NOT NULL, -- SCD-0
      [shipping_date] DATETIME NOT NULL, -- SCD-1
      [expected_delivery_date] DATETIME NULL, -- SCD-1
      [delivery_date] DATETIME NULL, -- SCD-1
      [return_date] DATETIME NULL, -- SCD-1
      [refund_date] DATETIME NULL, -- SCD-1
      [quantity]  INT NOT NULL
        CONSTRAINT [CHK_order_quantity] CHECK ([quantity] > 0), -- SCD-0
      [unit_price] DECIMAL(10,2) NOT NULL
        CONSTRAINT [CHK_order_unit_price] CHECK ([unit_price] >= 0), -- SCD-0

      [is_gift]  BIT DEFAULT 0
        CONSTRAINT [CHK_order_is_gift] CHECK ([is_gift] IN (0, 1)), -- SCD-0
      [gift_message] NVARCHAR(500) NULL, -- SCD-0
      [has_coupon] BIT DEFAULT 0
        CONSTRAINT [CHK_dim_order_has_coupon] CHECK ([has_coupon] IN (0, 1)), -- SCD-0
      [coupon_code] NVARCHAR(50) NULL, -- SCD-0
      
      -- metadata for audit
      [load_timestamp] DATETIME DEFAULT GETDATE()

      -- Foreign Keys
      -- CONSTRAINT [FK_order_shipping_type_id] FOREIGN KEY ([shipping_type_id]) 
      --   REFERENCES [staging].[shipping_type]([shipping_type_id]),
      CONSTRAINT [FK_order_product] FOREIGN KEY ([product_id]) 
        REFERENCES [staging].[product]([product_id]),
      CONSTRAINT [FK_order_customer] FOREIGN KEY ([customer_id]) 
        REFERENCES [staging].[customer]([customer_id]),

      -- Checks  
      CONSTRAINT [CHK_order_gift_message_dependency] CHECK (
          ([is_gift] = 1 AND [gift_message] IS NOT NULL) OR
          ([is_gift] = 0 AND [gift_message] IS NULL)
      	),
      CONSTRAINT [CHK_order_coupon_code_dependency] CHECK (
          ([has_coupon] = 1 AND [coupon_code] IS NOT NULL) OR
          ([has_coupon] = 0 AND [coupon_code] IS NULL)
        )
    )
  END
  

END;



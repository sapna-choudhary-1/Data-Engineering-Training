/*
=========================================================================================================
  Description:
  - This stored procedure creates the gold layer tables in the 'associatetraining' database.
  - It drops the tables if they already exist to avoid duplication.
  - It also creates a 'tbl_csv_mapping' table to map CSV files to their respective table names for automated data loading.
  - Finally, it executes [gold].[gold_load] to initiate the batch loading from CSVs.
=========================================================================================================
*/
USE [associatetraining];

CREATE OR ALTER PROCEDURE [gold].[usp_create_tables]
AS
BEGIN

-- =========================================================================================================

-- Batch_audit TABLE
-- =========================================================================================================
  IF OBJECT_ID('[gold].[batch_audit]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [gold].[batch_audit]
    END

  BEGIN
    CREATE TABLE [gold].[batch_audit] (
      [batch_id] INT IDENTITY(1,1) PRIMARY KEY,
      [load_name] NVARCHAR(100),
      [load_timestamp] DATETIME DEFAULT GETDATE()
    )
	END


-- =========================================================================================================
-- =========================================================================================================
-- DATE DIMENSION TABLE
-- =========================================================================================================
  IF OBJECT_ID('[gold].[dim_date]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [gold].[dim_date];
    END

  BEGIN
    CREATE TABLE [gold].[dim_date] (
      [date_skey] INT IDENTITY(1,1) 
        CONSTRAINT [PK_dim_date] PRIMARY KEY,
      [date] DATE NOT NULL,
      [year] INT NOT NULL,
      [month] INT NOT NULL,
      [day] INT NOT NULL,
      [weekday] INT NOT NULL,
      [weekday_name] NVARCHAR(10) NOT NULL,
      [is_weekend] BIT NOT NULL,
      [fiscal_quarter] NVARCHAR(2) NOT NULL,

      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE(),

      -- Unique constraint
      CONSTRAINT [UQ_dim_date_date] UNIQUE ([date])
    )
  END

-- =========================================================================================================
  -- ====================================== DIM GENDER ======================================
-- =========================================================================================================
  IF OBJECT_ID('[gold].[dim_gender]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [gold].[dim_gender];
    END

  BEGIN
    CREATE TABLE [gold].[dim_gender] (
      [gender_skey] INT IDENTITY(1,1) 
        CONSTRAINT [PK_dim_gender] PRIMARY KEY,
      [gender] NVARCHAR(10) NOT NULL,
      [is_active] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_gender_is_active] CHECK ([is_active] IN (0, 1)),

      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE(),

      -- Unique constraint
      CONSTRAINT [UQ_dim_gender] UNIQUE ([gender])
    )
  END

-- =========================================================================================================
  -- ====================================== DIM MARITAL STATUS ======================================
-- =========================================================================================================
  IF OBJECT_ID('[gold].[dim_marital_status]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [gold].[dim_marital_status];
    END

  BEGIN
    CREATE TABLE [gold].[dim_marital_status] (
      [marital_status_skey] INT IDENTITY(1,1) 
        CONSTRAINT [PK_dim_marital_status] PRIMARY KEY,
      [marital_status] NVARCHAR(10) NOT NULL,
      [is_active] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_marital_status_is_active] CHECK ([is_active] IN (0, 1)),
      
      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE(),

      -- Unique constraint
      CONSTRAINT [UQ_dim_marital_status] UNIQUE ([marital_status])
    )
  END

-- =========================================================================================================
  -- ====================================== DIM CUSTOMER TYPE ======================================
-- =========================================================================================================
  IF OBJECT_ID('[gold].[dim_customer_type]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [gold].[dim_customer_type];
    END

  BEGIN
    CREATE TABLE [gold].[dim_customer_type] (
      [customer_type_skey] INT IDENTITY(1,1) 
        CONSTRAINT [PK_dim_customer_type] PRIMARY KEY,
      [customer_type] NVARCHAR(50) NOT NULL,
      [is_active] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_customer_type_is_active] CHECK ([is_active] IN (0, 1)),
      
      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE(),

      -- Unique constraint
      CONSTRAINT [UQ_dim_customer_type] UNIQUE ([customer_type])
    )
  END

-- =========================================================================================================
  -- ====================================== DIM ACCOUNT STATUS ======================================
-- =========================================================================================================
  IF OBJECT_ID('[gold].[dim_account_status]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [gold].[dim_account_status];
    END

  BEGIN
    CREATE TABLE [gold].[dim_account_status] (
      [account_status_skey] INT IDENTITY(1,1) 
        CONSTRAINT [PK_dim_account_status] PRIMARY KEY,
      [account_status] NVARCHAR(20) NOT NULL,
      [is_active] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_account_status_is_active] CHECK ([is_active] IN (0, 1)),

      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE(),

      -- Unique constraint
      CONSTRAINT [UQ_dim_account_status] UNIQUE ([account_status])
    )
  END

-- =========================================================================================================
  -- ====================================== DIM REGION ======================================
-- =========================================================================================================
  IF OBJECT_ID('[gold].[dim_region]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [gold].[dim_region];
    END

  BEGIN
    CREATE TABLE [gold].[dim_region] (
      [region_skey] INT IDENTITY(1,1) 
        CONSTRAINT [PK_dim_region] PRIMARY KEY,
      [region] NVARCHAR(50) NOT NULL,
      [is_active] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_region_is_active] CHECK ([is_active] IN (0, 1)),
      
      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE(),

      -- Unique constraint
      CONSTRAINT [UQ_dim_region] UNIQUE ([region])
    )
  END

-- =========================================================================================================
  -- ====================================== DIM COUNTRY ======================================
-- =========================================================================================================
  IF OBJECT_ID('[gold].[dim_country]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [gold].[dim_country];
    END

  BEGIN
    CREATE TABLE [gold].[dim_country] (
      [country_skey] INT IDENTITY(1,1) 
        CONSTRAINT [PK_dim_country] PRIMARY KEY,
      [country] NVARCHAR(50) NOT NULL,
      [region_skey] INT NOT NULL, -- SCD-2
      [is_active] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_country_is_active] CHECK ([is_active] IN (0, 1)),

      [start_date] DATE NULL,
      [end_date] DATE NULL,
      [is_current] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_country_is_current] CHECK ([is_current] IN (0, 1)),
      
      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE(),

      -- Unique constraint
      CONSTRAINT [UQ_dim_country] UNIQUE ([country]),

      -- Foreign key constraint
      CONSTRAINT [FK_dim_country_region] FOREIGN KEY ([region_skey]) 
        REFERENCES [gold].[dim_region]([region_skey])
    )
  END

-- =========================================================================================================
  -- ====================================== DIM STATE ======================================
-- =========================================================================================================
  IF OBJECT_ID('[gold].[dim_state]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [gold].[dim_state];
    END

  BEGIN
    CREATE TABLE [gold].[dim_state] (
      [state_skey] INT IDENTITY(1,1) 
        CONSTRAINT [PK_dim_state] PRIMARY KEY,
      [state] NVARCHAR(50) NOT NULL,
      [country_skey] INT NOT NULL, -- SCD-2
      [is_active] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_state_is_active] CHECK ([is_active] IN (0, 1)),

      [start_date] DATE NULL,
      [end_date] DATE NULL,
      [is_current] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_state_is_current] CHECK ([is_current] IN (0, 1)),
      
      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE(),

      -- Unique constraint
      CONSTRAINT [UQ_dim_state] UNIQUE ([state]),

      -- Foreign key constraint
      CONSTRAINT [FK_dim_state_country] FOREIGN KEY ([country_skey]) 
        REFERENCES [gold].[dim_country]([country_skey])
    )
  END

-- =========================================================================================================
  -- ====================================== DIM CITY ======================================
-- =========================================================================================================
  IF OBJECT_ID('[gold].[dim_city]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [gold].[dim_city];
    END

  BEGIN
    CREATE TABLE [gold].[dim_city] (
      [city_skey] INT IDENTITY(1,1) 
        CONSTRAINT [PK_dim_city] PRIMARY KEY,
      [city] NVARCHAR(50) NOT NULL,
      [state_skey] INT NOT NULL, -- SCD-2
      [is_active] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_city_is_active] CHECK ([is_active] IN (0, 1)),

      [start_date] DATE NULL,
      [end_date] DATE NULL,
      [is_current] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_city_is_current] CHECK ([is_current] IN (0, 1)),
      
      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE(),

      -- Unique constraint
      CONSTRAINT [UQ_dim_city] UNIQUE ([city]),

      -- Foreign key constraint
      CONSTRAINT [FK_dim_city_state] FOREIGN KEY ([state_skey]) 
        REFERENCES [gold].[dim_state]([state_skey])
    )
  END

-- =========================================================================================================
  -- ====================================== DIM POSTAL CODE ======================================
-- =========================================================================================================
  IF OBJECT_ID('[gold].[dim_postal_code]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [gold].[dim_postal_code];
    END

  BEGIN
    CREATE TABLE [gold].[dim_postal_code] (
      [postal_code_skey] INT IDENTITY(1,1) 
        CONSTRAINT [PK_dim_postal_code_] PRIMARY KEY,
      [postal_code] NVARCHAR(50) NOT NULL,
      [city_skey] INT NOT NULL, -- SCD-2
      [is_active] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_postal_code_is_active] CHECK ([is_active] IN (0, 1)),

      [start_date] DATE NULL,
      [end_date] DATE NULL,
      [is_current] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_postal_code_is_current] CHECK ([is_current] IN (0, 1)),
      
      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE(),

      -- Unique constraint
      CONSTRAINT [UQ_dim_postal_code] UNIQUE ([postal_code]),

      -- Foreign key constraint
      CONSTRAINT [FK_dim_postal_code_city] FOREIGN KEY ([city_skey]) 
        REFERENCES [gold].[dim_city]([city_skey])
    )
  END

-- =========================================================================================================
  -- ====================================== DIM LOCATION ======================================
-- =========================================================================================================
  IF OBJECT_ID('[gold].[dim_location]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [gold].[dim_location];
    END

  BEGIN
    CREATE TABLE [gold].[dim_location] (
      [location_skey] INT IDENTITY(1,1) 
        CONSTRAINT [PK_dim_location] PRIMARY KEY,
      [postal_code_skey] INT NOT NULL, -- SCD-2
      [is_active] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_location_is_active] CHECK ([is_active] IN (0, 1)),
      
      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE(),

      -- Foreign key constraint
      CONSTRAINT [FK_dim_location_postal_code] FOREIGN KEY ([postal_code_skey]) 
        REFERENCES [gold].[dim_postal_code]([postal_code_skey])
    )
  END


-- =========================================================================================================
-- =========================================================================================================
-- =========================================================================================================
  -- ====================================== DIM BRAND TIER ======================================
-- =========================================================================================================
  IF OBJECT_ID('[gold].[dim_brand_tier]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [gold].[dim_brand_tier];
    END

  BEGIN
    CREATE TABLE [gold].[dim_brand_tier] (
      [brand_tier_skey] INT IDENTITY(1,1) 
        CONSTRAINT [PK_dim_brand_tier] PRIMARY KEY,
      [brand_tier] NVARCHAR(50) NOT NULL,
      [is_active] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_brand_tier_is_active] CHECK ([is_active] IN (0, 1)),
      
      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE(),

      -- Unique constraint
      CONSTRAINT [UQ_dim_brand_tier] UNIQUE ([brand_tier])
    )
  END


-- =========================================================================================================
  -- ====================================== DIM BRAND NAME ======================================
-- =========================================================================================================
  IF OBJECT_ID('[gold].[dim_brand_name]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [gold].[dim_brand_name];
    END

  BEGIN
    CREATE TABLE [gold].[dim_brand_name] (
      [brand_name_skey] INT IDENTITY(1,1) 
        CONSTRAINT [PK_dim_brand_name] PRIMARY KEY,
      [brand_name] NVARCHAR(50) NOT NULL,
      [is_active] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_brand_name_is_active] CHECK ([is_active] IN (0, 1)),
      
      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE(),

      -- Unique constraint
      CONSTRAINT [UQ_dim_brand_name] UNIQUE ([brand_name])
    )
  END


-- =========================================================================================================
  -- ====================================== DIM BRAND COUNTRY ======================================
-- =========================================================================================================
  IF OBJECT_ID('[gold].[dim_brand_country]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [gold].[dim_brand_country];
    END

  BEGIN
    CREATE TABLE [gold].[dim_brand_country] (
      [brand_country_skey] INT IDENTITY(1,1) 
        CONSTRAINT [PK_dim_brand_country] PRIMARY KEY,
      [brand_country] NVARCHAR(50) NOT NULL,
      [is_active] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_brand_country_is_active] CHECK ([is_active] IN (0, 1)),
      
      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE(),

      -- Unique constraint
      CONSTRAINT [UQ_dim_brand_country] UNIQUE ([brand_country])
    )
  END


-- =========================================================================================================
  -- ====================================== DIM BRAND ======================================
-- =========================================================================================================
  IF OBJECT_ID('[gold].[dim_brand]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [gold].[dim_brand];
    END

  BEGIN
    CREATE TABLE [gold].[dim_brand] (
      [brand_skey] INT IDENTITY(1,1) 
        CONSTRAINT [PK_dim_brand] PRIMARY KEY,
      [brand_tier_skey] INT NOT NULL,
      [brand_name_skey] INT NOT NULL,
      [brand_country_skey] INT NOT NULL,
      [is_active] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_brand_is_active] CHECK ([is_active] IN (0, 1)),

      [start_date] DATE NULL,
      [end_date] DATE NULL,
      [is_current] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_brand_is_current] CHECK ([is_current] IN (0, 1)),
      
      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE(),

      -- Foreign key constraints
      CONSTRAINT [FK_dim_brand_btier] FOREIGN KEY ([brand_tier_skey]) 
        REFERENCES [gold].[dim_brand_tier]([brand_tier_skey]),
      CONSTRAINT [FK_dim_brand_bname] FOREIGN KEY ([brand_name_skey]) 
        REFERENCES [gold].[dim_brand_name]([brand_name_skey]),
      CONSTRAINT [FK_dim_brand_bcountry] FOREIGN KEY ([brand_country_skey]) 
        REFERENCES [gold].[dim_brand_country]([brand_country_skey])
    )
  END

-- =========================================================================================================
  -- ====================================== DIM MAIN CATEGORY  ======================================
-- =========================================================================================================
  IF OBJECT_ID('[gold].[dim_main_category]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [gold].[dim_main_category];
    END

  BEGIN
    CREATE TABLE [gold].[dim_main_category] (
      [main_category_skey] INT IDENTITY(1,1) 
        CONSTRAINT [PK_dim_main_category] PRIMARY KEY,
      [main_category] NVARCHAR(50) NOT NULL,
      [is_active] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_main_category_is_active] CHECK ([is_active] IN (0, 1)),

      [start_date] DATE NULL,
      [end_date] DATE NULL,
      [is_current] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_main_category_is_current] CHECK ([is_current] IN (0, 1)),
      
      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE(),

      -- Unique constraint
      CONSTRAINT [UQ_dim_main_category] UNIQUE ([main_category])
    )
  END

-- =========================================================================================================
  -- ====================================== DIM SUB CATEGORY ======================================
-- =========================================================================================================
  IF OBJECT_ID('[gold].[dim_sub_category]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [gold].[dim_sub_category];
    END

  BEGIN
    CREATE TABLE [gold].[dim_sub_category] (
      [sub_category_skey] INT IDENTITY(1,1) 
        CONSTRAINT [PK_dim_sub_category] PRIMARY KEY,
      [sub_category] NVARCHAR(50) NOT NULL,
      [main_category_skey] INT NOT NULL, -- SCD-2
      [is_active] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_sub_category_is_active] CHECK ([is_active] IN (0, 1)),

      [start_date] DATE NULL,
      [end_date] DATE NULL,
      [is_current] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_sub_category_is_current] CHECK ([is_current] IN (0, 1)),
      
      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE(),

      -- Foreign key constraints
      CONSTRAINT [FK_dim_sub_category_main_category] FOREIGN KEY ([main_category_skey]) 
        REFERENCES [gold].[dim_main_category]([main_category_skey])
    )
  END


-- =========================================================================================================
-- =========================================================================================================
-- =========================================================================================================
  -- ====================================== DIM PAYMENT SOURCE ======================================
-- =========================================================================================================
  IF OBJECT_ID('[gold].[dim_payment_source]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [gold].[dim_payment_source];
    END

  BEGIN
    CREATE TABLE [gold].[dim_payment_source] (
      [payment_source_skey] INT IDENTITY(1,1) 
        CONSTRAINT [PK_dim_payment_source] PRIMARY KEY,
      [payment_source] NVARCHAR(50) NOT NULL,
      [is_active] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_payment_source_is_active] CHECK ([is_active] IN (0, 1)),
      
      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE(),

      -- Unique constraint
      CONSTRAINT [UQ_dim_payment_source] UNIQUE ([payment_source])
    )
  END

-- =========================================================================================================
  -- ====================================== DIM LEAD TYPE ======================================
-- =========================================================================================================
  IF OBJECT_ID('[gold].[dim_lead_type]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [gold].[dim_lead_type];
    END

  BEGIN
    CREATE TABLE [gold].[dim_lead_type] (
      [lead_type_skey] INT IDENTITY(1,1) 
        CONSTRAINT [PK_dim_lead_type] PRIMARY KEY,
      [lead_type] NVARCHAR(50) NOT NULL,
      [is_active] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_lead_type_is_active] CHECK ([is_active] IN (0, 1)),
      
      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE(),

      -- Unique constraint
      CONSTRAINT [UQ_dim_lead_type] UNIQUE ([lead_type])
    )
  END


-- =========================================================================================================
  -- ====================================== DIM ORDER STATUS ======================================
-- =========================================================================================================
  IF OBJECT_ID('[gold].[dim_order_status]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [gold].[dim_order_status];
    END

  BEGIN
    CREATE TABLE [gold].[dim_order_status] (
      [order_status_skey] INT IDENTITY(1,1) 
        CONSTRAINT [PK_dim_order_status] PRIMARY KEY,
      [order_status] NVARCHAR(50) NOT NULL,
      [is_active] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_order_status_is_active] CHECK ([is_active] IN (0, 1)),

      [start_date] DATE NULL,
      [end_date] DATE NULL,
      [is_current] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_order_status_is_current] CHECK ([is_current] IN (0, 1)),
      
      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE(),

      -- Unique constraint
      CONSTRAINT [UQ_dim_order_status] UNIQUE ([order_status])
    )
  END


-- =========================================================================================================
-- =========================================================================================================
-- =========================================================================================================
  -- ====================================== DIM DELIVERY ESTIMATE ======================================
-- =========================================================================================================
  IF OBJECT_ID('[gold].[dim_delivery_estimate]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [gold].[dim_delivery_estimate];
    END

  BEGIN
    CREATE TABLE [gold].[dim_delivery_estimate] (
      [delivery_estimate_skey] INT IDENTITY(1,1) 
        CONSTRAINT [PK_dim_delivery_estimate] PRIMARY KEY,
      [delivery_estimate] NVARCHAR(50) NOT NULL,
      [is_active] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_delivery_estimate_is_active] CHECK ([is_active] IN (0, 1)),
      
      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE(),

      -- Unique constraint
      CONSTRAINT [UQ_dim_delivery_estimate] UNIQUE ([delivery_estimate])
    )
  END


-- =========================================================================================================
-- =========================================================================================================
-- =========================================================================================================
  -- ====================================== SHIPPING_TYPE DIMENSION TABLE ======================================
-- =========================================================================================================
  IF OBJECT_ID('[gold].[dim_shipping_type]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [gold].[dim_shipping_type];
    END

  BEGIN
    CREATE TABLE [gold].[dim_shipping_type] (
      [shipping_type_skey] INT IDENTITY(1,1) 
        CONSTRAINT [PK_dim_shipping_type] PRIMARY KEY,
      [shipping_type] NVARCHAR(50) NOT NULL,
      [delivery_estimate_skey] INT NOT NULL,
      [is_active] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_shipping_type_is_active] CHECK ([is_active] IN (0, 1)),
      
      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE(),
      
      -- Foreign key constraint
      CONSTRAINT [FK_dim_shipping_type_delivery_estimate] FOREIGN KEY ([delivery_estimate_skey]) 
        REFERENCES [gold].[dim_delivery_estimate]([delivery_estimate_skey])
    )
  END


-- =========================================================================================================
-- =========================================================================================================
-- =========================================================================================================
-- ======================================= CUSTOMER DIMENSION TABLE =======================================
-- =========================================================================================================
  IF OBJECT_ID('[gold].[dim_customer]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [gold].[dim_customer];
    END

  BEGIN
    CREATE TABLE [gold].[dim_customer] (
      [customer_skey] INT IDENTITY(1,1) 
        CONSTRAINT [PK_dim_customer] PRIMARY KEY,
      [customer_id] INT NOT NULL,
      [signup_date] DATE NOT NULL,
      [gender_skey] INT NOT NULL,

      [customer_dob] DATE NOT NULL,
      [customer_age] INT NULL
        CONSTRAINT [CHK_dim_customer_customer_age] CHECK ([customer_age] >= 0 AND [customer_age] <= 120),

      [first_name] NVARCHAR(50) NULL,
      [middle_name] NVARCHAR(50) NULL,
      [last_name] NVARCHAR(50) NULL,
      [marital_status_skey] INT NOT NULL,

      [customer_type_skey] INT NOT NULL, -- SCD-3
      [prev_customer_type_skey] INT NULL DEFAULT NULL,
      [account_status_skey] INT, -- SCD-3
      [prev_account_status_skey] INT NULL DEFAULT NULL,

      [location_skey] INT NOT NULL,
      [email] NVARCHAR(100),
      [phone] NVARCHAR(50),

      [start_date] DATE NULL,
      [end_date] DATE NULL,
      [is_current] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_customer_is_current] CHECK ([is_current] IN (0, 1)),

      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE(),

      -- Unique constraint
      -- CONSTRAINT [UQ_dim_customer] UNIQUE ([customer_id]),

      -- Foreign key constraints
      CONSTRAINT [FK_dim_customer_gender] FOREIGN KEY ([gender_skey]) 
        REFERENCES [gold].[dim_gender]([gender_skey]),
      CONSTRAINT [FK_dim_customer_marital_status] FOREIGN KEY ([marital_status_skey]) 
        REFERENCES [gold].[dim_marital_status]([marital_status_skey]),
      CONSTRAINT [FK_dim_customer_customer_type] FOREIGN KEY ([customer_type_skey]) 
        REFERENCES [gold].[dim_customer_type]([customer_type_skey]),
      CONSTRAINT [FK_dim_customer_account_status] FOREIGN KEY ([account_status_skey]) 
        REFERENCES [gold].[dim_account_status]([account_status_skey]),
      CONSTRAINT [FK_dim_customer_location] FOREIGN KEY ([location_skey]) 
        REFERENCES [gold].[dim_location]([location_skey])
    )
  END


-- =========================================================================================================
-- =========================================================================================================
-- =========================================================================================================
-- ======================================= PRODUCT DIMENSION TABLES =======================================
-- =========================================================================================================
  IF OBJECT_ID('[gold].[dim_product]', 'U') IS NOT NULL
    BEGIN
      DROP TABLE [gold].[dim_product]
    END

  BEGIN
    CREATE TABLE [gold].[dim_product] (
      [product_skey] INT IDENTITY(1,1) 
        CONSTRAINT [PK_dim_product] PRIMARY KEY,
      [product_id] NVARCHAR(50) NOT NULL, -- SCD-0
      [brand_skey] INT NOT NULL, -- SCD-1
      [product_name] NVARCHAR(100) NOT NULL, -- SCD-1
      [product_description] NVARCHAR(1000) NULL, -- SCD-1

      [rating] DECIMAL(3,2) NULL, -- SCD-3
      [prev_rating] DECIMAL(3,2) NULL DEFAULT NULL,
      [no_of_ratings] INT NULL, -- SCD-3
      [prev_no_of_ratings] INT NULL DEFAULT NULL,

      [sub_category_skey] INT NULL, -- SCD-2
      [discount_percent] DECIMAL(10,2) NULL, -- SCD-2
      [actual_price] DECIMAL(10,2) NULL DEFAULT 1, -- SCD-2

      [start_date] DATE NULL,
      [end_date] DATE NULL,
      [is_current] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_product_is_current] CHECK ([is_current] IN (0, 1)),
      
      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE(),

      -- Unique constraint
      CONSTRAINT [UQ_dim_product] UNIQUE ([product_id]),

      -- Foreign Keys
      CONSTRAINT [FK_dim_product_brand_skey] FOREIGN KEY ([brand_skey]) 
        REFERENCES [gold].[dim_brand]([brand_skey]),
      CONSTRAINT [FK_dim_product_sub_category_skey] FOREIGN KEY ([sub_category_skey]) 
        REFERENCES [gold].[dim_sub_category]([sub_category_skey])
    )
  END


-- =========================================================================================================
-- =========================================================================================================
-- =========================================================================================================
-- ======================================= ORDER DIMENSION TABLES =======================================
-- =========================================================================================================
  IF OBJECT_ID('[gold].[dim_order]', 'U') IS NOT NULL
  BEGIN
    DROP TABLE [gold].[dim_order];
  END

  BEGIN
    CREATE TABLE [gold].[dim_order] (
      [order_skey] INT IDENTITY(1,1) 
        CONSTRAINT [PK_dim_order] PRIMARY KEY,
      [order_id] NVARCHAR(50) NOT NULL,
      [shipping_type_skey] INT NOT NULL,
      [payment_source_skey] INT NOT NULL,
      [lead_type_skey] INT NOT NULL,

      [order_date] DATETIME NOT NULL,
      [expected_delivery_date] DATETIME NOT NULL,
      [shipping_date] DATETIME NULL,
      [delivery_date] DATETIME NULL,
      [return_date] DATETIME NULL,
      [refund_date] DATETIME NULL,

      [has_coupon] BIT NOT NULL,
      [coupon_code] NVARCHAR(50) NULL,

      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE(),

      -- Unique constraint
      CONSTRAINT [UQ_dim_order] UNIQUE ([order_id]),

      -- Foreign Keys
      CONSTRAINT [FK_dim_order_shipping_type_skey] FOREIGN KEY ([shipping_type_skey]) 
        REFERENCES [gold].[dim_shipping_type]([shipping_type_skey]),
      CONSTRAINT [FK_dim_order_payment_source_skey] FOREIGN KEY ([payment_source_skey]) 
        REFERENCES [gold].[dim_payment_source]([payment_source_skey]),
      CONSTRAINT [FK_dim_order_lead_type_skey] FOREIGN KEY ([lead_type_skey]) 
        REFERENCES [gold].[dim_lead_type]([lead_type_skey])
    )
  END


-- =========================================================================================================
-- =========================================================================================================
-- =========================================================================================================
-- ======================================= ORDER_PRODUCT DIMENSION TABLES =======================================
-- =========================================================================================================
  IF OBJECT_ID('[gold].[dim_order_product]', 'U') IS NOT NULL
  BEGIN
    DROP TABLE [gold].[dim_order_product];
  END

  BEGIN
    CREATE TABLE [gold].[dim_order_product] (
      [order_product_skey] INT IDENTITY(1,1) 
        CONSTRAINT [PK_dim_order_product] PRIMARY KEY,
      [order_skey] INT NOT NULL,
      [product_skey] INT NOT NULL,

      [quantity] INT NOT NULL,
      [unit_price] DECIMAL(10,2) NOT NULL,

      [discount_percent] DECIMAL(10,2) NOT NULL,
      [actual_price] DECIMAL(10,2) NULL,
      
      [is_gift] BIT NOT NULL,
      [gift_message] NVARCHAR(500) NULL,
      
      [order_status_skey] INT NOT NULL,
      [current_shipping_date] DATETIME NULL,

      [start_date] DATE NULL,
      [end_date] DATE NULL,
      [is_current] BIT DEFAULT 1
        CONSTRAINT [CHK_dim_op_is_current] CHECK ([is_current] IN (0, 1)),
      
      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE(),

      -- Foreign Keys      
      CONSTRAINT [FK_dim_op_order] FOREIGN KEY ([order_skey]) 
        REFERENCES [gold].[dim_order]([order_skey]),
      CONSTRAINT [FK_dim_op_product] FOREIGN KEY ([product_skey]) 
        REFERENCES [gold].[dim_product]([product_skey]),
      CONSTRAINT [FK_dim_order_order_status_skey] FOREIGN KEY ([order_status_skey]) 
        REFERENCES [gold].[dim_order_status]([order_status_skey])
    )
  END


-- =========================================================================================================
-- =========================================================================================================
-- =========================================================================================================
-- ======================================= FACT SALES TABLE =======================================
-- =========================================================================================================
  IF OBJECT_ID('[gold].[fact_sales]', 'U') IS NOT NULL
  BEGIN
    DROP TABLE [gold].[fact_sales];
  END

  BEGIN
    CREATE TABLE [gold].[fact_sales] (
      [sales_skey] INT IDENTITY(1,1) 
        CONSTRAINT [PK_dim_sales] PRIMARY KEY,
      [sales_id] INT NOT NULL,
      [order_product_skey] INT NOT NULL,
      [customer_skey] INT NOT NULL,

      [quantity] INT NOT NULL,
      [unit_price] DECIMAL(10,2) NOT NULL,
      [discount_percent] DECIMAL(10,2) NOT NULL,

      [discount_amount] DECIMAL(10,2) NOT NULL 
        CONSTRAINT [CHK_fact_sales_discount_amount] CHECK ([discount_amount] >= 0),
      [total_amount] DECIMAL(10,2) NOT NULL
        CONSTRAINT [CHK_fact_sales_total_amount] CHECK ([total_amount] >= 0),

      [is_returned] BIT NOT NULL 
        CONSTRAINT [CHK_fact_sales_is_returned] CHECK ([is_returned] IN (0, 1)) DEFAULT 0,

      -- metadata for audit
      [batch_id] INT,
      [load_timestamp] DATETIME DEFAULT GETDATE(),

      -- Foreign keys
      CONSTRAINT [FK_fact_sales_order_product] FOREIGN KEY ([order_product_skey]) 
        REFERENCES [gold].[dim_order_product]([order_product_skey]),
      CONSTRAINT [FK_fact_sales_customer] FOREIGN KEY ([customer_skey]) 
        REFERENCES [gold].[dim_customer]([customer_skey])
    )
  END

END;
-- =========================================================================================================

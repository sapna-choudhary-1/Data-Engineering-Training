-- =========================================================================================================
-- Description:
-- This stored procedure loads data into the Bronze layer tables from the bronze layer.
-- It truncates the existing staging data and reloads from [bronze] tables.
-- This aligns with the schema defined in [staging].[create_tables].
-- Usage: EXEC [staging].[usp_load]
-- =========================================================================================================
USE [associatetraining];

CREATE OR ALTER PROCEDURE [staging].[usp_load] AS
BEGIN

  IF EXISTS (SELECT 1 FROM [staging].[order])
  BEGIN
    TRUNCATE TABLE [staging].[order];
  END;
  IF EXISTS (SELECT 1 FROM [staging].[shipping_type])
  BEGIN
    TRUNCATE TABLE [staging].[shipping_type];
  END;
  IF EXISTS (SELECT 1 FROM [staging].[product])
  BEGIN
    TRUNCATE TABLE [staging].[product];
  END;
  IF EXISTS (SELECT 1 FROM [staging].[customer])
  BEGIN
    TRUNCATE TABLE [staging].[customer];
  END;
  
  
  
  -- ==================== CUSTOMER ====================
  BEGIN
    WITH last_load_timestamp AS (
      SELECT MAX(load_timestamp) AS last_load
      FROM [staging].[customer]
    )
    INSERT INTO [staging].[customer] (
      [customer_id], [signup_date], [gender], 
      [customer_dob], [customer_name], [marital_status], 
      [email], [phone], 
      [customer_type], [account_status],
      [region], [country], [state], [city], [postal_code]
    )
    SELECT
      [staging].[fnClean] (customer_id) AS [customer_id],

      COALESCE(TRY_CAST(signup_date AS DATETIME), '1900-01-01') AS signup_date,
      CASE 
        WHEN [staging].[fnClean] (gender) LIKE 'M%' THEN 'Male'
        WHEN [staging].[fnClean] (gender) LIKE 'F%' THEN 'Female'
        WHEN [staging].[fnClean] (gender) LIKE 'O%' THEN 'Other'
        WHEN gender IS NULL OR gender = '' THEN 'Unknown'
        ELSE [staging].[fnClean] (gender)
      END AS [gender],

	    CASE
        WHEN TRY_CAST(customer_dob AS DATE) IS NOT NULL THEN CAST(customer_dob AS DATE)
        ELSE NULL
      END AS [customer_dob],

      [staging].[fnClean] (customer_name) AS [customer_name], 

      CASE 
        WHEN [staging].[fnClean] (marital_status) LIKE 'S%' THEN 'Single'
        WHEN [staging].[fnClean] (marital_status) LIKE 'M%' THEN 'Married'
        WHEN marital_status IS NULL OR marital_status = '' THEN 'Unknown'
        ELSE [staging].[fnClean] (marital_status)
      END AS [marital_status],

      [staging].[fnClean&ValidateEmail] (email) AS [email],
      [staging].[fnRemoveSpecialChars] (phone) AS [phone],
      
      CASE 
        WHEN [staging].[fnClean] (customer_type) LIKE 'P%' THEN 'Prime'
        WHEN [staging].[fnClean] (customer_type) LIKE 'N%' THEN 'Non-prime'
        WHEN customer_type IS NULL OR customer_type = '' THEN 'Unknown'
        ELSE [staging].[fnClean] (customer_type)
      END AS [customer_type],
      CASE 
        WHEN account_status IS NULL OR account_status = '' THEN 'Unknown'
        ELSE [staging].[fnClean] (account_status)
      END AS [account_status],

      CASE 
        WHEN region IS NULL OR region = '' THEN 'Unknown'
        ELSE [staging].[fnClean] (region)
      END AS [region],
      CASE 
        WHEN country IS NULL OR country = '' THEN 'Unknown'
        ELSE [staging].[fnClean] (country)
      END AS [country],
      CASE 
        WHEN state IS NULL OR state = '' THEN 'Unknown'
        ELSE [staging].[fnClean] (state)
        -- [staging].[fnTranslation] ([state])
      END AS [state],
      CASE 
        WHEN city IS NULL OR city = '' THEN 'Unknown'
        ELSE [staging].[fnClean] (city)
      END AS [city],
      CASE 
        WHEN [postal code] IS NULL OR [postal code] = '' THEN 'Unknown'
        ELSE [staging].[fnClean] ([postal code])
      END AS [postal_code]

    FROM [bronze].[customer]
    -- Ignore the customer's data if customer_id is NULL (aconsidering it as a false data):
    WHERE 
      customer_id IS NOT NULL 
      AND customer_id <> ''

  END

  -- ==================== PRODUCT ====================
  BEGIN
    WITH ranked_products  
    AS (
      SELECT
      *,
        ROW_NUMBER() OVER (PARTITION BY [staging].[fnClean](product_id) ORDER BY (SELECT 1)) AS row_num
      FROM [bronze].[product]
      WHERE product_id IS NOT NULL 
        AND product_id <> ''
    )
    INSERT INTO [staging].[product] (
      [product_id], [product_name],
      [brand_tier], [brand_name], [brand_country],
      [main_category], [sub_category], 
      [discount_percent], [actual_price],
      [rating], [no_of_ratings]
    )
    SELECT
--      TOP 100
      [staging].[fnClean] (rp.product_id),
      CASE 
        WHEN product_name IS NULL OR product_name = '' THEN 'Unknown'
        ELSE product_name
      END AS [product_name],

      CASE 
        WHEN brand_tier IS NULL OR brand_tier = '' THEN 'Unknown'
        ELSE [staging].[fnClean] (brand_tier)
      END AS [brand_tier],
      CASE 
        WHEN brand_name IS NULL OR brand_name = '' THEN 'Unknown'
        ELSE [staging].[fnClean] (brand_name)
      END AS [brand_name],
      CASE 
        WHEN brand_country IS NULL OR brand_country = '' THEN 'Unknown'
        ELSE [staging].[fnClean] (brand_country)
      END AS [brand_country],
      CASE 
        WHEN main_category IS NULL OR main_category = '' THEN 'Unknown'
        ELSE [staging].[fnClean] (main_category)
      END AS [main_category],
      CASE 
        WHEN sub_category IS NULL OR sub_category = '' THEN 'Unknown'
        ELSE [staging].[fnClean] (sub_category)
      END AS [sub_category],

      CASE 
        WHEN rp.discount_percent IS NULL OR rp.discount_percent = '' OR TRY_CAST(rp.discount_percent AS DECIMAL(10,2)) < 0 THEN 0
        ELSE CAST(rp.discount_percent AS DECIMAL(10, 2))
      END AS discount_percent,
      CASE 
        WHEN rp.actual_price IS NULL OR rp.actual_price = '' OR TRY_CAST(rp.actual_price AS DECIMAL(10,2)) < 0 THEN 0
        ELSE CAST(rp.actual_price AS DECIMAL(10, 2))
      END AS actual_price,

      CASE 
        WHEN rp.rating IS NULL OR rp.rating = '' OR TRY_CAST(rp.rating AS DECIMAL(3,2))  < 0 THEN 0
        ELSE CAST(rp.rating AS DECIMAL(3, 2))
      END AS rating,
      CASE 
        WHEN rp.[no of ratings] IS NULL OR rp.[no of ratings] = '' OR TRY_CAST(rp.[no of ratings] AS DECIMAL(3,2)) < 0 THEN 0
        ELSE CAST(CAST(rp.[no of ratings] AS DECIMAL(10,0)) AS INT)
      END AS no_of_ratings

    FROM ranked_products rp
    WHERE rp.row_num = 1

  END

  -- ==================== SHIPPING TYPE ====================
  BEGIN
    INSERT INTO [staging].[shipping_type] (
      [shipping_type], [delivery_estimate]
    )
    SELECT
      [staging].[fnClean] ([shipping_type]) AS [shipping_type],
      [staging].[fnClean] ([delivery_estimate]) AS [delivery_estimate]
      -- CASE 
      --   WHEN [shipping_type] IS NULL OR [shipping_type] = '' THEN 'Unknown'
      --   ELSE [staging].[fnClean] ([shipping_type])
      -- END AS [shipping_type],
      -- CASE
      --   WHEN [delivery_estimate] IS NULL OR [delivery_estimate] = '' THEN 'Unknown'
      --   ELSE [staging].[fnClean] ([delivery_estimate])
      -- END AS [delivery_estimate]
    FROM [bronze].[shipping_type]
  END

  -- ==================== ORDER ====================
  BEGIN
    WITH ranked_orders 
    AS (
      SELECT
      *,
        ROW_NUMBER() OVER (PARTITION BY [staging].[fnClean](order_id) ORDER BY (SELECT 1)) AS row_num
      FROM [bronze].[order]
      WHERE 
        order_id IS NOT NULL AND order_id <> ''
        -- AND product_id IS NOT NULL AND product_id <> ''
    )
    INSERT INTO [staging].[order] (
      [order_id], [customer_id], [product_id],
      -- [shipping_type_id], 
      [shipping_type], [payment_source], [lead_type], [order_status],
      [order_date], [expected_delivery_date], [shipping_date], [delivery_date], [return_date], [refund_date], 
      [quantity], [unit_price], 
      [is_gift], [gift_message], [has_coupon], [coupon_code]
    )
    SELECT
      [staging].[fnClean] (ro.order_id) AS [order_id],
      [staging].[fnClean] (ro.customer_id) AS [customer_id],
      [staging].[fnClean] (p.product_id) AS [product_id],
      -- [staging].[fnClean] (st.shipping_type_id) AS [shipping_type_id],
      CASE 
        WHEN shipping_type IS NULL OR shipping_type = '' THEN 'Unknown'
        ELSE [staging].[fnClean] (shipping_type)
      END AS [shipping_type],

      CASE 
        WHEN ro.payment_src IS NULL OR ro.payment_src = '' THEN 'Unknown'
        ELSE [staging].[fnClean] (ro.payment_src)
      END AS [payment_source],
      CASE 
        WHEN ro.lead_type IS NULL OR ro.lead_type = '' THEN 'Unknown'
        ELSE [staging].[fnClean] (ro.lead_type)
      END AS [lead_type],
      CASE 
        WHEN ro.order_status IS NULL OR ro.order_status = '' THEN 'Unknown'
        ELSE [staging].[fnClean] (ro.order_status)
      END AS [order_status],
      
      COALESCE(TRY_CAST(ro.order_date AS DATETIME), '1900-01-01') AS [order_date],
      COALESCE(TRY_CAST(ro.expected_delivery_date AS DATETIME), '1900-01-01') AS [expected_delivery_date],
      TRY_CAST(ro.shipping_date AS DATETIME) AS [shipping_date],
      TRY_CAST(ro.delivery_date AS DATETIME) AS [delivery_date],
      TRY_CAST(ro.return_date AS DATETIME) AS [return_date],
      TRY_CAST(ro.refund_date AS DATETIME) AS [refund_date],

      CASE 
        WHEN ro.quantity IS NULL OR ro.quantity = '' OR TRY_CAST(ro.quantity AS INT) < 0 THEN 0
        ELSE TRY_CAST(ro.quantity AS INT)
      END AS [quantity],
      CASE 
        WHEN ro.unit_price IS NULL OR ro.unit_price = '' OR TRY_CAST(ro.unit_price AS DECIMAL(10,2)) < 0 THEN 0
        ELSE TRY_CAST(ro.unit_price AS DECIMAL(10,2))
      END AS [unit_price], 

      CASE 
        WHEN TRY_CAST(ro.is_gift AS BIT) = 1 AND ISNULL(TRIM(ro.gift_message), '') <> '' THEN 1
        ELSE 0
      END AS [is_gift],
      CASE 
        WHEN TRY_CAST(ro.is_gift AS BIT) = 1 AND ISNULL(TRIM(ro.gift_message), '') <> '' THEN TRIM(ro.gift_message)
        ELSE ''
      END AS [gift_message],
      
      CASE 
        WHEN TRY_CAST(ro.has_coupon AS INT) = 1 AND ISNULL(TRIM(ro.coupon_code), '') <> '' THEN 1
        ELSE 0
      END AS [has_coupon],
      CASE 
        WHEN TRY_CAST(ro.has_coupon AS INT) = 1 AND ISNULL(TRIM(ro.coupon_code), '') <> '' THEN TRIM(ro.coupon_code)
        ELSE ''
      END AS [coupon_code]

    FROM ranked_orders ro
    LEFT JOIN [staging].[product] p
      ON [staging].[fnClean] (ro.product_id) = p.product_id
    LEFT JOIN [staging].[customer] c
      ON [staging].[fnClean] (ro.customer_id) = c.customer_id
    -- LEFT JOIN [staging].[shipping_type] st
    --   ON [staging].[fnClean] (ro.shipping_type) = st.shipping_type

    WHERE ro.row_num = 1
    ORDER BY 
    	[staging].[fnClean] (ro.order_id),
     	[staging].[fnClean] (ro.product_id)

  END

END;

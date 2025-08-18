-- =========================================================================================================
-- Description:
-- This stored procedure loads data into the Bronze layer tables from the raw layer.
-- It truncates the existing bronze data and reloads from [raw] tables.
-- This aligns with the schema defined in [bronze].[create_tables].
-- Usage: EXEC [bronze].[usp_load]
-- =========================================================================================================
USE [associatetraining];

CREATE OR ALTER PROCEDURE [bronze].[usp_load] AS
BEGIN

  -- ==================== CUSTOMER ====================
  IF EXISTS (SELECT 1 FROM [bronze].[customer])
  BEGIN
    TRUNCATE TABLE [bronze].[customer];
  END;
  BEGIN
    INSERT INTO [bronze].[customer] (
      [customer_id], [signup_date], [gender], [customer_dob],
      [customer_name], [marital_status], [customer_type], [account_status],
      [country], [state], [city], [postal code], [region], [email], [phone]
    )
    SELECT
      [customer_id], [signup_date], [gender], [customer_dob],
      [customer_name], [marital_status], [customer_type], [account_status],
      [country], [state], [city], [postal code], [region], [email], [phone]
    FROM [raw].[customer];
  END

  -- ==================== PRODUCT ====================
  IF EXISTS (SELECT 1 FROM [bronze].[product])
  BEGIN
    TRUNCATE TABLE [bronze].[product];
  END;
  BEGIN
    INSERT INTO [bronze].[product] (
      [product_id], [product_name],
      [brand_tier], [brand_name], [brand_country],
      [main_category], [sub_category], [discount_percent], [actual_price],
      [rating], [no of ratings]
    )
    SELECT
      [product_id], [product_name],
      [brand_tier], [brand_name], [brand_country],
      [main_category], [sub_category], [discount_percent], [actual_price],
      [rating], [no of ratings]
    FROM [raw].[product];
  END

  -- ==================== ORDER ====================
  IF EXISTS (SELECT 1 FROM [bronze].[order])
  BEGIN
    TRUNCATE TABLE [bronze].[order];
  END;
  BEGIN
    INSERT INTO [bronze].[order] (
      [order_id], [customer_id], [product_id],
      [shipping_type], [payment_src], [lead_type], [order_status],
      [order_date], [shipping_date], [expected_delivery_date], [delivery_date],
      [return_date], [refund_date], [quantity], [unit_price], 
      [is_gift], [gift_message], [has_coupon], [coupon_code]
    )
    SELECT
      [order_id], [customer_id], [product_id],
      [shipping_type], [payment_src], [lead_type], [order_status],
      [order_date], [shipping_date], [expected_delivery_date], [delivery_date],
      [return_date], [refund_date], [quantity], [unit_price], 
      [is_gift], [gift_message], [has_coupon], [coupon_code]
    FROM [raw].[order];
  END

  -- ==================== SHIPPING TYPE ====================
  IF EXISTS (SELECT 1 FROM [bronze].[shipping_type])
  BEGIN
    TRUNCATE TABLE [bronze].[shipping_type];
  END;
  BEGIN
    INSERT INTO [bronze].[shipping_type] (
      [shipping_type_id], [shipping_type], [delivery_estimate]
    )
    SELECT
      [shipping_type_id], [shipping_type], [delivery_estimate]
    FROM [raw].[shipping_type];
  END
END;



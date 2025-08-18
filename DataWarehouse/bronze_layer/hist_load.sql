/*
=============================================================================================
Description:
    - This stored procedure loads data into the Bronze layer of the Data Warehouse from CSV files.
    - It truncates existing data in the tables before loading new data
    - Uses INSERT INTO ... SELECT FROM to move data from the raw layer
    - Prints the duration of each loading operation and the total duration at the end

Usage Example:
    - EXEC [bronze].[bronze_load]
=============================================================================================
*/

USE [associatetraining];

CREATE OR ALTER PROCEDURE [bronze].[usp_load_hist] AS
BEGIN
	DECLARE @batch_id INT
	INSERT INTO [bronze].[batch_audit] ([load_name])
	VALUES ('Bronze History Load')
	SET @batch_id = SCOPE_IDENTITY()
	SELECT @batch_id

    -- ==================== CUSTOMER TABLE ====================
    -- Append Current to Historical
    INSERT INTO [bronze].[customer_hist] (
        [customer_id], [signup_date], [gender], [customer_dob],
        [customer_name], [marital_status],
        [customer_type], [account_status],
        [country], [state], [city], [postal code], [region], [email], [phone],
        [batch_id]
    )
    SELECT 
        [customer_id], [signup_date], [gender], [customer_dob],
        [customer_name], [marital_status],
        [customer_type], [account_status],
        [country], [state], [city], [postal code], [region], [email], [phone], 
        @batch_id
    FROM [bronze].[customer]

    -- Truncate current
    TRUNCATE TABLE [bronze].[customer]

    -- ==================== PRODUCT TABLE ====================
    INSERT INTO [bronze].[product_hist] (
        [product_id], [product_name],
        [brand_tier], [brand_name], [brand_country],
        [main_category], [sub_category], [discount_percent], [actual_price],
        [rating], [no of ratings], 
        [batch_id]
    )
    SELECT
        [product_id], [product_name],
        [brand_tier], [brand_name], [brand_country],
        [main_category], [sub_category], [discount_percent], [actual_price],
        [rating], [no of ratings], 
        @batch_id
    FROM [bronze].[product]

    TRUNCATE TABLE [bronze].[product]

    -- ==================== ORDER TABLE ====================
    INSERT INTO [bronze].[order_hist] (
        [order_id], [customer_id], [product_id],
        [shipping_type], [payment_src], [lead_type], [order_status],
        [order_date], [shipping_date], [expected_delivery_date], [delivery_date],
        [return_date], [refund_date], [quantity], [unit_price], 
        [is_gift], [gift_message], [has_coupon], [coupon_code],
        [batch_id]
    )
    SELECT
        [order_id], [customer_id], [product_id],
        [shipping_type], [payment_src], [lead_type], [order_status],
        [order_date], [shipping_date], [expected_delivery_date], [delivery_date],
        [return_date], [refund_date], [quantity], [unit_price], 
        [is_gift], [gift_message], [has_coupon], [coupon_code],
        @batch_id
    FROM [bronze].[order]

    TRUNCATE TABLE [bronze].[order]

    -- ==================== SHIPPING TYPE TABLE ====================
    INSERT INTO [bronze].[shipping_type_hist] (
        [shipping_type_id], [shipping_type], [delivery_estimate],
        [batch_id]
    )
    SELECT
        [shipping_type_id], [shipping_type], [delivery_estimate], 
        @batch_id
    FROM [bronze].[shipping_type]

    TRUNCATE TABLE [bronze].[shipping_type]
END
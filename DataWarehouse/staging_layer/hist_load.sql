/*
=============================================================================================
Description:
    - This stored procedure loads data into the Bronze layer of the Data Warehouse from CSV files.
    - It truncates existing data in the tables before loading new data
    - Uses INSERT INTO ... SELECT FROM to move data from the raw layer
    - Prints the duration of each loading operation and the total duration at the end
g
Usage Example:
    - EXEC [staging].[staging_load]
=============================================================================================
*/

USE [associatetraining];

CREATE OR ALTER PROCEDURE [staging].[usp_load_hist] AS
BEGIN
	DECLARE @batch_id INT
	INSERT INTO [staging].[batch_audit] ([load_name])
	VALUES ('Staging History Load')
	SET @batch_id = SCOPE_IDENTITY()
	SELECT @batch_id

    -- ==================== CUSTOMER TABLE ====================
    -- Append Current to Historical
    INSERT INTO [staging].[customer_hist] (
        [customer_id], [signup_date], [gender], 
        [customer_dob], [customer_name], [marital_status], 
        [email], [phone], 
        [customer_type], [account_status],
        [region], [country], [state], [city], [postal_code],
        [batch_id]
    )
    SELECT 
        [customer_id], [signup_date], [gender], 
        [customer_dob], [customer_name], [marital_status], 
        [email], [phone], 
        [customer_type], [account_status],
        [region], [country], [state], [city], [postal_code],
        @batch_id
    FROM [staging].[customer]

    -- ==================== PRODUCT TABLE ====================
    INSERT INTO [staging].[product_hist] (
        [product_id], [product_name],
        [brand_tier], [brand_name], [brand_country],
        [main_category], [sub_category], 
        [discount_percent], [actual_price],
        [rating], [no_of_ratings],
        [batch_id]
    )
    SELECT
        [product_id], [product_name],
        [brand_tier], [brand_name], [brand_country],
        [main_category], [sub_category], 
        [discount_percent], [actual_price],
        [rating], [no_of_ratings],
        @batch_id
    FROM [staging].[product]

    -- ==================== SHIPPING TYPE TABLE ====================
    INSERT INTO [staging].[shipping_type_hist] (
        [shipping_type], [delivery_estimate],
        [batch_id]
    )
    SELECT
        [shipping_type], [delivery_estimate],
        @batch_id
    FROM [staging].[shipping_type]


    -- ==================== ORDER TABLE ====================
    INSERT INTO [staging].[order_hist] (
        [order_id], [customer_id], [product_id],
        [shipping_type], [payment_source], [lead_type], [order_status],
        [order_date], [expected_delivery_date], [shipping_date], [delivery_date], [return_date], [refund_date], 
        [quantity], [unit_price], 
        [is_gift], [gift_message], [has_coupon], [coupon_code],
        [batch_id]
    )
    SELECT
        [order_id], [customer_id], [product_id],
        [shipping_type], [payment_source], [lead_type], [order_status],
        [order_date], [expected_delivery_date], [shipping_date], [delivery_date], [return_date], [refund_date], 
        [quantity], [unit_price], 
        [is_gift], [gift_message], [has_coupon], [coupon_code],
        @batch_id
    FROM [staging].[order]


    DELETE FROM  [staging].[shipping_type]
    DELETE FROM  [staging].[order]
    DELETE FROM  [staging].[product]
    DELETE FROM  [staging].[customer]
END
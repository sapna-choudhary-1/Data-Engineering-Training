USE [associatetraining];

CREATE OR ALTER PROCEDURE [gold].[usp_load] 
AS
BEGIN  
   
  -- Delete from most dependent child
   IF EXISTS (SELECT 1 FROM [gold].[fact_sales])
   BEGIN
     DELETE FROM [gold].[fact_sales];
     DBCC CHECKIDENT ('[gold].[fact_sales]', RESEED, 0);
   END
  
  IF EXISTS (SELECT 1 FROM [gold].[dim_order_product])
  BEGIN
    DELETE FROM [gold].[dim_order_product];
    DBCC CHECKIDENT ('[gold].[dim_order_product]', RESEED, 0);
  END

  IF EXISTS (SELECT 1 FROM [gold].[dim_order])
  BEGIN
    DELETE FROM [gold].[dim_order];
    DBCC CHECKIDENT ('[gold].[dim_order]', RESEED, 0);
  END

  IF EXISTS (SELECT 1 FROM [gold].[dim_product])
  BEGIN
    DELETE FROM [gold].[dim_product];
    DBCC CHECKIDENT ('[gold].[dim_product]', RESEED, 0);
  END

  IF EXISTS (SELECT 1 FROM [gold].[dim_customer])
  BEGIN
    DELETE FROM [gold].[dim_customer];
    DBCC CHECKIDENT ('[gold].[dim_customer]', RESEED, 0);
  END

-- =======================
  IF EXISTS (SELECT 1 FROM [gold].[dim_location])
  BEGIN
    DELETE FROM [gold].[dim_location];
    DBCC CHECKIDENT ('[gold].[dim_location]', RESEED, 0);
  END

  IF EXISTS (SELECT 1 FROM [gold].[dim_postal_code])
  BEGIN
    DELETE FROM [gold].[dim_postal_code];
    DBCC CHECKIDENT ('[gold].[dim_postal_code]', RESEED, 0);
  END

  IF EXISTS (SELECT 1 FROM [gold].[dim_city])
  BEGIN
    DELETE FROM [gold].[dim_city];
    DBCC CHECKIDENT ('[gold].[dim_city]', RESEED, 0);
  END

  IF EXISTS (SELECT 1 FROM [gold].[dim_state])
  BEGIN
    DELETE FROM [gold].[dim_state];
    DBCC CHECKIDENT ('[gold].[dim_state]', RESEED, 0);
  END

-- =======================
  IF EXISTS (SELECT 1 FROM [gold].[dim_gender])
  BEGIN
    DELETE FROM [gold].[dim_gender];
    DBCC CHECKIDENT ('[gold].[dim_gender]', RESEED, 0);
  END

  IF EXISTS (SELECT 1 FROM [gold].[dim_marital_status])
  BEGIN
    DELETE FROM [gold].[dim_marital_status];
    DBCC CHECKIDENT ('[gold].[dim_marital_status]', RESEED, 0);
  END
  
  IF EXISTS (SELECT 1 FROM [gold].[dim_customer_type])
  BEGIN
    DELETE FROM [gold].[dim_customer_type];
    DBCC CHECKIDENT ('[gold].[dim_customer_type]', RESEED, 0);
  END

  IF EXISTS (SELECT 1 FROM [gold].[dim_account_status])
  BEGIN
    DELETE FROM [gold].[dim_account_status];
    DBCC CHECKIDENT ('[gold].[dim_account_status]', RESEED, 0);
  END

-- --------------------
  IF EXISTS (SELECT 1 FROM [gold].[dim_brand])
  BEGIN
    DELETE FROM [gold].[dim_brand];
    DBCC CHECKIDENT ('[gold].[dim_brand]', RESEED, 0);
  END

  IF EXISTS (SELECT 1 FROM [gold].[dim_brand_tier])
  BEGIN
    DELETE FROM [gold].[dim_brand_tier];
    DBCC CHECKIDENT ('[gold].[dim_brand_tier]', RESEED, 0);
  END

  IF EXISTS (SELECT 1 FROM [gold].[dim_brand_name])
  BEGIN
    DELETE FROM [gold].[dim_brand_name];
    DBCC CHECKIDENT ('[gold].[dim_brand_name]', RESEED, 0);
  END

-- --------------------

  IF EXISTS (SELECT 1 FROM [gold].[dim_sub_category])
  BEGIN
    DELETE FROM [gold].[dim_sub_category];
    DBCC CHECKIDENT ('[gold].[dim_sub_category]', RESEED, 0);
  END

  IF EXISTS (SELECT 1 FROM [gold].[dim_main_category])
  BEGIN
    DELETE FROM [gold].[dim_main_category];
    DBCC CHECKIDENT ('[gold].[dim_main_category]', RESEED, 0);
  END

  -- --------------------
  IF EXISTS (SELECT 1 FROM [gold].[dim_payment_source])
  BEGIN
    DELETE FROM [gold].[dim_payment_source];
    DBCC CHECKIDENT ('[gold].[dim_payment_source]', RESEED, 0);
  END

  IF EXISTS (SELECT 1 FROM [gold].[dim_lead_type])
  BEGIN
    DELETE FROM [gold].[dim_lead_type];
    DBCC CHECKIDENT ('[gold].[dim_lead_type]', RESEED, 0);
  END

  IF EXISTS (SELECT 1 FROM [gold].[dim_order_status])
  BEGIN
    DELETE FROM [gold].[dim_order_status];
    DBCC CHECKIDENT ('[gold].[dim_order_status]', RESEED, 0);
  END

  IF EXISTS (SELECT 1 FROM [gold].[dim_shipping_type])
  BEGIN
    DELETE FROM [gold].[dim_shipping_type];
    DBCC CHECKIDENT ('[gold].[dim_shipping_type]', RESEED, 0);
  END

  -- --------------------
  IF EXISTS (SELECT 1 FROM [gold].[dim_delivery_estimate])
  BEGIN
    DELETE FROM [gold].[dim_delivery_estimate];
    DBCC CHECKIDENT ('[gold].[dim_delivery_estimate]', RESEED, 0);
  END
  
  IF EXISTS (SELECT 1 FROM [gold].[dim_date])
  BEGIN
    DELETE FROM [gold].[dim_date];
  END
  
  
  
  IF EXISTS (SELECT 1 FROM [gold].[batch_audit])
  BEGIN
    DELETE FROM [gold].[batch_audit];
  END
  
  
  

-- ========================================================================================================= 
-- BATCH AUDIT TABLE
-- =========================================================================================================

	DECLARE @batch_id INT
	INSERT INTO [gold].[batch_audit] ([load_name])
	VALUES ('Gold Load')
	SET @batch_id = SCOPE_IDENTITY()
	SELECT @batch_id
  
 -- =========================================================================================================
 -- DATE DIMENSION TABLE
 -- =========================================================================================================
-- =======================

 -- Insert generated rows
  BEGIN
    WITH date_sequence 
    AS (
      SELECT CAST('1954-08-18' AS DATE) AS [date]
      UNION ALL
      SELECT DATEADD(DAY, 1, [date])
      FROM date_sequence
      WHERE [date] < '2025-07-30'
    )
    INSERT INTO [gold].[dim_date] (
      [date], [year], [month], [day], [weekday],
      [weekday_name], [is_weekend], [fiscal_quarter]
    )
    SELECT
      [date],
      YEAR([date]) AS [year],
      MONTH([date]) AS [month],
      DAY([date]) AS [day],
      DATEPART(WEEKDAY, [date]) AS [weekday],
      DATENAME(WEEKDAY, [date]) AS [weekday_name],
      CASE 
        WHEN DATEPART(WEEKDAY, [date]) IN (6, 7) THEN 1 
        ELSE 0 
      END AS [is_weekend],
      'Q' + CAST(DATEPART(QUARTER, [date]) AS VARCHAR) AS [fiscal_quarter]
    FROM date_sequence
    OPTION (MAXRECURSION 32767)
  END
-- Insert pre-decided mapping-rows
  BEGIN
    INSERT INTO [gold].[dim_date] (
      [date], [year], [month], [day], [weekday],
      [weekday_name], [is_weekend], [fiscal_quarter]
    )
    VALUES 
      ('1900-01-01', 0, 0, 0, 0, 'Unknown', 0, 'Q0')
  END

-- =========================================================================================================
-- ==================== GENDER TABLE ====================
-- =========================================================================================================

  BEGIN 
    MERGE gold.dim_gender AS target
    USING (
        SELECT DISTINCT gender
        FROM staging.customer
        WHERE gender IS NOT NULL
    ) AS src
    ON target.gender = src.gender
    
  -- If the record exists in both the source and target → do nothing → keep as is

  -- If the record not exists in the target, add it
  -- In source only → insert
    WHEN NOT MATCHED BY TARGET 
      THEN INSERT (gender)
      VALUES (src.gender)

  -- If the record not exists in the source, delete it
  -- In target only → delete
    WHEN NOT MATCHED BY SOURCE 
      THEN DELETE
    OUTPUT $action, inserted.*, deleted.*;
  END

-- =========================================================================================================
-- ==================== MARITAL STATUS TABLE ====================
-- =========================================================================================================

  BEGIN 
    MERGE gold.dim_marital_status AS target
    USING (
        SELECT DISTINCT marital_status
        FROM staging.customer
        WHERE marital_status IS NOT NULL
    ) AS src
    ON target.marital_status = src.marital_status

    WHEN NOT MATCHED BY TARGET THEN
      INSERT (marital_status)
      VALUES (src.marital_status)
    WHEN NOT MATCHED BY SOURCE THEN
      DELETE;
  END

-- =========================================================================================================
-- ==================== CUSTOMER TYPE TABLE ====================
-- =========================================================================================================

  BEGIN 
    MERGE gold.dim_customer_type AS target
    USING (
        SELECT DISTINCT customer_type
        FROM staging.customer
        WHERE customer_type IS NOT NULL
    ) AS src
    ON target.customer_type = src.customer_type
    
    WHEN NOT MATCHED BY TARGET THEN
      INSERT (customer_type)
      VALUES (src.customer_type)
    WHEN NOT MATCHED BY SOURCE THEN
      DELETE;
  END

-- =========================================================================================================
-- ==================== ACCOUNT STATUS TABLE ====================
-- =========================================================================================================

  BEGIN 
    MERGE gold.dim_account_status AS target
    USING (
        SELECT DISTINCT account_status
        FROM staging.customer
        WHERE account_status IS NOT NULL
    ) AS src
    ON target.account_status = src.account_status
    
    WHEN NOT MATCHED BY TARGET THEN
      INSERT (account_status)
      VALUES (src.account_status)
    WHEN NOT MATCHED BY SOURCE THEN
      DELETE;
  END

-- =========================================================================================================
-- ==================== REGION TABLE ====================
-- =========================================================================================================
  IF EXISTS (SELECT 1 FROM [gold].[dim_region])
  BEGIN
    MERGE gold.dim_region AS target
    USING (
      SELECT DISTINCT region
      FROM staging.customer
      WHERE region IS NOT NULL
    ) AS src
    ON target.region = src.region

    WHEN NOT MATCHED BY TARGET THEN
      INSERT (region)
      VALUES (src.region)
    WHEN NOT MATCHED BY SOURCE
      AND target.region <> 'Unknown'
      THEN DELETE
    OUTPUT $action, inserted.*, deleted.*;
  END

  -- Insert pre-decided mapping-rows
  IF NOT EXISTS (SELECT 1 FROM [gold].[dim_region])
  BEGIN
    BEGIN
      INSERT INTO [gold].[dim_region] (region) 
      SELECT DISTINCT region
      FROM [staging].[customer]
      WHERE region <> 'Unknown'
    END
    
    BEGIN
      INSERT INTO [gold].[dim_region] (region) 
      VALUES 
        ('Unknown')
    END
  END


-- =========================================================================================================
-- ==================== COUNTRY TABLE ====================
-- =========================================================================================================
  -- Variables for "Unknown" values
  DECLARE @unknown_region_skey INT = (
    SELECT region_skey
    FROM [gold].[dim_region]
    WHERE region = 'Unknown'
  )
  -- =======================
  -- SCD2 logic for dim_country
  
  IF EXISTS (SELECT 1 FROM [gold].[dim_country])
  BEGIN
    WITH cte_src AS (
      SELECT DISTINCT 
        c.country,
        r.region_skey
      FROM [staging].[customer] c
      JOIN [gold].[dim_region] r 
        ON c.region = r.region
      WHERE c.country <> 'Unknown'
    )
    -- Step 1: Close old rows
    MERGE [gold].[dim_country] AS target
    USING cte_src AS src
    ON target.[country] = src.[country]
      AND target.is_current = 1
    WHEN MATCHED 
      AND target.region_skey <> src.region_skey
      THEN UPDATE SET
        target.is_current = 0,
        target.end_date = GETDATE()
    WHEN NOT MATCHED BY TARGET THEN
      INSERT (
        [country],
        region_skey,
        [start_date],
        is_current
      )
      VALUES (
        src.[country],
        src.region_skey,
        GETDATE(),
        1
      )
    WHEN NOT MATCHED BY SOURCE
      AND target.country <> 'Unknown'
      THEN DELETE
    OUTPUT $action, inserted.*, deleted.*;
  
    -- Step 2: Insert new SCD2 rows for changed countries
    INSERT INTO [gold].[dim_country] (
      [country],
      region_skey,
      [start_date],
      is_current
    )
    SELECT
      src.[country],
      src.region_skey,
      GETDATE(),
      1
    FROM cte_src AS src
    LEFT JOIN [gold].[dim_country] target
      ON src.[country] = target.[country]
      AND target.is_current = 1
      AND src.region_skey = target.region_skey
    WHERE target.[country] IS NULL;
  END
  
  -- Initial load if table is empty
  IF NOT EXISTS (SELECT 1 FROM [gold].[dim_country])
  BEGIN
    INSERT INTO [gold].[dim_country] (
      [country],
      region_skey,
      [start_date],
      is_current
    )
    SELECT DISTINCT
      c.country,
      r.region_skey,
      GETDATE(),
      1
    FROM [staging].[customer] c
    JOIN [gold].[dim_region] r 
      ON c.region = r.region
    WHERE c.country <> 'Unknown';
  
    INSERT INTO [gold].[dim_country] (
      country, 
      region_skey,
      [start_date],
      is_current
    )
    VALUES (
      'Unknown', 
      @unknown_region_skey,
      GETDATE(),
      1
    );
  END
  
  
-- =========================================================================================================
-- ==================== STATE TABLE ====================
-- =========================================================================================================
-- SCD-2: country_skey, is_active, start_date, end_date, is_current

  -- Variables for "Unknown" values
  DECLARE @unknown_country_skey INT
  SELECT @unknown_country_skey = country_skey
  FROM [gold].[dim_country]
  WHERE country = 'Unknown'

  -- Merge new or changed states (SCD-2)
  IF EXISTS (SELECT 1 FROM [gold].[dim_state])
  BEGIN
    WITH cte_src AS (
      SELECT DISTINCT
        c.[state],
        co.country_skey
      FROM [staging].[customer] c
      JOIN [gold].[dim_country] co
        ON c.country = co.country
      WHERE c.state <> 'Unknown'
    )
    -- Step 1: Close old rows
    MERGE [gold].[dim_state] AS target
    USING cte_src AS src
    ON target.[state] = src.[state]
      AND target.is_current = 1

    WHEN MATCHED 
          AND target.country_skey <> src.country_skey 
          AND target.is_current = 1
      THEN UPDATE SET
        target.is_current = 0,
        target.end_date = GETDATE()
    WHEN NOT MATCHED BY TARGET THEN
      INSERT (
        [state],
        country_skey,
        [start_date]
      )
      VALUES (
        src.[state],
        src.country_skey,
        GETDATE()
      )
    WHEN NOT MATCHED BY SOURCE 
      AND target.state <> 'Unknown'
      THEN DELETE
    OUTPUT $action, inserted.*, deleted.*;
  
    -- Step 2: Insert new SCD2 rows for changed countries
    INSERT INTO [gold].[dim_state] (
      [state],
      country_skey,
      [start_date],
      is_current
    )
    SELECT
      src.[state],
      src.country_skey,
      GETDATE(),
      1
    FROM cte_src AS src
    LEFT JOIN [gold].[dim_state] target
      ON src.[state] = target.[state]
      AND target.is_current = 1
      AND src.country_skey = target.country_skey
    WHERE target.[state] IS NULL;
  END

  -- Insert pre-decided mapping-rows
  IF NOT EXISTS (SELECT 1 FROM [gold].[dim_state])
  BEGIN
    BEGIN
      INSERT INTO [gold].[dim_state] (
        [state],
        country_skey,
        [start_date]
      )
      SELECT DISTINCT
        c.[state],
        co.country_skey,
        GETDATE()
      FROM [staging].[customer] c
      JOIN [gold].[dim_country] co
        ON c.country = co.country
      WHERE c.state <> 'Unknown';
    END
    BEGIN
      INSERT INTO [gold].[dim_state] (
        [state],
        country_skey,
        [start_date]
      )
      VALUES (
        'Unknown',
        @unknown_country_skey,
        GETDATE()
      );
    END
  END
  
-- =========================================================================================================
-- ==================== CITY TABLE ====================
-- =========================================================================================================
  -- SCD-2: state_skey, is_active, start_date, end_date, is_current

  DECLARE @unknown_state_skey INT
  SELECT @unknown_state_skey = state_skey
  FROM [gold].[dim_state]
  WHERE [state] = 'Unknown'

  -- Merge new or changed cities (SCD-2)
  IF EXISTS (SELECT 1 FROM [gold].[dim_city])
  BEGIN
    WITH cte_src AS (
      SELECT DISTINCT
        c.city,
        s.state_skey
      FROM [staging].[customer] c
      JOIN [gold].[dim_state] s
        ON c.state = s.state
      WHERE c.city <> 'Unknown'
    )

    MERGE [gold].[dim_city] AS target
    USING cte_src AS src
    ON target.city = src.city
      AND target.is_current = 1

    WHEN MATCHED 
          AND target.state_skey <> src.state_skey 
          AND target.is_current = 1
      THEN UPDATE SET
        target.is_current = 0,
        target.end_date = GETDATE()
    WHEN NOT MATCHED BY TARGET THEN
      INSERT (
        city,
        state_skey,
        [start_date]
      )
      VALUES (
        src.city,
        src.state_skey,
        GETDATE()
      )
    WHEN NOT MATCHED BY SOURCE
      AND target.city <> 'Unknown'
      THEN DELETE
    OUTPUT $action, inserted.*, deleted.*;
  
    -- Step 2: Insert new SCD2 rows for changed countries
    INSERT INTO [gold].[dim_city] (
      [city],
      state_skey,
      [start_date],
      is_current
    )
    SELECT
      src.[city],
      src.state_skey,
      GETDATE(),
      1
    FROM cte_src AS src
    LEFT JOIN [gold].[dim_city] target
      ON src.[city] = target.[city]
      AND target.is_current = 1
      AND src.state_skey = target.state_skey
    WHERE target.[city] IS NULL;
  END

-- Insert pre-decided mapping-rows
  IF NOT EXISTS (SELECT 1 FROM [gold].[dim_city])
  BEGIN
    INSERT INTO [gold].[dim_city] (
      city,
      state_skey,
      [start_date]
    )
    SELECT DISTINCT
      c.city,
      s.state_skey,
      GETDATE()
    FROM [staging].[customer] c
    JOIN [gold].[dim_state] s
      ON c.state = s.state
    WHERE c.city <> 'Unknown';

    INSERT INTO [gold].[dim_city] (
      city,
      state_skey,
      [start_date]
    )
    VALUES (
      'Unknown',
      @unknown_state_skey,
      GETDATE()
    );
  END

-- =========================================================================================================
-- ==================== POSTAL CODE TABLE ====================
-- =========================================================================================================
  -- SCD-2: city_skey, is_active, start_date, end_date, is_current

  DECLARE @unknown_city_skey INT
  SELECT @unknown_city_skey = city_skey
  FROM [gold].[dim_city]
  WHERE city = 'Unknown'

  -- Merge new or changed postal codes (SCD-2)
  IF EXISTS (SELECT 1 FROM [gold].[dim_postal_code])
  BEGIN
    WITH cte_src AS (
      SELECT DISTINCT
        c.[postal_code],
        ci.city_skey
      FROM [staging].[customer] c
      JOIN [gold].[dim_city] ci
        ON c.city = ci.city
      WHERE c.[postal_code] <> 'Unknown'
    )
    MERGE [gold].[dim_postal_code] AS target
    USING cte_src AS src
    ON target.[postal_code] = src.[postal_code]
      AND target.is_current = 1

    WHEN MATCHED 
          AND target.city_skey <> src.city_skey 
          AND target.is_current = 1
      THEN UPDATE SET
        target.is_current = 0,
        target.end_date = GETDATE()
    WHEN NOT MATCHED BY TARGET 
      THEN INSERT (
        [postal_code],
        city_skey,
        [start_date]
      )
      VALUES (
        src.[postal_code],
        src.city_skey,
        GETDATE()
      )
    WHEN NOT MATCHED BY SOURCE
      AND target.postal_code <> 'Unknown'
      THEN DELETE
    OUTPUT $action, inserted.*, deleted.*;
  
    -- Step 2: Insert new SCD2 rows for changed postal_codes
    INSERT INTO [gold].[dim_postal_code] (
      [postal_code],
      city_skey,
      [start_date],
      is_current
    )
    SELECT
      src.[postal_code],
      src.city_skey,
      GETDATE(),
      1
    FROM cte_src AS src
    LEFT JOIN [gold].[dim_postal_code] target
      ON src.[postal_code] = target.[postal_code]
      AND target.is_current = 1
      AND src.city_skey = target.city_skey
    WHERE target.[state] IS NULL;
  END

  -- Insert pre-decided mapping-rows
  IF NOT EXISTS (SELECT 1 FROM [gold].[dim_postal_code])
  BEGIN
    INSERT INTO [gold].[dim_postal_code] (
      [postal_code],
      city_skey,
      [start_date]
    )
    SELECT DISTINCT
      c.[postal_code],
      ci.city_skey,
      GETDATE()
    FROM [staging].[customer] c
    JOIN [gold].[dim_city] ci
      ON c.city = ci.city
    WHERE c.[postal_code] <> 'Unknown';

    INSERT INTO [gold].[dim_postal_code] (
      [postal_code],
      city_skey,
      [start_date]
    )
    VALUES (
      'Unknown',
      @unknown_city_skey,
      GETDATE()
    );
  END

-- =========================================================================================================
-- ==================== LOCATION TABLE ====================
-- ========================================================================================================= 
-- SCD-2: postal_code_skey, is_active, start_date, end_date, is_current

  DECLARE @unknown_postal_code_skey INT
  SELECT @unknown_postal_code_skey = postal_code_skey
  FROM [gold].[dim_postal_code]
  WHERE postal_code = 'Unknown'

-- =======================
  -- Merge new or changed locations (SCD-2)
  IF EXISTS (SELECT 1 FROM [gold].[dim_location])
  BEGIN
    MERGE [gold].[dim_location] AS target
    USING (
      SELECT DISTINCT postal_code_skey
      FROM [gold].[dim_postal_code]
      WHERE postal_code <> 'Unknown'
    ) AS src
    ON target.postal_code_skey = src.postal_code_skey

    WHEN NOT MATCHED BY TARGET 
    	THEN INSERT (postal_code_skey)
      VALUES (src.postal_code_skey)
    WHEN NOT MATCHED BY SOURCE 
      AND target.postal_code_skey <> @unknown_postal_code_skey
      THEN DELETE
    OUTPUT $action, inserted.*, deleted.*;
  END

  -- Insert pre-decided mapping-rows
  IF NOT EXISTS (SELECT 1 FROM [gold].[dim_location])
  BEGIN
    INSERT INTO [gold].[dim_location] (postal_code_skey)
    SELECT DISTINCT postal_code_skey
    FROM [gold].[dim_postal_code]
    WHERE postal_code <> 'Unknown'

    UNION ALL
    SELECT @unknown_postal_code_skey
  END

-- =========================================================================================================
-- ==================== BRAND TIER TABLE ====================
-- =========================================================================================================

  BEGIN
    MERGE [gold].[dim_brand_tier] AS target
    USING (
      SELECT DISTINCT brand_tier
      FROM [staging].[product]
      WHERE brand_tier IS NOT NULL
    ) AS src
    ON target.brand_tier = src.brand_tier

    WHEN NOT MATCHED BY TARGET THEN
      INSERT (brand_tier)
      VALUES (src.brand_tier)
    WHEN NOT MATCHED BY SOURCE 
      AND target.brand_tier <> 'Unknown'
      THEN DELETE
    OUTPUT $action, inserted.*, deleted.*;
  END


-- =========================================================================================================
-- ==================== BRAND NAME TABLE ====================
-- =========================================================================================================

-- Insert data from the table
  BEGIN
    MERGE [gold].[dim_brand_name] AS target
    USING (
      SELECT DISTINCT brand_name
      FROM [staging].[product]
      WHERE brand_name IS NOT NULL
    ) AS src
    ON target.brand_name = src.brand_name

    WHEN NOT MATCHED BY TARGET THEN
      INSERT (brand_name)
      VALUES (src.brand_name)
    WHEN NOT MATCHED BY SOURCE 
      AND target.brand_name <> 'Unknown'
      THEN DELETE
    OUTPUT $action, inserted.*, deleted.*;
  END


-- =========================================================================================================
-- ==================== BRAND COUNTRY TABLE ====================
-- =========================================================================================================
-- =======================
-- Insert data from the table
  BEGIN
    MERGE [gold].[dim_brand_country] AS target
    USING (
      SELECT DISTINCT brand_country
      FROM [staging].[product]
      WHERE brand_country IS NOT NULL
    ) AS src
    ON target.brand_country = src.brand_country

    WHEN NOT MATCHED BY TARGET THEN
      INSERT (brand_country)
      VALUES (src.brand_country)
    WHEN NOT MATCHED BY SOURCE 
      AND target.brand_country <> 'Unknown'
      THEN DELETE
    OUTPUT $action, inserted.*, deleted.*;
  END


-- =========================================================================================================
-- ==================== BRAND TABLE ====================
-- =========================================================================================================
  -- Variables for "Unknown" values
  DECLARE @unknown_brand_tier_skey INT
  DECLARE @unknown_brand_name_skey INT
  DECLARE @unknown_brand_country_skey INT

  SELECT @unknown_brand_tier_skey = brand_tier_skey
    FROM [gold].[dim_brand_tier]
    WHERE brand_tier = 'Unknown'

  SELECT @unknown_brand_name_skey = brand_name_skey
    FROM [gold].[dim_brand_name]
    WHERE brand_name = 'Unknown'

  SELECT @unknown_brand_country_skey = brand_country_skey
    FROM [gold].[dim_brand_country]
    WHERE brand_country = 'Unknown'

-- =======================
  -- Merge new or changed postal codes (SCD-2)
  -- IF EXISTS (SELECT 1 FROM [gold].[dim_brand])
  BEGIN
    WITH cte_src AS (
      SELECT DISTINCT
        bt.brand_tier_skey,
        bn.brand_name_skey,
        bc.brand_country_skey
      FROM [staging].[product] p
      JOIN [gold].[dim_brand_tier] bt
        ON p.brand_tier = bt.brand_tier
      JOIN [gold].[dim_brand_name] bn
        ON p.brand_name = bn.brand_name
      JOIN [gold].[dim_brand_country] bc
        ON p.brand_country = bc.brand_country
--      WHERE p.brand_tier <> 'Unknown'
--        AND p.brand_name <> 'Unknown'
--        AND p.brand_country <> 'Unknown'
    )
  -- Step 1: Expire old rows (close previous version)
    MERGE [gold].[dim_brand] AS target
    USING cte_src AS src
    ON target.brand_tier_skey = src.brand_tier_skey
      AND target.brand_name_skey = src.brand_name_skey
      AND target.brand_country_skey = src.brand_country_skey
      AND target.is_current = 1
    WHEN NOT MATCHED BY TARGET THEN
      INSERT (
        brand_tier_skey,
        brand_name_skey,
        brand_country_skey,
        start_date,
        is_current
      )
      VALUES (
        src.brand_tier_skey,
        src.brand_name_skey,
        src.brand_country_skey,
        GETDATE(),
        1
      )
    WHEN NOT MATCHED BY SOURCE
      THEN DELETE;

    -- Step 2: Insert new SCD2 rows for changed brands (if needed)
    INSERT INTO [gold].[dim_brand] (
      brand_tier_skey,
      brand_name_skey,
      brand_country_skey,
      start_date,
      is_current
    )
    SELECT
      src.brand_tier_skey,
      src.brand_name_skey,
      src.brand_country_skey,
      GETDATE(),
      1
    FROM cte_src AS src
    LEFT JOIN [gold].[dim_brand] tgt
      ON src.brand_tier_skey = tgt.brand_tier_skey
      AND src.brand_name_skey = tgt.brand_name_skey
      AND src.brand_country_skey = tgt.brand_country_skey
      AND tgt.is_current = 1
    WHERE tgt.brand_tier_skey IS NULL;
  END

-- -- Initial load if table is empty
--   IF NOT EXISTS (SELECT 1 FROM [gold].[dim_brand])
--   BEGIN
--     INSERT INTO [gold].[dim_brand] (
--       brand_tier_skey, 
--       brand_name_skey, 
--       brand_country_skey,
--       start_date,
--       is_current
--     )
--     SELECT DISTINCT
--       ISNULL(bt.brand_tier_skey, @unknown_brand_tier_skey) AS brand_tier_skey,
--       ISNULL(bn.brand_name_skey, @unknown_brand_name_skey) AS brand_name_skey,
--       ISNULL(bc.brand_country_skey, @unknown_brand_country_skey) AS brand_country_skey,
--       GETDATE(),
--       1
--     FROM [staging].[product] p
--     JOIN [gold].[dim_brand_tier] bt
--       ON p.brand_tier = bt.brand_tier
--     JOIN [gold].[dim_brand_name] bn
--       ON p.brand_name = bn.brand_name
--     JOIN [gold].[dim_brand_country] bc
--       ON p.brand_country = bc.brand_country
-- --     WHERE 
-- --       p.brand_name <> 'Unknown' 
-- --       AND p.brand_tier <> 'Unknown' 
-- --       AND p.brand_country <> 'Unknown'

--    -- Insert the 'Unknown' brand row
--    INSERT INTO [gold].[dim_brand] (
--      brand_tier_skey,
--      brand_name_skey,
--      brand_country_skey,
--      start_date,
--      is_current
--    )
--    VALUES (
--      @unknown_brand_tier_skey,
--      @unknown_brand_name_skey,
--      @unknown_brand_country_skey,
--      GETDATE(),
--      1
--    )
--   END



-- =========================================================================================================
-- ==================== MAIN CATEGORY TABLE ====================
-- =========================================================================================================

  -- Merge new or changed postal codes (SCD-2)
  IF EXISTS (SELECT 1 FROM [gold].[dim_main_category])
  BEGIN
    MERGE [gold].[dim_main_category] AS target
    USING (
      SELECT DISTINCT
        main_category
      FROM [staging].[product]
      WHERE main_category <> 'Unknown'
    ) AS src
    ON target.main_category = src.main_category
      AND target.is_current = 1

    WHEN NOT MATCHED BY TARGET THEN
      INSERT (
        main_category,
        [start_date]
      )
      VALUES (
        src.main_category,
        GETDATE()
      )
    WHEN NOT MATCHED BY SOURCE 
      AND target.main_category <> 'Unknown'
      THEN DELETE
    OUTPUT $action, inserted.*, deleted.*;
  
    -- Step 2: Insert new SCD2 rows for changed countries
    INSERT INTO [gold].[dim_main_category] (
      main_category,
      [start_date],
      is_current
    )
    SELECT
      src.main_category,
      GETDATE(),
      1
    -- FROM cte_src AS src ❗❗CHK❗❗
    FROM [staging].[product] AS src
    LEFT JOIN [gold].[dim_main_category] target
      ON src.[main_category] = target.[main_category]
      AND target.is_current = 1
    WHERE target.[main_category] IS NULL;
  END

  -- Insert pre-decided mapping-rows
  IF NOT EXISTS (SELECT 1 FROM [gold].[dim_main_category])
  BEGIN
    INSERT INTO [gold].[dim_main_category] (
      main_category,
      [start_date]
    )
    SELECT DISTINCT
      p.main_category AS main_category,
      GETDATE()
    FROM [staging].[product] p
    WHERE p.main_category <> 'Unknown'
    
    INSERT INTO [gold].[dim_main_category] (
      main_category,
      [start_date]
    ) 
    VALUES (
      'Unknown',
      GETDATE()
    )
  END

-- =========================================================================================================
-- ==================== SUB-CATEGORY TABLE ====================
-- =========================================================================================================
  -- Variables for "Unknown" values
  DECLARE @unknown_main_category_skey INT
  SELECT @unknown_main_category_skey = main_category_skey
    FROM [gold].[dim_main_category]
    WHERE main_category = 'Unknown'

-- =======================
  -- Merge new or changed locations (SCD-2)
  IF EXISTS (SELECT 1 FROM [gold].[dim_sub_category])
  BEGIN
    WITH cte_src AS (
      SELECT DISTINCT
        sub_category,
        main_category_skey
      -- FROM [gold].[dim_sub_category]❗❗CHK❗❗
      FROM [staging].[product] 
      WHERE sub_category <> 'Unknown'
    )
    -- Step 1: Close old rows
    MERGE [gold].[dim_sub_category] AS target
    USING cte_src AS src
    ON target.sub_category = src.sub_category
      AND target.is_current = 1

    WHEN MATCHED 
          AND target.main_category_skey <> src.main_category_skey 
          AND target.is_current = 1
      THEN UPDATE SET
        target.is_current = 0,
        target.end_date = GETDATE()
    WHEN NOT MATCHED BY TARGET 
      THEN INSERT (
        sub_category,
        main_category_skey,
        [start_date]
      )
      VALUES (
        sub_category,
        src.main_category_skey,
        GETDATE()
      )
    WHEN NOT MATCHED BY SOURCE 
      AND target.sub_category <> 'Unknown'
      THEN DELETE
    OUTPUT $action, inserted.*, deleted.*;
  
    -- Step 2: Insert new SCD2 rows for changed postal_codes
    INSERT INTO [gold].[dim_sub_category] (
      [sub_category],
      main_category_skey,
      [start_date],
      is_current
    )
    SELECT
      src.[sub_category],
      src.main_category_skey,
      GETDATE(),
      1
    FROM cte_src AS src
    LEFT JOIN [gold].[dim_sub_category] target
      ON src.[sub_category] = target.[sub_category]
      AND target.is_current = 1
      AND src.main_category_skey = target.main_category_skey
    WHERE target.[sub_category] IS NULL;
  END

-- Insert pre-decided mapping-rows
  IF NOT EXISTS (SELECT 1 FROM [gold].[dim_sub_category])
  BEGIN
    INSERT INTO [gold].[dim_sub_category] (
      sub_category, 
      main_category_skey,
      [start_date]
    )
    SELECT DISTINCT
      p.sub_category AS sub_category,
      m.main_category_skey,
      GETDATE()
    FROM [staging].[product] p
    JOIN [gold].[dim_main_category] m
      ON p.main_category = m.main_category
    WHERE p.sub_category <> 'Unknown'

    INSERT INTO [gold].[dim_sub_category] (
      sub_category, 
      main_category_skey,
      [start_date]
    ) 
    VALUES (
      'Unknown', 
      @unknown_main_category_skey,
      GETDATE()
    )
  END


-- =========================================================================================================
-- ==================== PAYMENT SOURCE TABLE ====================
-- =========================================================================================================

  BEGIN 
    MERGE [gold].[dim_payment_source] AS target
    USING (
        SELECT DISTINCT payment_source
        FROM [staging].[order]
        WHERE payment_source <> ''
    ) AS src
    ON target.payment_source = src.payment_source

    WHEN NOT MATCHED BY TARGET 
      THEN INSERT (payment_source)
      VALUES (src.payment_source)

    WHEN NOT MATCHED BY SOURCE 
      THEN DELETE
    OUTPUT $action, inserted.*, deleted.*;
  END


-- =========================================================================================================
-- ==================== LEAD TYPE TABLE ====================
-- =========================================================================================================

  BEGIN 
    MERGE gold.dim_lead_type AS target
    USING (
        SELECT DISTINCT lead_type
        FROM [staging].[order]
        WHERE lead_type IS NOT NULL
    ) AS src
    ON target.lead_type = src.lead_type

    WHEN NOT MATCHED BY TARGET 
      THEN INSERT (lead_type)
      VALUES (src.lead_type)

    WHEN NOT MATCHED BY SOURCE 
      THEN DELETE
    OUTPUT $action, inserted.*, deleted.*;
  END


-- =========================================================================================================
-- ==================== ORDER STATUS TABLE ====================
-- =========================================================================================================

  BEGIN
    WITH cte_src AS (
      SELECT DISTINCT
        order_status
      FROM [staging].[order]
      WHERE order_status IS NOT NULL
    )
    -- Step 1: Expire old rows if status changes
    MERGE [gold].[dim_order_status] AS target
    USING cte_src AS src
    ON target.order_status = src.order_status
      AND target.is_current = 1
    
    WHEN NOT MATCHED BY TARGET THEN
      INSERT (
        order_status,
        start_date,
        is_current
      )
      VALUES (
        src.order_status,
        GETDATE(),
        1
      )
    WHEN NOT MATCHED BY SOURCE 
      AND target.order_status <> 'Unknown'
      THEN DELETE
    OUTPUT $action, inserted.*, deleted.*;

    -- Step 2: Insert new SCD2 rows for changed statuses (if needed)
    INSERT INTO [gold].[dim_order_status] (
      order_status,
      start_date,
      is_current
    )
    SELECT
      src.order_status,
      GETDATE(),
      1
    FROM cte_src AS src
    LEFT JOIN [gold].[dim_order_status] tgt
      ON src.order_status = tgt.order_status
      AND tgt.is_current = 1
    WHERE tgt.order_status IS NULL;
  END

-- =========================================================================================================
-- ==================== DELIVERY ESTIMATE TABLE ====================
-- =========================================================================================================

  IF EXISTS (SELECT 1 FROM [gold].[dim_delivery_estimate])
  BEGIN
    MERGE gold.dim_delivery_estimate AS target
    USING (
      SELECT DISTINCT delivery_estimate
      FROM staging.shipping_type
      WHERE delivery_estimate IS NOT NULL
    ) AS src
    ON target.delivery_estimate = src.delivery_estimate

    WHEN NOT MATCHED BY TARGET 
      THEN INSERT (delivery_estimate)
      VALUES (src.delivery_estimate)

    WHEN NOT MATCHED BY SOURCE 
      THEN DELETE
    OUTPUT $action, inserted.*, deleted.*;
  END

-- Insert data from the table
  IF NOT EXISTS (SELECT 1 FROM [gold].[dim_delivery_estimate])
  BEGIN
    INSERT INTO [gold].[dim_delivery_estimate] (delivery_estimate)
    SELECT DISTINCT
      delivery_estimate
    FROM [staging].[shipping_type]
    WHERE shipping_type <> 'Unknown'

    UNION ALL
    SELECT '0'
  END

-- =========================================================================================================
-- ==================== SHIPPING TYPE TABLE ====================
-- =========================================================================================================
  -- Variables for "Unknown" values
  DECLARE @unknown_delivery_estimate_skey INT
  SELECT @unknown_delivery_estimate_skey = delivery_estimate_skey
    FROM [gold].[dim_delivery_estimate]
    WHERE delivery_estimate = '0'

-- =======================
  -- Merge new or changed locations (SCD-2)
  IF EXISTS (SELECT 1 FROM [gold].[dim_shipping_type])
  BEGIN
    WITH cte_src AS (
      SELECT DISTINCT
        st.shipping_type,
        de.delivery_estimate_skey
      FROM [staging].[shipping_type] st
      JOIN [gold].[dim_delivery_estimate] de
        ON st.delivery_estimate = de.delivery_estimate
      WHERE shipping_type <> 'Unknown'
    )
    MERGE [gold].[dim_shipping_type] AS target
    USING cte_src AS src
    ON target.shipping_type = src.shipping_type
      AND target.delivery_estimate_skey = src.delivery_estimate_skey

    WHEN NOT MATCHED BY TARGET 
      THEN INSERT (
        shipping_type,
        delivery_estimate_skey
      )
      VALUES (
        shipping_type,
        src.delivery_estimate_skey
      )
    WHEN NOT MATCHED BY SOURCE 
      AND target.shipping_type <> 'Unknown'
      THEN DELETE
    OUTPUT $action, inserted.*, deleted.*;
  END


-- Insert pre-decided mapping-rows
  IF NOT EXISTS (SELECT 1 FROM [gold].[dim_shipping_type])
  BEGIN
    INSERT INTO [gold].[dim_shipping_type] (
      shipping_type, 
      delivery_estimate_skey
    )
    SELECT DISTINCT
      st.shipping_type,
      de.delivery_estimate_skey
    FROM [staging].[shipping_type] st
    JOIN [gold].[dim_delivery_estimate] de
      ON st.delivery_estimate = de.delivery_estimate
    WHERE shipping_type <> 'Unknown'

    INSERT INTO [gold].[dim_shipping_type] (
      shipping_type, 
      delivery_estimate_skey
    )
    VALUES (
      'Unknown', 
      @unknown_delivery_estimate_skey
    )
  END


-- =========================================================================================================
-- =========================================================================================================
-- =========================================================================================================
-- ======================================= CUSTOMER DIMENSION TABLE =======================================
-- =========================================================================================================
    -- Variables for "Unknown" values  
  BEGIN
    DECLARE @unknown_gender_skey INT
    DECLARE @unknown_marital_status_skey INT
    DECLARE @unknown_customer_type_skey INT
    DECLARE @unknown_account_status_skey INT
    DECLARE @unknown_location_skey INT
    DECLARE @unknown_postal_code_skey INT
    
    SELECT @unknown_postal_code_skey = postal_code_skey
    FROM [gold].[dim_postal_code]
    WHERE postal_code = 'Unknown'
    SELECT @unknown_gender_skey = gender_skey
      FROM [gold].[dim_gender]
      WHERE gender = 'Unknown'
    SELECT @unknown_marital_status_skey = marital_status_skey
      FROM [gold].[dim_marital_status]
      WHERE marital_status = 'Unknown'
    SELECT @unknown_customer_type_skey = customer_type_skey
      FROM [gold].[dim_customer_type]
      WHERE customer_type = 'Unknown'
    SELECT @unknown_account_status_skey = account_status_skey
      FROM [gold].[dim_account_status]
      WHERE account_status = 'Unknown'
    SELECT @unknown_location_skey = location_skey
      FROM [gold].[dim_location]
      WHERE postal_code_skey = @unknown_postal_code_skey
      
    -- Drop temp tables only if they exist
    IF OBJECT_ID('tempdb..#utmp_calculate_age') IS NOT NULL
        DROP TABLE #utmp_calculate_age;
    
    IF OBJECT_ID('tempdb..#utmp_fetch_name_parts') IS NOT NULL
        DROP TABLE #utmp_fetch_name_parts;
    
    IF OBJECT_ID('tempdb..#utmp_cte_src') IS NOT NULL
        DROP TABLE #utmp_cte_src;

    -- Create temp tables
  SELECT 
    customer_id,
    DATEDIFF(YEAR, customer_dob, GETDATE()) - 
    CASE 
      WHEN MONTH(customer_dob) > MONTH(GETDATE()) 
        OR (MONTH(customer_dob) = MONTH(GETDATE()) AND DAY(customer_dob) > DAY(GETDATE())) THEN 1 
      ELSE 0 
    END AS calculated_customer_age
  INTO #utmp_calculate_age
  FROM [staging].[customer]
  WHERE customer_dob IS NOT NULL

  SELECT
    customer_id,
    customer_name,
    -- First Name: Everything before the first space
    LEFT(customer_name, CHARINDEX(' ', customer_name + ' ') - 1) AS first_name,
    -- Middle name: Only if there are three or more words
    CASE 
      WHEN LEN(customer_name) - LEN(REPLACE(customer_name, ' ', '')) >= 2
        THEN TRIM(SUBSTRING(
          customer_name,
        -- 1st space position + 1
          CHARINDEX(' ', customer_name) + 1,
        -- Length from 1st space to the 2nd space
        -- CHARINDEX(expression_to_find, full_string, start_location)
          CHARINDEX(' ', customer_name + ' ', CHARINDEX(' ', customer_name) + 1) - CHARINDEX(' ', customer_name) - 1
        ))
      ELSE NULL
    END AS middle_name,
    -- Last name: for two words get second, for 3+ get last part, else null
    CASE 
      -- No last name if no spaces
      WHEN LEN(customer_name) - LEN(REPLACE(customer_name, ' ', '')) = 0 
        THEN NULL
      -- If one space, get the second word as last name value
      WHEN LEN(customer_name) - LEN(REPLACE(customer_name, ' ', '')) = 1
        THEN TRIM(SUBSTRING(
          customer_name,
          CHARINDEX(' ', customer_name) + 1,
          LEN(customer_name)
        ))
      -- If two or more spaces, get everything after the second space
      ELSE TRIM(SUBSTRING(
            customer_name,
            CHARINDEX(' ', customer_name + ' ', CHARINDEX(' ', customer_name) + 1) + 1,
            LEN(customer_name)
          ))
    END AS last_name
  INTO #utmp_fetch_name_parts
  FROM [staging].[customer]


  SELECT DISTINCT
    c.customer_id,
    COALESCE(c.signup_date, '1900-01-01') AS signup_date,
    ISNULL(g.gender_skey, @unknown_gender_skey) AS gender_skey,
    CASE
      WHEN c.customer_dob IS NOT NULL 
        THEN c.customer_dob
      ELSE '1900-01-01'
    END AS [customer_dob],
    -- Calculate Age
    CASE 
      WHEN ca.calculated_customer_age BETWEEN 0 AND 120 THEN ca.calculated_customer_age
      WHEN ca.calculated_customer_age < 0 THEN 0
      WHEN ca.calculated_customer_age > 120 THEN 120
      ELSE NULL
    END AS customer_age,
    fnp.first_name,
    fnp.middle_name,
    fnp.last_name,
    ISNULL(ms.marital_status_skey, @unknown_marital_status_skey) AS marital_status_skey,
    ISNULL(ct.customer_type_skey, @unknown_customer_type_skey) AS customer_type_skey,
    ISNULL(ac.account_status_skey, @unknown_account_status_skey) AS account_status_skey,
    ISNULL(l.location_skey, @unknown_location_skey) AS location_skey,
    c.email AS [email],
    c.phone AS [phone]
  INTO #utmp_cte_src
  FROM [staging].[customer] c
  LEFT JOIN #utmp_calculate_age ca
    ON c.customer_id = ca.customer_id
  LEFT JOIN [gold].[dim_gender] g 
    ON c.gender = g.gender
  LEFT JOIN #utmp_fetch_name_parts fnp 
    ON c.customer_id = fnp.customer_id
  LEFT JOIN [gold].[dim_marital_status] ms 
    ON c.marital_status = ms.marital_status
  LEFT JOIN [gold].[dim_customer_type] ct 
    ON c.customer_type = ct.customer_type
  LEFT JOIN [gold].[dim_account_status] ac 
    ON c.account_status = ac.account_status
  LEFT JOIN [gold].[dim_postal_code] pc 
    ON c.[postal_code] = pc.postal_code
  LEFT JOIN [gold].[dim_location] l 
    ON l.postal_code_skey = pc.postal_code_skey
  -- Ignore the customer's data if customer_id is NULL (aconsidering it as a false data):
  WHERE 
    c.customer_id IS NOT NULL 
    AND c.customer_id <> ''
  END

  
  MERGE [gold].[dim_customer] AS target
  USING [#utmp_cte_src] AS src
    ON target.customer_id = src.customer_id
      AND target.is_current = 1
  WHEN MATCHED AND (
    target.signup_date <> src.signup_date OR
    target.gender_skey <> src.gender_skey OR
    target.customer_dob <> src.customer_dob OR
    target.customer_age <> src.customer_age OR
    target.first_name <> src.first_name OR
    target.middle_name <> src.middle_name OR
    target.last_name <> src.last_name OR
    target.marital_status_skey <> src.marital_status_skey OR
    target.customer_type_skey <> src.customer_type_skey OR
    target.account_status_skey <> src.account_status_skey OR
    target.location_skey <> src.location_skey OR
    target.email <> src.email OR
    target.phone <> src.phone
  )
  THEN UPDATE SET
    -- SCD2 Expiry Logic
    target.is_current = 
      CASE
        WHEN 
          target.email <> src.email
          OR target.phone <> src.phone
          THEN 0 
        ELSE target.is_current 
      END,
    target.end_date =
      CASE
        WHEN 
          target.email <> src.email
          OR target.phone <> src.phone
          THEN GETDATE() 
        ELSE target.end_date 
      END,
    -- SCD1 Overwrite
    target.signup_date = src.signup_date,
    target.gender_skey = src.gender_skey,
    target.customer_dob = src.customer_dob,
    target.customer_age = src.customer_age,
    target.first_name = src.first_name,
    target.middle_name = src.middle_name,
    target.last_name = src.last_name,
    target.marital_status_skey = src.marital_status_skey,
    -- SCD3 Logic for customer_type
    target.prev_customer_type_skey =
      CASE
        WHEN target.customer_type_skey <> src.customer_type_skey
          THEN target.customer_type_skey
        ELSE target.prev_customer_type_skey 
      END,
    target.customer_type_skey = src.customer_type_skey,
    -- SCD3 Logic for account_status
    target.prev_account_status_skey =
      CASE
        WHEN target.account_status_skey <> src.account_status_skey
          THEN target.account_status_skey
        ELSE target.prev_account_status_skey 
      END,
    target.account_status_skey = src.account_status_skey
  
  -- Insert new customers
  WHEN NOT MATCHED BY TARGET 
    THEN INSERT (
      [customer_id], 
      [signup_date], 
      [gender_skey], 
      [customer_dob], 
      [customer_age], 
      [first_name], 
      [middle_name], 
      [last_name], 
      [marital_status_skey], 
      [customer_type_skey], 
      [prev_customer_type_skey], 
      [account_status_skey], 
      [prev_account_status_skey], 
      [location_skey], 
      [email], 
      [phone],
      [start_date],
      [is_current]
    )
    VALUES (
      src.customer_id,
      src.signup_date,
      src.gender_skey,
      src.customer_dob,
      src.customer_age,
      src.first_name,
      src.middle_name,
      src.last_name,
      src.marital_status_skey,
      src.customer_type_skey,
      NULL, -- prev_customer_type_skey
      src.account_status_skey,
      NULL, -- prev_account_status_skey
      src.location_skey,
      src.email,
      src.phone,
      GETDATE(),
      1
    )
  -- Expire rows for customers no longer in source
  WHEN NOT MATCHED BY SOURCE
    THEN DELETE
  OUTPUT $action, inserted.*, deleted.*;

  
 -- =========================================================================================================
 -- =========================================================================================================
 -- =========================================================================================================
 -- ======================================= PRODUCT DIMENSION TABLE =======================================
 -- =========================================================================================================


  BEGIN
    -- Variables for "Unknown" values
    DECLARE 
      @unknown_brand_name_skey INT,
      @unknown_brand_tier_skey INT,
      @unknown_brand_country_skey INT,
      @unknown_brand_skey INT,
      @unknown_sub_category_skey INT;

    SELECT @unknown_brand_name_skey = brand_name_skey 
    FROM [gold].[dim_brand_name]
    WHERE brand_name = 'Unknown';

    SELECT @unknown_brand_tier_skey = brand_tier_skey 
    FROM [gold].[dim_brand_tier]
    WHERE brand_tier = 'Unknown';
      
    SELECT @unknown_brand_country_skey = brand_country_skey 
    FROM [gold].[dim_brand_country]
    WHERE brand_country = 'Unknown';

    SELECT @unknown_brand_skey = brand_skey 
    FROM [gold].[dim_brand]
    WHERE brand_name_skey = @unknown_brand_name_skey
      AND brand_tier_skey = @unknown_brand_tier_skey
      AND brand_country_skey = @unknown_brand_country_skey;
      
    SELECT @unknown_sub_category_skey = sub_category_skey 
    FROM [gold].[dim_sub_category]
    WHERE sub_category = 'Unknown';
    
        -- Drop temp tables only if they exist
    IF OBJECT_ID('tempdb..#utmp_ranked_products') IS NOT NULL
        DROP TABLE #utmp_ranked_products;
    
    IF OBJECT_ID('tempdb..#utmp_cte_src') IS NOT NULL
        DROP TABLE #utmp_cte_src;

    -- Create ranked products temp table
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY (SELECT 1)) AS rn
    INTO #utmp_ranked_products
    FROM [staging].[product] p
    WHERE p.product_id IS NOT NULL 
      AND p.product_id <> '';

    -- Create CTE source temp table
    SELECT
        rp.product_id AS [product_id],
        ISNULL(b.brand_skey, @unknown_brand_skey) AS [brand_skey],
        SUBSTRING(rp.product_name, 1, CHARINDEX('(', rp.product_name) - 1) AS [product_name],
        SUBSTRING(
            rp.product_name, 
            CHARINDEX('(', rp.product_name) + 1, 
            CHARINDEX(')', rp.product_name) - CHARINDEX('(', rp.product_name) - 1
        ) AS [product_description],
        rp.rating AS [rating],
        rp.no_of_ratings AS [no_of_ratings],
--        sc.sub_category_skey AS [sub_category_skey],
        ISNULL(sc.sub_category_skey, @unknown_sub_category_skey) AS sub_category_skey,
        rp.discount_percent AS [discount_percent],
        rp.actual_price AS [actual_price]
    INTO #utmp_cte_src
    FROM #utmp_ranked_products rp
    LEFT JOIN [gold].[dim_brand_name] bn 
        ON rp.brand_name = bn.brand_name
    LEFT JOIN [gold].[dim_brand_tier] bt 
        ON rp.brand_tier = bt.brand_tier
    LEFT JOIN [gold].[dim_brand_country] bc 
        ON rp.brand_country = bc.brand_country
    LEFT JOIN [gold].[dim_brand] b 
        ON b.brand_name_skey = ISNULL(bn.brand_name_skey, @unknown_brand_name_skey)
      AND b.brand_tier_skey = ISNULL(bt.brand_tier_skey, @unknown_brand_tier_skey)
      AND b.brand_country_skey = ISNULL(bc.brand_country_skey, @unknown_brand_country_skey)
    LEFT JOIN [gold].[dim_sub_category] sc 
        ON rp.sub_category = sc.sub_category
    WHERE rp.rn = 1
    ORDER BY rp.product_id;
  END

  --   SELECT * FROM #utmp_ranked_products
--     SELECT * FROM #utmp_cte_src
  ----------------------------------------------------------
    MERGE [gold].[dim_product] AS target
    USING [#utmp_cte_src] AS src
      ON target.product_id = src.product_id
        AND target.is_current = 1
    WHEN MATCHED AND (  
      target.product_id <> src.product_id OR
      target.brand_skey <> src.brand_skey OR
      target.product_name <> src.product_name OR
      target.product_description <> src.product_description OR
      target.rating <> src.rating OR
      target.no_of_ratings <> src.no_of_ratings OR
      target.sub_category_skey <> src.sub_category_skey OR
      target.discount_percent <> src.discount_percent OR
      target.actual_price <> src.actual_price
    )
    THEN UPDATE SET
      -- SCD2 Expiry Logic
      target.is_current = 
        CASE
          WHEN 
            target.sub_category_skey <> src.sub_category_skey
            OR target.discount_percent <> src.discount_percent
            OR target.actual_price <> src.actual_price
            THEN 0 
          ELSE target.is_current 
        END,
      target.end_date =
        CASE
          WHEN 
            target.sub_category_skey <> src.sub_category_skey
            OR target.discount_percent <> src.discount_percent
            OR target.actual_price <> src.actual_price
            THEN GETDATE() 
          ELSE target.end_date 
        END,
      -- SCD1 Overwrite
      target.brand_skey = src.brand_skey,
      target.product_name = src.product_name,
      target.product_description = src.product_description,
      -- SCD3 Logic for customer_type
      target.prev_rating =
        CASE
          WHEN target.rating <> src.rating
            THEN target.rating
          ELSE target.prev_rating 
        END,
      target.rating = src.rating,
      -- SCD3 Logic for account_status
      target.prev_no_of_ratings =
        CASE
          WHEN target.no_of_ratings <> src.no_of_ratings
            THEN target.no_of_ratings
          ELSE target.prev_no_of_ratings 
        END,
      target.no_of_ratings = src.no_of_ratings

    -- Insert new customers
    WHEN NOT MATCHED BY TARGET 
      THEN INSERT (
        [product_id], 
        [brand_skey], 
        [product_name], 
        [product_description], 
        [rating], 
        [prev_rating], 
        [no_of_ratings], 
        [prev_no_of_ratings], 
        [sub_category_skey],
        [discount_percent],
        [actual_price], 
        [start_date],
        [is_current]
      )
      VALUES (
        src.product_id,
        src.brand_skey,
        src.product_name,
        src.product_description,
        src.rating,
        NULL, -- prev_rating
        src.no_of_ratings,
        NULL, -- prev_no_of_ratings
        src.sub_category_skey,
        src.discount_percent,
        src.actual_price,
        GETDATE(),
        1
      )
    -- Expire rows for customers no longer in source
    WHEN NOT MATCHED BY SOURCE
      THEN DELETE
    OUTPUT $action, inserted.*, deleted.*;

-- =========================================================================================================
-- =========================================================================================================
-- =========================================================================================================
-- ======================================= ORDER DIMENSION TABLE =======================================
-- =========================================================================================================

  BEGIN
    -- Variables for "Unknown" values
    DECLARE @unknown_shipping_type_skey INT,
            @unknown_payment_source_skey INT,
            @unknown_lead_type_skey INT;

    SELECT @unknown_shipping_type_skey = shipping_type_skey 
      FROM [gold].[dim_shipping_type]
      WHERE shipping_type = 'Unknown';
    
    SELECT @unknown_payment_source_skey = payment_source_skey
      FROM [gold].[dim_payment_source]
      WHERE payment_source = 'Unknown';
    
    SELECT @unknown_lead_type_skey = lead_type_skey 
      FROM [gold].[dim_lead_type]
      WHERE lead_type = 'Unknown';

    -- Drop temp tables only if they exist
    IF OBJECT_ID('tempdb..#utmp_ranked_orders') IS NOT NULL
        DROP TABLE #utmp_ranked_orders;
    
    IF OBJECT_ID('tempdb..#utmp_order_cte_src') IS NOT NULL
        DROP TABLE #utmp_order_cte_src;

    -- Create ranked orders temp table to handle duplicates
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY (SELECT 1)) AS rn
    INTO #utmp_ranked_orders
    FROM [staging].[order] o
    WHERE o.order_id IS NOT NULL 
      AND o.order_id <> '';

    -- Create CTE source temp table
    SELECT DISTINCT
      ro.order_id,
      ISNULL(st.shipping_type_skey, @unknown_shipping_type_skey) AS shipping_type_skey,
      ISNULL(ps.payment_source_skey, @unknown_payment_source_skey) AS payment_source_skey,
      ISNULL(lt.lead_type_skey, @unknown_lead_type_skey) AS lead_type_skey,
      ro.order_date AS order_date,
      ro.expected_delivery_date AS expected_delivery_date,
      ro.shipping_date AS shipping_date,
      ro.delivery_date AS delivery_date,
      ro.return_date AS return_date,
      ro.refund_date AS refund_date,
      ro.has_coupon AS has_coupon,
      ro.has_coupon AS coupon_code
    INTO #utmp_order_cte_src
    FROM #utmp_ranked_orders ro
    LEFT JOIN [gold].[dim_shipping_type] st
      ON ro.shipping_type = st.shipping_type
    LEFT JOIN [gold].[dim_payment_source] ps
      ON ro.payment_source = ps.payment_source
    LEFT JOIN [gold].[dim_lead_type] lt
      ON ro.lead_type = lt.lead_type
    WHERE ro.rn = 1;

    -- MERGE logic for Order dimension (SCD-1 for most attributes)
    MERGE [gold].[dim_order] AS target
    USING [#utmp_order_cte_src] AS src
      ON target.order_id = src.order_id
    WHEN MATCHED AND (
      target.shipping_type_skey <> src.shipping_type_skey OR
      target.payment_source_skey <> src.payment_source_skey OR
      target.lead_type_skey <> src.lead_type_skey OR
      target.order_date <> src.order_date OR
      target.expected_delivery_date <> src.expected_delivery_date OR
      target.shipping_date <> src.shipping_date OR
      target.delivery_date <> src.delivery_date OR
      target.return_date <> src.return_date OR
      target.refund_date <> src.refund_date OR
      target.has_coupon <> src.has_coupon OR
      target.coupon_code <> src.coupon_code
    )
    THEN UPDATE SET
      -- SCD1 Overwrite for all attributes
      target.shipping_type_skey = src.shipping_type_skey,
      target.payment_source_skey = src.payment_source_skey,
      target.lead_type_skey = src.lead_type_skey,
      target.order_date = src.order_date,
      target.expected_delivery_date = src.expected_delivery_date,
      target.shipping_date = src.shipping_date,
      target.delivery_date = src.delivery_date,
      target.return_date = src.return_date,
      target.refund_date = src.refund_date,
      target.has_coupon = src.has_coupon,
      target.coupon_code = src.coupon_code

    -- Insert new orders
    WHEN NOT MATCHED BY TARGET 
      THEN INSERT (
        [order_id], 
        [shipping_type_skey], 
        [payment_source_skey], 
        [lead_type_skey], 
        [order_date], 
        [expected_delivery_date],
        [shipping_date], 
        [delivery_date], 
        [return_date], 
        [refund_date],
        [has_coupon], 
        [coupon_code]
      )
      VALUES (
        src.order_id,
        src.shipping_type_skey,
        src.payment_source_skey,
        src.lead_type_skey,
        src.order_date,
        src.expected_delivery_date,
        src.shipping_date,
        src.delivery_date,
        src.return_date,
        src.refund_date,
        src.has_coupon,
        src.coupon_code
      )
    -- Delete orders no longer in source
    WHEN NOT MATCHED BY SOURCE
      THEN DELETE
    OUTPUT $action, inserted.*, deleted.*;

  END

-- =========================================================================================================
-- =========================================================================================================
-- =========================================================================================================
-- ======================================= ORDER_PRODUCT DIMENSION TABLE =======================================
-- =========================================================================================================

  BEGIN
    -- Variables for "Unknown" values
    DECLARE @unknown_order_status_skey INT;
    
    SELECT @unknown_order_status_skey = order_status_skey 
      FROM [gold].[dim_order_status]
      WHERE order_status = 'Unknown';

    -- Drop temp tables only if they exist
    IF OBJECT_ID('tempdb..#utmp_order_product_cte_src') IS NOT NULL
        DROP TABLE #utmp_order_product_cte_src;

    -- Create CTE source temp table for order_product
    SELECT DISTINCT
      o.order_id,
      o.product_id,
      o.quantity AS quantity,
      o.unit_price AS unit_price,
      p.discount_percent AS discount_percent,
      p.actual_price AS actual_price,
      o.is_gift AS is_gift,
      o.is_gift AS gift_message,
      ISNULL(os.order_status_skey, @unknown_order_status_skey) AS order_status_skey,
      CASE 
        WHEN go.shipping_date > o.expected_delivery_date THEN go.shipping_date
        WHEN go.delivery_date > o.expected_delivery_date THEN go.delivery_date
        WHEN go.return_date > o.expected_delivery_date THEN go.return_date
        WHEN go.refund_date > o.expected_delivery_date THEN go.refund_date
        ELSE o.expected_delivery_date
      END AS current_shipping_date,
      go.order_skey,
      gp.product_skey
    INTO #utmp_order_product_cte_src
    FROM [staging].[order] o
    LEFT JOIN [gold].[dim_product] gp
      ON o.product_id = gp.product_id
      AND gp.is_current = 1
    LEFT JOIN [gold].[dim_order] go
      ON o.order_id = go.order_id
    LEFT JOIN [gold].[dim_order_status] os
      ON o.order_status = os.order_status
      AND os.is_current = 1
    WHERE 
      o.order_id IS NOT NULL AND o.order_id <> ''
      AND o.product_id IS NOT NULL AND o.product_id <> ''
      AND go.order_skey IS NOT NULL
      AND gp.product_skey IS NOT NULL;

    -- MERGE logic for Order_Product dimension
    MERGE [gold].[dim_order_product] AS target
    USING [#utmp_order_product_cte_src] AS src
      ON target.order_skey = src.order_skey
        AND target.product_skey = src.product_skey
        AND target.is_current = 1
    WHEN MATCHED AND (
      target.quantity <> src.quantity OR
      target.unit_price <> src.unit_price OR
      target.discount_percent <> src.discount_percent OR
      target.actual_price <> src.actual_price OR
      target.is_gift <> src.is_gift OR
      target.gift_message <> src.gift_message OR
      target.order_status_skey <> src.order_status_skey OR
      ISNULL(target.current_shipping_date, '1900-01-01') <> ISNULL(src.current_shipping_date, '1900-01-01')
    )
    THEN UPDATE SET
      -- SCD2 Expiry Logic for status and shipping date changes
      target.is_current = 
        CASE
          WHEN 
            target.order_status_skey <> src.order_status_skey
            OR ISNULL(target.current_shipping_date, '1900-01-01') <> ISNULL(src.current_shipping_date, '1900-01-01')
            THEN 0 
          ELSE target.is_current 
        END,
      target.end_date =
        CASE
          WHEN 
            target.order_status_skey <> src.order_status_skey
            OR ISNULL(target.current_shipping_date, '1900-01-01') <> ISNULL(src.current_shipping_date, '1900-01-01')
            THEN GETDATE() 
          ELSE target.end_date 
        END,
      -- SCD1 Overwrite for other attributes
      target.quantity = src.quantity,
      target.unit_price = src.unit_price,
      target.discount_percent = src.discount_percent,
      target.actual_price = src.actual_price,
      target.is_gift = src.is_gift,
      target.gift_message = src.gift_message

    -- Insert new order-product combinations
    WHEN NOT MATCHED BY TARGET 
      THEN INSERT (
        [order_skey], 
        [product_skey],
        [quantity],
        [unit_price],
        [discount_percent],
        [actual_price],
        [is_gift], 
        [gift_message],
        [order_status_skey],
        [current_shipping_date],
        [start_date],
        [is_current]
      )
      VALUES (
        src.order_skey,
        src.product_skey,
        src.quantity,
        src.unit_price,
        src.discount_percent,
        src.actual_price,
        src.is_gift,
        src.gift_message,
        src.order_status_skey,
        src.current_shipping_date,
        GETDATE(),
        1
      )
    -- Delete order-products no longer in source
    WHEN NOT MATCHED BY SOURCE
      THEN DELETE
    OUTPUT $action, inserted.*, deleted.*;

    -- Insert new SCD2 rows for changed order status or shipping dates
    INSERT INTO [gold].[dim_order_product] (
      [order_skey], 
      [product_skey],
      [quantity],
      [unit_price],
      [discount_percent],
      [actual_price],
      [is_gift], 
      [gift_message],
      [order_status_skey],
      [current_shipping_date],
      [start_date],
      [is_current]
    )
    SELECT
      src.order_skey,
      src.product_skey,
      src.quantity,
      src.unit_price,
      src.discount_percent,
      src.actual_price,
      src.is_gift,
      src.gift_message,
      src.order_status_skey,
      src.current_shipping_date,
      GETDATE(),
      1
    FROM #utmp_order_product_cte_src AS src
    WHERE EXISTS (
      SELECT 1 
      FROM [gold].[dim_order_product] target
      WHERE target.order_skey = src.order_skey
        AND target.product_skey = src.product_skey
        AND target.is_current = 0
        AND target.end_date = CAST(GETDATE() AS DATE)
    );

  END

-- =========================================================================================================
-- =========================================================================================================
-- =========================================================================================================
-- ======================================= FACT SALES TABLE =======================================
-- =========================================================================================================

  BEGIN
    -- Drop temp tables only if they exist
    IF OBJECT_ID('tempdb..#utmp_fact_sales_cte_src') IS NOT NULL
        DROP TABLE #utmp_fact_sales_cte_src;

    IF OBJECT_ID('tempdb..#utmp_sales_with_rownum') IS NOT NULL
        DROP TABLE #utmp_sales_with_rownum;

    -- Step 1: Create comprehensive source data with all necessary joins
    SELECT 
      op.order_product_skey,
      c.customer_skey,
      op.quantity,
      op.unit_price,
      op.discount_percent,
      -- Calculate discount amount with proper rounding
      ROUND(op.quantity * op.unit_price * op.discount_percent / 100, 2) AS discount_amount,
      -- Calculate total amount with proper rounding
      ROUND((op.quantity * op.unit_price) - (op.quantity * op.unit_price * op.discount_percent / 100), 2) AS total_amount,
      CASE 
        WHEN os.order_status = 'Returned' THEN 1 
        ELSE 0 
      END AS is_returned,
      o.order_date,
      go.order_id,
      gp.product_id
    INTO #utmp_fact_sales_cte_src
    FROM [gold].[dim_order_product] op
    JOIN [gold].[dim_order] go
      ON op.order_skey = go.order_skey
    JOIN [gold].[dim_product] gp
      ON op.product_skey = gp.product_skey
      AND gp.is_current = 1
    JOIN [staging].[order] so
      ON go.order_id = so.order_id
      AND gp.product_id = so.product_id
    JOIN [gold].[dim_customer] c
      ON so.customer_id = c.customer_id
      AND c.is_current = 1
    LEFT JOIN [gold].[dim_order_status] os
      ON op.order_status_skey = os.order_status_skey
      AND os.is_current = 1
    WHERE 
      op.is_current = 1
      AND op.quantity > 0  -- Only process valid quantities
      AND op.unit_price >= 0;  -- Only process valid prices

    -- Step 2: Add sequential sales_id to the source data
    SELECT 
      ROW_NUMBER() OVER (ORDER BY order_date, order_product_skey) AS sales_id,
      *
    INTO #utmp_sales_with_rownum
    FROM #utmp_fact_sales_cte_src;

    -- Step 3: Insert into fact sales table with validation
    INSERT INTO [gold].[fact_sales] (
      [sales_id],
      [order_product_skey],
      [customer_skey],
      [quantity],
      [unit_price],
      [discount_percent],
      [discount_amount],
      [total_amount],
      [is_returned]
    )
    SELECT 
      src.sales_id,
      src.order_product_skey,
      src.customer_skey,
      src.quantity,
      src.unit_price,
      src.discount_percent,
      src.discount_amount,
      src.total_amount,
      src.is_returned
    FROM #utmp_sales_with_rownum src
    LEFT JOIN [gold].[fact_sales] existing
      ON src.order_product_skey = existing.order_product_skey
      AND src.customer_skey = existing.customer_skey
    WHERE 
      existing.sales_skey IS NULL  -- Only insert if not already exists
      AND src.order_product_skey IS NOT NULL
      AND src.customer_skey IS NOT NULL
      AND src.total_amount >= 0;  -- Additional validation

    -- Clean up temp tables
    IF OBJECT_ID('tempdb..#utmp_fact_sales_cte_src') IS NOT NULL
        DROP TABLE #utmp_fact_sales_cte_src;

    IF OBJECT_ID('tempdb..#utmp_sales_with_rownum') IS NOT NULL
        DROP TABLE #utmp_sales_with_rownum;

  END

END;
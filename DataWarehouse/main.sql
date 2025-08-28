--IF NOT EXISTS (
--    SELECT name 
--    FROM sys.databases 
--    WHERE name = 'associatetraining'
--)

/*
=============================================================================================
Description:
    - This script checks if the associatetraining database exists. 
    - If it doesn't, it creates the database and then sets up the required schemas: bronze, staging, gold.
    - It avoids re-creating any database or schema that already exists.
    - Finally, it executes the stored procedure to create tables in the bronze schema.
=============================================================================================
*/

USE [associatetraining];

-- ======================================================================
-- ======================================================================


IF DB_ID('associatetraining') IS NULL
	BEGIN
        PRINT 'Creating Database associatetraining...'
        CREATE DATABASE [associatetraining]
        PRINT 'Database associatetraining created successfully.'
	END
ELSE
    BEGIN
        PRINT 'Database associatetraining already exists. No action taken.'
    END

-- ======================================================================

IF SCHEMA_ID('raw') IS NULL
    BEGIN
        PRINT 'Creating Schema raw...'
        EXEC('CREATE SCHEMA raw')
        PRINT 'Schema raw created successfully.'
    END
ELSE
    BEGIN
        PRINT 'Schema raw already exists. No action taken.'
    END

-- -----------------------------------------------------------------------
IF SCHEMA_ID('bronze') IS NULL
    BEGIN
        PRINT 'Creating Schema bronze...'
        EXEC('CREATE SCHEMA bronze')
        PRINT 'Schema bronze created successfully.'
    END
ELSE
    BEGIN
        PRINT 'Schema bronze already exists. No action taken.'
    END

-- -----------------------------------------------------------------------

IF SCHEMA_ID('staging') IS NULL
    BEGIN
        PRINT 'Creating Schema staging...'
        EXEC('CREATE SCHEMA staging')
        PRINT 'Schema staging created successfully.'
    END
ELSE
    BEGIN
        PRINT 'Schema staging already exists. No action taken.'
    END

-- -----------------------------------------------------------------------
IF SCHEMA_ID('gold') IS NULL
    BEGIN
        PRINT 'Creating Schema gold...'
        EXEC('CREATE SCHEMA gold')
        PRINT 'Schema gold created successfully.'
    END
ELSE
    BEGIN
        PRINT 'Schema gold already exists. No action taken.'
    END


-- ======================================================================
-- RAW
-- ======================================================================

--EXECUTE [raw].[usp_create_tables]

--EXECUTE [raw].[usp_drop_schema] [raw];

-- ======================================================================
-- BRONZE
-- ======================================================================
    
--EXECUTE [bronze].[usp_create_tables]
--EXECUTE [bronze].[usp_create_tables_hist]

--EXECUTE [raw].[usp_drop_schema] [bronze];
-- -----------------------------------------------------------------------
--DELETE FROM [bronze].[batch_audit]
--DBCC CHECKIDENT ('[bronze].[batch_audit]', RESEED, 0)

--EXEC [bronze].[usp_load]
--EXEC [bronze].[usp_load_hist]

-- ======================================================================
-- STAGING
-- ======================================================================

EXECUTE [staging].[usp_create_tables]
EXECUTE [staging].[usp_create_tables_hist]

--EXECUTE [raw].[usp_drop_schema] [staging];
-- -----------------------------------------------------------------------
--DELETE FROM [staging].[batch_audit]
--DBCC CHECKIDENT ('[staging].[batch_audit]', RESEED, 0)

EXEC [staging].[usp_load]
EXEC [staging].[usp_load_hist]

-- ======================================================================
-- GOLD
-- ======================================================================

-- -----------------------------------------------------------------------
IF SCHEMA_ID('gold') IS NULL
    BEGIN
        PRINT 'Creating Schema gold...'
        EXEC('CREATE SCHEMA gold')
        PRINT 'Schema gold created successfully.'
    END
ELSE
    BEGIN
        PRINT 'Schema gold already exists. No action taken.'
    END
    
EXECUTE [gold].[usp_create_tables]

--EXECUTE [raw].[usp_drop_schema] [gold];
-- -----------------------------------------------------------------------
--DELETE FROM [gold].[batch_audit]
--DBCC CHECKIDENT ('[gold].[batch_audit]', RESEED, 0)

EXEC [gold].[usp_load]











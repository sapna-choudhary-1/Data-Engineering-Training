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
-- FUNCTIONS
-- ======================================================================
CREATE OR ALTER FUNCTION [staging].[fnToTitleCase] (@input NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @output NVARCHAR(MAX) = ''
    SELECT @output = 
        STRING_AGG(
                UPPER(LEFT(value, 1)) + LOWER(SUBSTRING(value, 2, LEN(value))),
                ' '
            )
        FROM STRING_SPLIT(@input, ' ')
        WHERE LEN(value) > 0
        RETURN @output
END;

-- Create function
CREATE OR ALTER FUNCTION [staging].[fnRemoveSpecialChars] (@str NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @clean NVARCHAR(MAX) = ''
    DECLARE @i INT = 1
    WHILE @i <= LEN(@str)
    BEGIN
        IF UNICODE(SUBSTRING(@str, @i, 1)) BETWEEN 48 AND 57 -- 0–9
           OR UNICODE(SUBSTRING(@str, @i, 1)) BETWEEN 65 AND 90 -- A–Z
           OR UNICODE(SUBSTRING(@str, @i, 1)) BETWEEN 97 AND 122 -- a–z
           OR SUBSTRING(@str, @i, 1) = ' ' -- space
           OR SUBSTRING(@str, @i, 1) = '-' -- dash           
           OR SUBSTRING(@str, @i, 1) = '_' -- underscore
        BEGIN
            SET @clean += SUBSTRING(@str, @i, 1)
        END
        SET @i += 1
    END
    RETURN @clean
END;
-- Create function
CREATE OR ALTER FUNCTION [staging].[fnClean] (@str NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @result NVARCHAR(MAX) = ''
    BEGIN
	    SET @result = TRIM(@str)
	    SET @result = [staging].[fnRemoveSpecialChars] (@result)
	    SET @result = [staging].[fnToTitleCase] (@result)
	    SET @result = TRIM(@result)
	END
    RETURN @result
END;

-- Create function
CREATE OR ALTER FUNCTION [staging].[fnTranslation] (@str NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @to_be_replaced NVARCHAR(MAX) = '34105'
    DECLARE @to_replace_with NVARCHAR(MAX) = 'eaios'
    DECLARE @result NVARCHAR(MAX) = ''
    BEGIN
	    SET @result = [staging].[fnClean] (@str)
	    SET @result = TRANSLATE(@result, @to_be_replaced, @to_replace_with)
	    SET @result = TRIM(@result)
	END
    RETURN @result
END;

-- Create function
CREATE OR ALTER FUNCTION [staging].[fnDateToInt] (@str NVARCHAR(MAX))
RETURNS INT
AS
BEGIN
    DECLARE @result NVARCHAR(MAX) = ''
    DECLARE @dateVal DATE;
    DECLARE @intResult INT;
    BEGIN
	    SET @result = TRIM(@str)
	    SET @dateVal = CAST(@result AS DATE)
	    SET @result = FORMAT(@dateVal, 'ddMMyyyy')
	    SET @intResult = CAST(@result AS INT)
	END
    RETURN @intResult
END;


-- Create function
CREATE OR ALTER FUNCTION [staging].[fnClean&ValidateEmail] (@str NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @result NVARCHAR(MAX) = ''
    DECLARE @i INT = 1

    -- Step 1: Remove unwanted characters
    WHILE @i <= LEN(@str)
    BEGIN
        IF UNICODE(SUBSTRING(@str, @i, 1)) BETWEEN 48 AND 57 -- 0–9
           OR UNICODE(SUBSTRING(@str, @i, 1)) BETWEEN 65 AND 90 -- A–Z
           OR UNICODE(SUBSTRING(@str, @i, 1)) BETWEEN 97 AND 122 -- a–z
           OR SUBSTRING(@str, @i, 1) IN ('_', '.', '@')
        BEGIN
            SET @result += SUBSTRING(@str, @i, 1)
        END
        SET @i += 1
    END

    -- Step 2: Lowercase cleaned value
    SET @result = LOWER(@result)

    -- Step 3: Validation
    -- a. Must contain exactly one '@'
    IF LEN(@result) - LEN(REPLACE(@result, '@', '')) <> 1
        RETURN NULL;

    -- b. Must not contain consecutive dots
    IF CHARINDEX('..', @result) > 0
        RETURN NULL;

    -- c. Must not start or end with a dot or @
    IF LEFT(@result,1) IN ('.','@') OR RIGHT(@result,1) IN ('.','@') 
        RETURN NULL;

    -- d. Must contain at least one '.' after '@'
    DECLARE @at_pos INT = CHARINDEX('@', @result)
    IF CHARINDEX('.', @result, @at_pos) = 0
        RETURN NULL;

    RETURN @result;
END;




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











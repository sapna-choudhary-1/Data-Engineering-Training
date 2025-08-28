
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
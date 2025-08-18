USE [associatetraining];

CREATE OR ALTER PROCEDURE [raw].[usp_drop_schema] 
    @schema_name NVARCHAR(128)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX) = ''
    -- Drop all foreign key constraints in the staging schema
    SET @sql = ''
    SELECT @sql += 
    'ALTER TABLE [' + s.name + '].[' + t.name + '] DROP CONSTRAINT [' + fk.name + ']' + CHAR(13)
    FROM sys.foreign_keys fk
    JOIN sys.tables t ON fk.parent_object_id = t.object_id
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE s.name = @schema_name
    EXEC sp_executesql @sql

    -- Drop all stored procedures
    SET @sql = ''
    SELECT @sql += 'DROP PROCEDURE IF EXISTS [' + SCHEMA_NAME(schema_id) + '].[' + name + ']' + CHAR(13)
    FROM sys.procedures
    WHERE SCHEMA_NAME(schema_id) = @schema_name
    EXEC sp_executesql @sql

    -- Drop all functions
    SET @sql = ''
    SELECT @sql += 'DROP FUNCTION IF EXISTS [' + SCHEMA_NAME(schema_id) + '].[' + name + ']' + CHAR(13)
    FROM sys.objects
    WHERE type IN ('FN', 'IF', 'TF') AND SCHEMA_NAME(schema_id) = @schema_name
    EXEC sp_executesql @sql

    -- Drop all views
    SET @sql = ''
    SELECT @sql += 'DROP VIEW IF EXISTS [' + SCHEMA_NAME(schema_id) + '].[' + name + ']' + CHAR(13)
    FROM sys.views
    WHERE SCHEMA_NAME(schema_id) = @schema_name
    EXEC sp_executesql @sql

    -- Drop all tables
    SET @sql = ''
    SELECT @sql += 'DROP TABLE IF EXISTS [' + SCHEMA_NAME(schema_id) + '].[' + name + ']' + CHAR(13)
    FROM sys.tables
    WHERE SCHEMA_NAME(schema_id) = @schema_name
    EXEC sp_executesql @sql

    -- Finally, drop the schema
    SET @sql = 'DROP SCHEMA IF EXISTS [' + @schema_name + ']'
	EXEC sp_executesql @sql

END

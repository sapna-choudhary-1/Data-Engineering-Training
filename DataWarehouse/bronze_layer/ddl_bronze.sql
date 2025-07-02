/*
=============================================================================================
DDL Script: Create Bronze Layer Tables
=============================================================================================
Purpose:
	- This script creates tables in the 'bronze' schema, in the 'DWH' database
	- Drops tables if they already exist
=============================================================================================
*/

USE DWH;

IF OBJECT_ID('bronze.FactSales', 'U') IS NOT NULL
	DROP TABLE bronze.FactSales
CREATE TABLE bronze.FactSales (
  [OrderID] INT,
  [DateID] INT,
  [CustomerID] INT,
  [ProductID] INT,
  [UserID] INT,
  [Quantity] INT,
  [UnitPrice] DECIMAL(10,2) NULL
)

IF OBJECT_ID('bronze.CustomerInfo', 'U') IS NOT NULL
	DROP TABLE bronze.CustomerInfo
CREATE TABLE bronze.CustomerInfo (
  [CustomerID] INT,
  [CustomerName] NVARCHAR(50),
  [Region] NVARCHAR(50),
  [SignupDate] DATE
)

IF OBJECT_ID('bronze.ProductInfo', 'U') IS NOT NULL
	DROP TABLE bronze.ProductInfo
CREATE TABLE bronze.ProductInfo (
  [ProductID] INT,
  [ProductName] NVARCHAR(1000),
  [CategoryID] INT,
  [ProductTypeID] INT,
  [DiscountPrice] DECIMAL(10,2),
  [ActualPrice] DECIMAL(10,2),
--  [Rating] DECIMAL(10,1) NULL,
  [Rating] NVARCHAR(100)NULL,
--  [NoOfRatings] INT NULL
    [NoOfRatings] NVARCHAR(100) NULL
)

IF OBJECT_ID('bronze.ProductType', 'U') IS NOT NULL
	DROP TABLE bronze.ProductType
CREATE TABLE bronze.ProductType (
  [ProductTypeID] INT,
  [SubCategory] NVARCHAR(50)
)

IF OBJECT_ID('bronze.OrderInfo', 'U') IS NOT NULL
	DROP TABLE bronze.OrderInfo
CREATE TABLE bronze.OrderInfo (
  [OrderID] INT,
  [CustomerID] INT,
  [OrderDate] DATE,
  [DateID] INT
)

IF OBJECT_ID('bronze.Category', 'U') IS NOT NULL
	DROP TABLE bronze.Category
CREATE TABLE bronze.Category (
  [CategoryID] INT,
  [MainCategory] NVARCHAR(50)
)

IF OBJECT_ID('bronze.DateInfo', 'U') IS NOT NULL
	DROP TABLE bronze.DateInfo
CREATE TABLE bronze.DateInfo (
  [DateID] INT,
  [Date] DATE,
  [Year] INT,
  [Month] INT,
  [Day] INT,
  [Weekday] INT
)

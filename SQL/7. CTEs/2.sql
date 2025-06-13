
------------------------------------------------------------------------------
---- PIVOT OPERATOR ----
------------------------------------------------------------------------------
USE [db1];

DROP TABLE [tblSales];

CREATE TABLE [tblSales]
(
agent NVARCHAR(20),
country NVARCHAR(20),
amt INT
);

INSERT INTO [tblSales] VALUES
('Tom', 'UK', 200),
('John', 'US', 180),
('John', 'UK', 260),
('David', 'India', 450),
('Tom', 'India', 350),
('David', 'US', 200),
('Tom', 'US', 130),
('John', 'India', 540),
('John', 'UK', 120),
('David', 'UK', 220),
('John', 'UK', 420),
('David', 'US', 320),
('Tom', 'US', 340),
('Tom', 'UK', 660),
('John', 'India', 430),
('David', 'India', 230),
('David', 'India', 280),
('Tom', 'UK', 480),
('John', 'US', 360),
('David', 'UK', 140);

SELECT * FROM [tblSales];
SELECT * FROM [tblEm];

------------------------------------------------------------------------------
--(Q1) Show total sales per agent per country using PIVOT.
-- Output columns: agent, [India], [US], [UK].
------------------------------------------------------------------------------

------------------------------------------------------------------------------
---- USING GROUP BY ----

SELECT agent, country, SUM(amt) AS total
FROM [tblSales]
GROUP BY agent, country
ORDER BY agent, country;


------------------------------------------------------------------------------
---- USING PIVOT ----

SELECT agent, India, UK, US
FROM [tblSales]
PIVOT (
--	SUM(amt) AS total-- ❌ Can't alias the aggreagate function 
	SUM(amt)
	FOR country IN ([India], [UK], [US])
	)
AS pivotTbl;


------------------------------------------------------------------------------
---- If extra columns present ----
USE [db1];

DROP TABLE [tblSales2];

CREATE TABLE [tblSales2]
(
id INT IDENTITY(1,1) PRIMARY KEY,
agent NVARCHAR(20),
country NVARCHAR(20),
amt INT
);

INSERT INTO [tblSales2] VALUES
('Tom', 'UK', 200),
('John', 'US', 180),
('John', 'UK', 260),
('David', 'India', 450),
('Tom', 'India', 350),
('David', 'US', 200),
('John', 'India', 540),
('John', 'UK', 120),
('David', 'UK', 220),
('John', 'UK', 420),
('David', 'US', 320),
('Tom', 'UK', 660),
('John', 'India', 430),
('David', 'India', 230),
('David', 'India', 280),
('Tom', 'UK', 480),
('John', 'US', 360),
('David', 'UK', 140);

SELECT * FROM [tblSales2];

------------------------------------------------------------------------------
---- USING PIVOT ----
--❌ Won't give correct output: Individual rows returned not the sum of salary

SELECT agent, India, US, UK
FROM [tblSales2]
PIVOT ( 
	SUM(amt)
	FOR country
	IN ([India], [US], [UK])
	)
AS pivotTbl;


------------------------------------------------------------------------------
---- Using Derived Tables: to work on just the reqd cols ----

SELECT agent, India, US, UK
FROM (
	SELECT agent, country, amt
	FROM [tblSales2]
	)
AS srcTbl
PIVOT ( 
	SUM(amt)
	FOR country
	IN ([India], [US], [UK])
	)
AS pivotTbl;


------------------------------------------------------------------------------
--(Q2) Show total amount earned by each country (not agent). Use PIVOT.
--➤ You’ll need to flip the axes: country as row, agent as column.
------------------------------------------------------------------------------
SELECT country, [Tom], [David], [John]
FROM  (
	SELECT agent, amt, country
	FROM [tblSales2]
	) AS src
PIVOT (
	SUM(amt)
	FOR agent IN ([Tom], [David], [John])
) AS pvt;


------------------------------------------------------------------------------
--(Q2) Add a new column that shows the Total Sales (sum of India, US, UK) for each agent.
------------------------------------------------------------------------------
SELECT agent, [India], [UK], [US], 
	ISNULL([India], 0) + ISNULL([UK], 0) + ISNULL([US], 0) AS total_sales
FROM (
	SELECT agent, amt, country
	FROM [tblSales2]
	) AS src
PIVOT (
	SUM(amt)
	FOR country IN ([India], [UK], [US])
) AS pvt

------------------------------------------------------------------------------
--(Q3) Add a new column for each country’s average amount sold per agent.
--➤ Use PIVOT with AVG(amt).
------------------------------------------------------------------------------
SELECT agent, [India], [UK], [US]
FROM (
	SELECT agent, amt, country
	FROM [tblSales2]
	) AS src
PIVOT (
	AVG(amt)
	FOR country IN ([India], [UK], [US])
) AS pvt

------------------------------------------------------------------------------
--(Q4) Add a count version: Show number of transactions each agent made in each country.
--➤ Use COUNT(amt) instead of SUM.
------------------------------------------------------------------------------
SELECT agent, [India], [UK], [US]
FROM (
	SELECT agent, amt, country
	FROM [tblSales2]
	) AS src
PIVOT (
	COUNT(amt)
	FOR country IN ([India], [UK], [US])
) AS pvt

------------------------------------------------------------------------------
--(Q5) For each agent, show max amount sold in each country (i.e., best deal).
--➤ Use MAX(amt).
------------------------------------------------------------------------------
SELECT agent, [India], [UK], [US]
FROM (
	SELECT agent, amt, country
	FROM [tblSales2]
	) AS src
PIVOT (
	MAX(amt)
	FOR country IN ([India], [UK], [US])
) AS pvt

------------------------------------------------------------------------------
--(Q6) Find the agent(s) who sold more than ₹1000 total in any single country.
------------------------------------------------------------------------------
WITH [cteTblSales]
AS (
	SELECT agent, [India], [UK], [US]
	FROM (
		SELECT agent, amt, country
		FROM [tblSales2]
		) AS src
	PIVOT (
		SUM(amt)
		FOR country IN ([India], [UK], [US])
	) AS pvt
)
SELECT * FROM [cteTblSales]
WHERE ISNULL([India], 0)>1000 OR ISNULL([UK], 0)>1000 OR ISNULL([US], 0)>1000;


------------------------------------------------------------------------------
--(Q7) Show agent-wise total amount sold in each country, 
--but include only agents who have sold in all 3 countries, and sort by total amount in India descending.
------------------------------------------------------------------------------
WITH [cteTblSales]
AS (
	SELECT agent, COUNT(DISTINCT(country)) AS country_cnt
	FROM [tblSales2]
	GROUP BY agent
)
--SELECT * FROM cteTblSales
SELECT pvt.agent, [India], [UK], [US]
FROM (
	SELECT agent, amt, country
	FROM [tblSales2]
	) AS src
PIVOT (
	SUM(amt)
	FOR country IN ([India], [UK], [US])
) AS pvt
JOIN [cteTblSales] c
ON pvt.agent = c.agent
WHERE c.country_cnt = 3
ORDER BY [India] DESC;


------------------------------------------------------------------------------
--(Q8) Create a pivot showing month-wise sales per agent
--➤ add a sale_date column and test
------------------------------------------------------------------------------
ALTER TABLE [tblSales2]
ADD sale_date DATE;

SELECT * FROM [tblSales2];

-- Assigning sample sale dates across different months
UPDATE [tblSales2]
SET sale_date = CASE id
    WHEN 1 THEN '2024-01-10'
    WHEN 2 THEN '2024-01-15'
    WHEN 3 THEN '2024-02-12'
    WHEN 4 THEN '2024-02-18'
    WHEN 5 THEN '2024-03-05'
    WHEN 6 THEN '2024-03-10'
    WHEN 7 THEN '2024-04-01'
    WHEN 8 THEN '2024-04-12'
    WHEN 9 THEN '2024-05-25'
    WHEN 10 THEN '2024-06-01'
    WHEN 11 THEN '2024-06-10'
    WHEN 12 THEN '2024-07-05'
    WHEN 13 THEN '2024-08-01'
    WHEN 14 THEN '2024-08-15'
    WHEN 15 THEN '2024-09-10'
    WHEN 16 THEN '2024-09-20'
    WHEN 17 THEN '2024-10-05'
    WHEN 18 THEN '2024-10-18'
END;

SELECT id, agent, amt, sale_date, 
       DATENAME(MONTH, sale_date) AS full_month, 
       LEFT(DATENAME(MONTH, sale_date), 3) AS short_month,
       FORMAT(sale_date, 'MMM') AS short_month
FROM tblSales2
ORDER BY agent;

---- Using Pivot ----
SELECT agent, [Jan], [Feb], [Mar], [Apr], [May], [Jun], [Jul], [Aug], [Sep], [Oct], [Nov], [Dec]
FROM (
	SELECT 
		agent,
		FORMAT(sale_date, 'MMM') AS sale_month,
		amt
	FROM [tblSales2]
	) AS src
PIVOT (
	SUM(amt)
	FOR sale_month
	IN ([Jan], [Feb], [Mar], [Apr], [May], [Jun], [Jul], [Aug], [Sep], [Oct], [Nov], [Dec])
) AS pvt;


------------------------------------------------------------------------------
---- UNPIVOT OPERATOR ----
------------------------------------------------------------------------------
DROP TABLE [SalesByQuarter];

CREATE TABLE SalesByQuarter (
    name NVARCHAR(50),
    q1 INT,
    q2 INT,
    q3 INT,
    q4 INT
);

INSERT INTO SalesByQuarter VALUES
('Alice', 1000, 1500, 1200, 1300),
('Bob', 900, 1100, 950, 1000);

SELECT * FROM [SalesByQuarter];


------------------------------------------------------------------------------
--(Q1) UNPIVOT SalesByQuarter to show each salesperson's quarterly sales in a vertical list.
------------------------------------------------------------------------------
SELECT name, [Quarter], [SalesAmt]
FROM [SalesByQuarter]
UNPIVOT (
	[SalesAmt]
	FOR [Quarter]
	IN (q1, q2, q3, q4)
) AS unpvt;


------------------------------------------------------------------------------
--(Q2) Unpivot the previous [tblSales] table from it's pivoted form
------------------------------------------------------------------------------
SELECT * FROM [tblSales];

DROP TABLE [tblSales3];

SELECT agent, [India], [UK], [US]
INTO [tblSales3]
FROM (
	SELECT agent, amt, country
	FROM [tblSales2]
	) AS src
PIVOT (
	SUM(amt)
	FOR country IN ([India], [UK], [US])
) AS pvt;

SELECT * FROM [tblSales3];


---- Directly ----
SELECT agent, country, amount
FROM [tblSales3]
UNPIVOT (
	amount
	FOR country IN ([India], [UK], [US])
) AS unpvt;


---- From Pivot table ----
SELECT agent, country, amount
FROM (
	SELECT agent, [India], [UK], [US]
	FROM (
		SELECT agent, amt, country
		FROM [tblSales2]
		) AS src
	PIVOT (
		SUM(amt)
		FOR country IN ([India], [UK], [US])
	) AS pvt
) AS pvtTbl
UNPIVOT (
	amount
	FOR country IN ([India], [UK], [US])
) AS unpvt;


------------------------------------------------------------------------------
---- UNPIVOT back from PIVOT table doesn't work right ----
------------------------------------------------------------------------------

----❗❗Excludes the NULL values by default❗❗ ----
----❗❗Don't know how to undo the Aggregation (on same row-col val pairs)❗❗ ----

DROP TABLE [tblProductSales];

CREATE TABLE [tblProductSales]
(SalesAgent NVARCHAR(10), Country NVARCHAR(10), SalesAmount INT);

INSERT INTO [tblProductSales] VALUES 
('David', 'India', 960),
('David', 'US', 520),
('John', 'India', 970),
('John', 'US', 540),
('David','India',100);

SELECT * FROM [tblProductSales];

---- Pivoting ----
SELECT SalesAgent, India, US
FROM [tblProductSales]
PIVOT
(
     SUM(SalesAmount)
     FOR Country IN (India, US)
) AS PivotTable


---- Unpivoting Back ----
----❗❗David for country India got only 1 row with aggregated sales instead of original 2 rows❗❗ ----
SELECT SalesAgent, Country, SalesAmount
FROM (
	SELECT SalesAgent, India, US
	FROM tblProductSales
	PIVOT(SUM(SalesAmount) FOR Country IN (India, US)) AS PivotTable
	) P
UNPIVOT(SalesAmount FOR Country IN (India, US)) AS UnpivotTable





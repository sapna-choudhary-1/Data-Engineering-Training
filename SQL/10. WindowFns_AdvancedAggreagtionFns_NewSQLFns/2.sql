
------------------------------------------------------------------------------
---- ADVANCED AGGREGATIONS ----
------------------------------------------------------------------------------
USE [db1];

DROP TABLE [tblEmployees];

CREATE TABLE [tblEmployees] (Id INT PRIMARY KEY, Name NVARCHAR(50), Gender NVARCHAR(10), Salary INT, Country NVARCHAR(10))

INSERT INTO [tblEmployees] VALUES 
(1, 'Mark', 'Male', 5000, 'USA'),
(2, 'John', 'Male', 4500, 'India'),
(3, 'Pam', 'Female', 5500, 'USA'),
(4, 'Sara', 'Female', 4000, 'India'),
(5, 'Todd', 'Male', 3500, 'India'),
(6, 'Mary', 'Female', 5000, 'UK'),
(7, 'Ben', 'Male', 6500, 'UK'),
(8, 'Elizabeth', 'Female', 7000, 'USA'),
(9, 'Tom', 'Male', 5500, 'UK'),
(10, 'Ron', 'Male', 5000, 'USA');

SELECT * FROM [tblEmployees];

------------------------------------------------------------------------------
---- GROUPING SETS ----
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--(Q1) Fetch sum of salary by (country and gender), (country), (gender), (grand total) ----
------------------------------------------------------------------------------

---- fetching sum of salary for each country, for each gender ----
SELECT country, gender, SUM(salary) AS sumSalary
FROM [tblEmployees]
GROUP BY country, gender;

---- fetching sum of salary for each country => sum salary by country ----
SELECT country, NULL AS gender, SUM(salary) AS sumSalary
FROM [tblEmployees]
GROUP BY country;

---- fetching sum of salary for each country => sum salary by gender ----
SELECT NULL AS country, gender, SUM(salary) AS sumSalary
FROM [tblEmployees]
GROUP BY gender;

---- fetching sum of salary across all countries ----
SELECT NULL AS country, NULL AS gender, SUM(salary) AS sumSalary
FROM [tblEmployees];


------------------------------------------------------------------------------
---- Method-1: Using Union: fetching sum of salary by (country and gender), (country), (gender), (grand total): Altogether ----
SELECT country, gender, SUM(salary) AS sumSalary
FROM [tblEmployees]
GROUP BY country, gender
--
UNION ALL
SELECT country, NULL AS gender, SUM(salary) AS sumSalary
FROM [tblEmployees]
GROUP BY country
--
UNION ALL
SELECT NULL AS country, gender, SUM(salary) AS sumSalary
FROM [tblEmployees]
GROUP BY gender
--
UNION ALL
SELECT NULL AS country, NULL AS gender, SUM(salary) AS sumSalary
FROM [tblEmployees];


------------------------------------------------------------------------------
---- Method-2: Using Grouping Sets() ----

-- Ordering: gender -> country (defined by (group-set 1)
SELECT country, gender, SUM(salary) AS sumSalary
FROM [tblEmployees]
GROUP BY GROUPING SETS (
	(country, gender), -- sum of salary by country and gender
	(country),         -- sum of salary by country
	(gender),          -- sum of salary by gender
	()                 -- sum of total salary
);

-- Defining the Ordering: { set([country -> gender]) = 0,0 -> 0,1 -> 1,0 -> 1,1 } : Ordered further in each (0|1, 0|1) set as [gender -> country]
SELECT country, gender, SUM(salary) AS sumSalary
FROM [tblEmployees]
GROUP BY GROUPING SETS (
	(country, gender), -- sum of salary by country and gender
	(country),         -- sum of salary by country
	(gender),          -- sum of salary by gender
	()                 -- sum of total salary
)
ORDER BY Grouping(country), Grouping(gender), gender;



------------------------------------------------------------------------------
---- ROLLUP ----
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--(Q1) Fetch sum of salary by (country) and (grand total) ----
------------------------------------------------------------------------------

---- fetching sum of salary for each country ----
SELECT country, SUM(salary) AS sumSalary
FROM [tblEmployees]
GROUP BY country;

---- fetching grand total sum of salary ----
SELECT NULL, SUM(salary) AS sumSalary
FROM [tblEmployees];

------------------------------------------------------------------------------
---- Method-1: Using Union: fetching sum of salary for each country, along with grand total ----
SELECT country, SUM(salary) AS sumSalary
FROM [tblEmployees]
GROUP BY country
--
UNION ALL
SELECT NULL, SUM(salary) AS sumSalary
FROM [tblEmployees];

------------------------------------------------------------------------------
---- Method-2: Using Grouping Sets() ----
SELECT country, SUM(salary) AS sumSalary
FROM [tblEmployees]
GROUP BY GROUPING SETS (
	(country),         -- sum of salary by country
	()                 -- sum of total salary
);


------------------------------------------------------------------------------
---- Method-3: Using Rollup() ----
SELECT country, SUM(salary) AS sumSalary
FROM [tblEmployees]
GROUP BY ROLLUP (country);
-- OR 
SELECT country, SUM(salary) AS sumSalary
FROM [tblEmployees]
GROUP BY country WITH ROLLUP;


------------------------------------------------------------------------------
--(Q2) Calculate total by country & gender, then total by country, then grand total. ----
------------------------------------------------------------------------------
SELECT country, gender, SUM(salary) AS sumSalary
FROM [tblEmployees]
GROUP BY ROLLUP (country, gender)
ORDER BY gender, country;


------------------------------------------------------------------------------
--(Q3) Group salary by country & gender, by country, by gender, along with grand total salary ----
------------------------------------------------------------------------------
SELECT country, gender,  SUM(salary) AS sumSalary
FROM [tblEmployees]
GROUP BY ROLLUP (country, gender)
--UNION ALL -->> this will print the common result-set {grand-total} twice
UNION
SELECT NULL, gender, SUM(salary) AS sumSalary
FROM [tblEmployees]
GROUP BY ROLLUP (gender)
ORDER BY country, gender;


------------------------------------------------------------------------------
---- CUBE ----
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--(Q1) Group salary by country & gender, by country, by gender, along with grand total salary ----
------------------------------------------------------------------------------

------------------------------------------------------------------------------
---- Method-2: Using Grouping Sets() ----
SELECT country, gender, SUM(salary) AS sumSalary
FROM [tblEmployees]
GROUP BY GROUPING SETS (
	(country, gender), -- sum of salary by country and gender
	(country),         -- sum of salary by country
	(gender),          -- sum of salary by gender
	()                 -- sum of total salary
);

------------------------------------------------------------------------------
---- Method-4: Using Cube() ----
SELECT country, gender, SUM(salary) AS sumSalary
FROM [tblEmployees]
GROUP BY CUBE(country, gender);
-- OR 
SELECT country, gender, SUM(salary) AS sumSalary
FROM [tblEmployees] 
GROUP BY country, gender WITH CUBE;


------------------------------------------------------------------------------
---- Grouping Function ----
------------------------------------------------------------------------------

-- To understand the ordering
SELECT 
    country, 
    gender, 
    SUM(salary) AS sumSalary,
    GROUPING(country) AS grp_country,
    GROUPING(gender) AS grp_gender
FROM tblEmployees
GROUP BY GROUPING SETS (
    (country, gender),
    (country),
    (gender),
    ()
)
ORDER BY grp_country, grp_gender, country, gender;


------------------------------------------------------------------------------
---- USE CASE: Replace NULL ----
SELECT
	country,
	gender, 
	CASE WHEN GROUPING(country) = 1
		THEN 'ALL'
--		add the actual val (=> not aggregated => Grouping(country) = 0) after ensuring it's not storing Null originally
		ELSE ISNULL(country, 'Unkown')
		END AS Country,
	CASE WHEN GROUPING(gender) = 1
		THEN 'ALL'
		ELSE ISNULL(gender, 'Unkown')
		END AS Gender,
	SUM(salary) AS sumSalary
FROM [tblEmployees]
GROUP BY ROLLUP (country, gender);


------------------------------------------------------------------------------
---- Grouping Function ----
------------------------------------------------------------------------------

-- To understand the leveling by GpId
SELECT 
    country, 
    gender, 
    SUM(salary) AS sumSalary,
    GROUPING(country) AS grp_country,
    GROUPING(gender) AS grp_gender,
    CAST(GROUPING(country) AS NVARCHAR(1)) +
    CAST(GROUPING(gender) AS NVARCHAR(1)) AS Casting,
    GROUPING_ID(country, gender) AS GpId
FROM tblEmployees
GROUP BY GROUPING SETS (
    (country, gender),
    (country),
    (gender),
    ()
)
ORDER BY GpId DESC;


------------------------------------------------------------------------------
---- USE CASE: Filter the results: for aggregated (NULL) values only ----
SELECT 
    country, 
    gender, 
    SUM(salary) AS sumSalary,
    GROUPING(country) AS grp_country,
    GROUPING(gender) AS grp_gender,
    GROUPING_ID(country, gender) AS GpId
FROM tblEmployees
GROUP BY GROUPING SETS (
    (country, gender),
    (country),
    (gender),
    ()
)
HAVING GROUPING_ID(country, gender) > 0
ORDER BY GpId DESC;







------------------------------------------------------------------------------
---- WINDOW FUNCITONS ----
------------------------------------------------------------------------------
USE [db1];

DROP TABLE [tblEmplInfo];

CREATE TABLE [tblEmplInfo] 
(
	id INT,
	name NVARCHAR(50),
	salary INT,
	gender NVARCHAR(1),
	dept NVARCHAR(10)
);
INSERT INTO [tblEmplInfo] VALUES
(1, 'sam', 40000, 'm', 'HR'),
(2, 'ron', 60000, 'm', 'HR'),
(3, 'sana', 45000, 'f', 'IT'),
(4, 'sarah', 60000, 'f', 'HR'),
(5, 'mike', 60000, 'm', 'Payroll'),
(6, 'anna', 34000, 'f', 'Payroll'),
(7, 'ben', 45000, 'm', 'IT'),
(8, 'brian', NULL, NULL, 'Other');

SELECT * FROM [tblEmplInfo];

------------------------------------------------------------------------------
---- OVER Clause ----
------------------------------------------------------------------------------

---- fetching grouped record's info ----
SELECT gender, COUNT(Gender), SUM(salary), MAX(salary), Min(salary)
FROM [tblEmplInfo]
GROUP BY gender;

------------------------------------------------------------------------------
---- fetching grouped record's info, along with other columns ----
SELECT id, name, t.gender, tmp.genderCnt, tmp.sum, tmp.max, tmp.min
FROM [tblEmplInfo] t
JOIN
(
	SELECT gender, COUNT(Gender) AS genderCnt, SUM(salary) AS sum, MAX(salary) AS max, Min(salary) AS min
	FROM [tblEmplInfo]
	GROUP BY gender
) AS tmp
ON t.gender = tmp.gender
ORDER BY id;

------------------------------------------------------------------------------
---- Better way: Using OVER() ----
SELECT id, name, gender,
	COUNT(*) OVER(PARTITION BY gender) AS genderCnt,
	SUM(salary) OVER(PARTITION BY gender) AS sum,
	MAX(salary) OVER(PARTITION BY gender) AS max,
	Min(salary) OVER(PARTITION BY gender) AS min
FROM [tblEmplInfo]
ORDER BY id;

------------------------------------------------------------------------------
---- Better way: Using OVER() ----
SELECT id, name, gender,
	COUNT(*) OVER(PARTITION BY gender) AS genderCnt,
	SUM(salary) OVER(PARTITION BY gender) AS sum,
	MAX(salary) OVER(PARTITION BY gender) AS max,
	Min(salary) OVER(PARTITION BY gender) AS min
FROM [tblEmplInfo]
ORDER BY id;

------------------------------------------------------------------------------
---- Over clause  ----
SELECT id, name, gender,
--  Doesn't include count of NULL vals
	COUNT(gender) OVER() AS genderCnt,
	COUNT(dept) OVER() AS deptCnt,
	COUNT(*) OVER() AS tolEmplCnt,
--  Does include count of NULL vals
	COUNT(*) OVER() AS genderCnt2,
	COUNT(*) OVER() AS tolEmplCnt2,
	SUM(salary) OVER() AS sum,
	Min(salary) OVER() AS min
FROM [tblEmplInfo]
ORDER BY id;


------------------------------------------------------------------------------
---- Over clause with Partition on same col ----
-- Ordered by Partition col
SELECT id, name, gender, dept,
--  Holds '0' as genderCnt for Brian
	COUNT(gender) OVER(PARTITION BY gender) AS genderCnt,
--  Holds '1' as genderCnt for Brian
	COUNT(*) OVER(PARTITION BY gender) AS genderCnt
FROM [tblEmplInfo];


------------------------------------------------------------------------------
---- Over clause with Partition on different col ----
SELECT id, name, gender, dept,
	COUNT(gender) OVER(PARTITION BY dept) AS genderCnt,
	COUNT(dept) OVER(PARTITION BY dept) AS deptCnt,
--  Holds '1' as genderCnt for Brian
	COUNT(*) OVER(PARTITION BY dept) AS genderCnt,
	COUNT(*) OVER(PARTITION BY dept) AS deptCnt
FROM [tblEmplInfo];


------------------------------------------------------------------------------
---- Over clause with Partition on multiple col ----
-- Ordered by the last Partition col
SELECT id, name, gender, dept,
	COUNT(gender) OVER(PARTITION BY gender) AS genderCnt,
	COUNT(dept) OVER(PARTITION BY dept) AS deptCnt
FROM [tblEmplInfo];



------------------------------------------------------------------------------
---- ROW NUMBER() ----
------------------------------------------------------------------------------

---- without 'partition by' clause ----
SELECT id, name, gender, salary,
	ROW_NUMBER() OVER (ORDER BY gender) AS rowNo
FROM [tblEmplInfo];

--if ordered by id externally ----
SELECT id, name, gender, salary,
	ROW_NUMBER() OVER (ORDER BY gender) AS rowNo
FROM [tblEmplInfo]
ORDER BY id;

------------------------------------------------------------------------------
---- with 'partition by' clause: 'rowNo' Resets after every gender-group ----
SELECT id, name, gender, salary,
	ROW_NUMBER() OVER (PARTITION BY gender ORDER BY gender) AS rowNo
FROM [tblEmplInfo];

--if ordered by id externally
SELECT id, name, gender, salary,
	ROW_NUMBER() OVER (PARTITION BY gender ORDER BY gender) AS rowNo
FROM [tblEmplInfo]
ORDER BY id;

------------------------------------------------------------------------------
--(Q1) Delete duplicate rows ----
------------------------------------------------------------------------------

DROP TABLE [tblEmplInfo2];

CREATE TABLE [tblEmplInfo2] 
(
	id INT,
	name NVARCHAR(50),
	salary INT,
	gender NVARCHAR(1),
	dept NVARCHAR(10)
);
INSERT INTO [tblEmplInfo2] VALUES
(1, 'sam', 40000, 'm', 'HR'),
(1, 'sam', 40000, 'm', 'HR'),
(1, 'sam', 40000, 'm', 'HR'),
(2, 'sana', 45000, 'f', 'IT'),
(2, 'sana', 45000, 'f', 'IT'),
(3, 'mike', 72000, 'm', 'Payroll'),
(3, 'mike', 72000, 'm', 'Payroll'),
(3, 'mike', 72000, 'm', 'Payroll'),
(3, 'mike', 72000, 'm', 'Payroll'),
(4, 'brian', NULL, NULL, 'Other');

SELECT * FROM [tblEmplInfo2];


---- leaving only 1 distinct row ----
WITH [cteTblDuplicates] AS (
	SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY id) AS rowNo 
	FROM [tblEmplInfo2]
)
DELETE FROM [cteTblDuplicates] WHERE rowNo > 1;

SELECT * FROM [tblEmplInfo2];

---- leaving at max 2 same rows ----
WITH [cteTblDuplicates] AS (
	SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY id) AS rowNo 
	FROM [tblEmplInfo2]
)
DELETE FROM [cteTblDuplicates] WHERE rowNo > 2;

SELECT * FROM [tblEmplInfo2];



------------------------------------------------------------------------------
---- RANK() & DENSE_RANK() ----
------------------------------------------------------------------------------

---- without 'partition by' clause ----
SELECT id, name, gender, salary, dept,
	ROW_NUMBER() OVER (ORDER BY dept) AS rowNo,
	RANK() OVER (ORDER BY dept) AS rank,
	DENSE_RANK() OVER (ORDER BY dept) AS denseRank
FROM [tblEmplInfo];

-- ordered by in descending order ----
SELECT id, name, gender, salary, dept,
	ROW_NUMBER() OVER (ORDER BY dept DESC) AS rowNo,
	RANK() OVER (ORDER BY dept DESC) AS rank,
	DENSE_RANK() OVER (ORDER BY dept DESC) AS denseRank
FROM [tblEmplInfo];

--if ordered by id externally ----
SELECT id, name, gender, salary, dept,
	ROW_NUMBER() OVER (ORDER BY dept) AS rowNo,
	RANK() OVER (ORDER BY dept) AS rank,
	DENSE_RANK() OVER (ORDER BY dept) AS denseRank
FROM [tblEmplInfo]
ORDER BY id;

------------------------------------------------------------------------------
---- with 'partition by' clause: fns Resets after every gender-group ----
SELECT id, name, gender, salary, dept,
	ROW_NUMBER() OVER (PARTITION BY gender ORDER BY dept) AS rowNo,
	RANK() OVER (PARTITION BY gender ORDER BY dept) AS rank,
	DENSE_RANK() OVER (PARTITION BY gender ORDER BY dept) AS denseRank
FROM [tblEmplInfo];


------------------------------------------------------------------------------
--(Q1) Fetch empl with second highest salary ----
------------------------------------------------------------------------------

SELECT * FROM [tblEmplInfo];

SELECT name, dept, salary,
	ROW_NUMBER() OVER (ORDER BY salary DESC) AS rowNo,
	RANK() OVER (ORDER BY salary DESC) AS rank,
	DENSE_RANK() OVER (ORDER BY salary DESC) AS denseRank
FROM [tblEmplInfo];

---- rank() won't work right, since there's no empl getting rank as 2 for salary due to the s_keyips on repeating salary ranks ----
WITH [cteTblDuplicates] AS (
	SELECT name, dept, salary, 
		ROW_NUMBER() OVER (ORDER BY salary DESC) AS rowNo,
		RANK() OVER (ORDER BY salary DESC) AS rank,
		DENSE_RANK() OVER (ORDER BY salary DESC) AS denseRank
	FROM [tblEmplInfo]
)
SELECT TOP 1 name, dept, salary
FROM [cteTblDuplicates] 
WHERE rank = 2;

---- denseRank() works ----
WITH [cteTblDuplicates] AS (
	SELECT name, dept, salary, 
		ROW_NUMBER() OVER (ORDER BY salary DESC) AS rowNo,
		RANK() OVER (ORDER BY salary DESC) AS rank,
		DENSE_RANK() OVER (ORDER BY salary DESC) AS denseRank
	FROM [tblEmplInfo]
)
SELECT name, dept, salary
FROM [cteTblDuplicates] 
WHERE denseRank = 2;

------------------------------------------------------------------------------
--(Q2) Fetch all male empls with highest salary ----
------------------------------------------------------------------------------
SELECT name, gender, salary, 
	ROW_NUMBER() OVER (PARTITION BY gender ORDER BY salary DESC) AS rowNo,
	RANK() OVER (PARTITION BY gender ORDER BY salary DESC) AS rank,
	DENSE_RANK() OVER (PARTITION BY gender ORDER BY salary DESC) AS denseRank
FROM [tblEmplInfo];

----  ----
WITH [cteTblDuplicates] AS (
	SELECT name, gender, salary, 
		ROW_NUMBER() OVER (PARTITION BY gender ORDER BY salary DESC) AS rowNo,
		RANK() OVER (PARTITION BY gender ORDER BY salary DESC) AS rank,
		DENSE_RANK() OVER (PARTITION BY gender ORDER BY salary DESC) AS denseRank
	FROM [tblEmplInfo]
)
SELECT name, gender, salary
FROM [cteTblDuplicates] 
WHERE denseRank = 1 AND gender = 'm';

------------------------------------------------------------------------------
--(Q3) Fetch both male & female empls with highest salary ----
------------------------------------------------------------------------------
SELECT name, gender, salary, 
	ROW_NUMBER() OVER (PARTITION BY gender ORDER BY salary DESC) AS rowNo,
	RANK() OVER (PARTITION BY gender ORDER BY salary DESC) AS rank,
	DENSE_RANK() OVER (PARTITION BY gender ORDER BY salary DESC) AS denseRank
FROM [tblEmplInfo];

--------
WITH [cteTblDuplicates] AS (
	SELECT name, gender, salary, 
		ROW_NUMBER() OVER (PARTITION BY gender ORDER BY salary DESC) AS rowNo,
		RANK() OVER (PARTITION BY gender ORDER BY salary DESC) AS rank,
		DENSE_RANK() OVER (PARTITION BY gender ORDER BY salary DESC) AS denseRank
	FROM [tblEmplInfo]
)
SELECT name, gender, salary
FROM [cteTblDuplicates] 
WHERE denseRank = 1 AND gender IN ('m', 'f')
ORDER BY gender, name;


------------------------------------------------------------------------------
--(Q4) Fetch any 1 (only) of both male & female empls with highest salary ----
------------------------------------------------------------------------------
WITH [cteTblDuplicates] AS (
		SELECT name, gender, salary, 
			ROW_NUMBER() OVER (PARTITION BY gender ORDER BY salary DESC) AS rowNo,
			RANK() OVER (PARTITION BY gender ORDER BY salary DESC) AS rank,
			DENSE_RANK() OVER (PARTITION BY gender ORDER BY salary DESC) AS denseRank
		FROM [tblEmplInfo]
	)
SELECT name, gender, salary, rowNo
FROM [cteTblDuplicates] 
WHERE denseRank = 1 AND gender IN ('m', 'f') AND rowNo = 1
ORDER BY gender, name;


------------------------------------------------------------------------------
---- RUNNING TOTAL ----
------------------------------------------------------------------------------
SELECT * FROM [tblEmplInfo];

SELECT name, salary, gender,
	COUNT(gender) OVER() AS genderCnt,
	COUNT(gender) OVER(ORDER BY id) AS runningGenderCnt,
	COUNT(gender) OVER(PARTITION BY gender ORDER BY id) AS runningPartitionedGenderCnt,
	COUNT(*) OVER(PARTITION BY gender ORDER BY id) AS runningPartitionedGenderCntForNull,
--	
	SUM(id) OVER() AS idTotal,
	SUM(id) OVER(ORDER BY id) AS runningId,
	SUM(id) OVER(PARTITION BY gender ORDER BY id) AS runningPartitionedIdTotal,
--	
	SUM(salary) OVER() AS salaryTotal,
	SUM(salary) OVER(ORDER BY id) AS runningSalary,
	SUM(salary) OVER(PARTITION BY gender ORDER BY id) AS runningPartitionedSalaryTotal
FROM [tblEmplInfo]
ORDER BY id;


------------------------------------------------------------------------------
---- NTILE FUNCTION ----
------------------------------------------------------------------------------
SELECT * FROM [tblEmplInfo];

INSERT INTO [tblEmplInfo]
SELECT * FROM [tblEmplInfo];

SELECT * FROM [tblEmplInfo];

---- 'noOfGroups' exactly divisible by 'noOfRows' ----
SELECT name, salary, gender,
	NTILE(2) OVER (ORDER BY id) AS Ntile
FROM [tblEmplInfo];

---- 'noOfGroups' not exactly divisible by 'noOfRows' ----
SELECT name, salary, gender,
	NTILE(3) OVER (ORDER BY id) AS Ntile
FROM [tblEmplInfo];

---- noOfGroups > noOfRows ----
SELECT name, salary, gender,
	NTILE(20) OVER (ORDER BY id) AS Ntile
FROM [tblEmplInfo];


---- Reverting the table back to original form  ----
WITH cte AS (
	SELECT *,
		ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS rowNum
	FROM [tblEmplInfo]
)
DELETE FROM [cte]
WHERE rowNum > 1;

SELECT * FROM [tblEmplInfo];


------------------------------------------------------------------------------
---- LEAD & LAG FUNCTION ----
------------------------------------------------------------------------------

SELECT name, gender,salary,
	LEAD(salary) OVER (ORDER BY salary) AS lead,
	LAG(salary) OVER (ORDER BY salary) AS lag,
--	
	LEAD(salary, 2, -1) OVER (ORDER BY salary) AS leadBy2,
	LAG(salary, 2, -1) OVER (ORDER BY salary) AS lagBy2,
--	
	LEAD(salary) OVER (PARTITION BY gender ORDER BY salary) AS prtLead,
	LAG(salary) OVER (PARTITION BY gender ORDER BY salary) AS prtLag,
--	
	LEAD(salary,2, -1) OVER (PARTITION BY gender ORDER BY salary) AS prtLeadBy2,
	LAG(salary,2, -1) OVER (PARTITION BY gender ORDER BY salary) AS prtLagBy2
FROM [tblEmplInfo];


------------------------------------------------------------------------------
---- FIRST_VALUE FUNCTION ----
------------------------------------------------------------------------------

SELECT name, gender,salary,
	FIRST_VALUE(name) OVER (ORDER BY gender) AS firstVal,
	FIRST_VALUE(name) OVER (PARTITION BY gender ORDER BY salary) AS firstVal,
	FIRST_VALUE(name) OVER (PARTITION BY gender ORDER BY salary) AS firstVal
FROM [tblEmplInfo];

----  ----
SELECT name, gender,salary,
	FIRST_VALUE(name) OVER (ORDER BY gender) AS firstVal,
	FIRST_VALUE(name) OVER (ORDER BY gender DESC) AS firstVal,
	FIRST_VALUE(name) OVER (PARTITION BY gender ORDER BY salary) AS firstVal,
	FIRST_VALUE(name) OVER (PARTITION BY gender ORDER BY salary DESC) AS firstVal,
	FIRST_VALUE(name) OVER (PARTITION BY gender ORDER BY name) AS firstVal 
FROM [tblEmplInfo]
WHERE gender IN ('m', 'f');


------------------------------------------------------------------------------
---- ROWS | RANGE CLAUSE ----
------------------------------------------------------------------------------

SELECT id, name, gender,salary,
	---- default: consider scope from 1st to current row ----
	COUNT(id) OVER (ORDER BY id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cntId1,
	---- consider scope from 1st to last row ----
	COUNT(id) OVER (ORDER BY id ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS cntId2,
	---- consider scope from 1st to just next 1 row ----
	COUNT(id) OVER (ORDER BY id ROWS BETWEEN UNBOUNDED PRECEDING AND 1 FOLLOWING) AS cntId3,
	---- consider scope from 2 rows before to 2 rows after row ----
	COUNT(id) OVER (ORDER BY id ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) AS cntId4
FROM [tblEmplInfo];

----  ----
SELECT id, name, gender,
	ROW_NUMBER() OVER (PARTITION BY gender ORDER BY gender) AS rowNum,
	SUM(id) OVER (PARTITION BY gender) AS sumId0,
	SUM(id) OVER (PARTITION BY gender ORDER BY gender RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS sumId1,
	SUM(id) OVER (PARTITION BY gender ORDER BY gender RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS sumId2,
	SUM(id) OVER (PARTITION BY gender ORDER BY gender ROWS BETWEEN UNBOUNDED PRECEDING AND 1 FOLLOWING) AS sumId3,
	SUM(id) OVER (PARTITION BY gender ORDER BY gender ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) AS sumId4
FROM [tblEmplInfo];

----  ----
DROP TABLE [tblTmp];

CREATE TABLE [tblTmp] (id INT);
INSERT INTO [tblTmp] VALUES (1), (2), (3), (3), (5), (5);
SELECT * FROM [tblTmp];

SELECT id,
	ROW_NUMBER() OVER (ORDER BY id) AS rowNum,
	SUM(id) OVER (ORDER BY id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS sumByRow,
	SUM(id) OVER (ORDER BY id RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS sumByRange
FROM [tblTmp];


------------------------------------------------------------------------------
---- LAST_VALUE FUNCTION ----
---- Ensure to change the ROWS BETWEEN Clause to UNBOUNDED at both ends ----
------------------------------------------------------------------------------

----❌ Not correct way ❌----
SELECT name, gender,salary,
	LAST_VALUE(name) OVER (ORDER BY gender) AS lastVal,
	LAST_VALUE(name) OVER (PARTITION BY gender ORDER BY salary) AS lastVal,
	LAST_VALUE(name) OVER (PARTITION BY gender ORDER BY salary) AS lastVal
FROM [tblEmplInfo];

----✅ Correct way ✅----
SELECT id, name, gender,salary,
	LAST_VALUE(name) OVER (ORDER BY gender, name ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS lastVal,
	LAST_VALUE(name) OVER (ORDER BY gender, name  DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS lastVal,
	LAST_VALUE(name) OVER (PARTITION BY gender ORDER BY salary, name   ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS lastVal,
	LAST_VALUE(name) OVER (PARTITION BY gender ORDER BY salary, name   DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS lastVal,
	LAST_VALUE(name) OVER (PARTITION BY gender ORDER BY name  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS lastVal 
FROM [tblEmplInfo]
WHERE gender IN ('m', 'f');


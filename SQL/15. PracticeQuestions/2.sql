

------------------------------------------------------------------------------
--(Q1) 
------------------------------------------------------------------------------
IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_NAME = 'A')
	DROP TABLE A;
IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_NAME = 'B')
	DROP TABLE B;

CREATE TABLE A (id INT, name NVARCHAR(1), deptId INT);
CREATE TABLE B (did INT, dname NVARCHAR(1));

INSERT INTO A VALUES
(1, 'a', 1),
(2, 'b', 1),
(3, 'c', 2),
(4, 'd', NULL);
INSERT INTO B VALUES
(1, 'a'),
(2, 'b'),
(3, 'c'),
(NULL, 'd');

SELECT * FROM A;
SELECT * FROM B;

----  ----
SELECT a.name, b.dname
FROM A AS a
JOIN B AS b
ON a.deptId = b.did;


----  ----
SELECT COUNT(a.name), COUNT(b.dname), COUNT(*)
FROM A AS a
JOIN B AS b
ON a.deptId = b.did;


------------------------------------------------------------------------------
--(Q2) Create table with outputs of rows - {a-b, a-c, a-d, b-c, b-d, c-d}
------------------------------------------------------------------------------
IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_NAME = 'A')
	DROP TABLE A;

CREATE TABLE A (id INT, name NVARCHAR(1));

INSERT INTO A VALUES
(1, 'a'),
(2, 'b'),
(3, 'c'),
(4, 'd');

SELECT * FROM A;

----  ----
SELECT a.name + ' - ' + b.name AS Matches
FROM A AS a
JOIN A AS b
ON a.id < b.id
ORDER BY a.id;


------------------------------------------------------------------------------
--(Q3) 
------------------------------------------------------------------------------
IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_NAME = 'A')
	DROP TABLE A;

CREATE TABLE A (id INT, name NVARCHAR(1), deptId INT);

INSERT INTO A VALUES
(1, 'a', 1),
(1, 'b', 2),
(3, 'c', 3),
(4, 'd', NULL);

SELECT * FROM A;

---- Cross Join with WHERE clause ==> Inner Join ----
SELECT a.name, b.name, a.id, b.id, a.deptId
FROM A AS a
CROSS JOIN A AS b
WHERE a.id = b.id;

----  ----
SELECT COUNT(a.name), COUNT(b.name), COUNT(*), COUNT(a.id), COUNT(b.id), COUNT(a.deptId)
FROM A AS a 
CROSS JOIN A AS b
WHERE a.id = b.id;


------------------------------------------------------------------------------
--(Q4) 
------------------------------------------------------------------------------
IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_NAME = 'A')
	DROP TABLE A;

CREATE TABLE A (id INT, name NVARCHAR(1), deptId INT);

INSERT INTO A VALUES
(1, 'a', 1),
(2, 'b', 2),
(3, 'c', 3),
(NULL, 'd', NULL);

SELECT * FROM A;

---- Cross Join with WHERE clause ==> Inner Join ----
SELECT a.id, b.id, a.name, b.name, a.deptId
FROM A AS a
left JOIN A AS b
ON a.id <> b.id;

----  ----
SELECT COUNT(*), COUNT(a.id), COUNT(b.id), COUNT(a.name), COUNT(b.name), COUNT(a.deptId)
FROM A AS a 
JOIN A AS b
ON a.id <> b.id;

----  --------  --------  --------  ----
SELECT a.id, b.id, a.name, b.name, a.deptId
FROM A AS a 
CROSS JOIN A AS b
WHERE a.id IS NULL;

----  ----
SELECT COUNT(*), COUNT(a.id), COUNT(b.id), COUNT(a.name), COUNT(b.name), COUNT(a.deptId)
FROM A AS a 
CROSS JOIN A AS b
WHERE a.id IS NULL;


----  --------  --------  --------  ----
SELECT a.id, b.id, a.name, b.name, a.deptId
FROM A AS a 
CROSS JOIN A AS b;

----  --------  --------  --------  ----
SELECT a.id, b.id, c.id, a.name, b.name, c.name, a.deptId
FROM A AS a 
CROSS JOIN A AS b
CROSS JOIN A AS c;

----  ----
SELECT COUNT(*), COUNT(a.id), COUNT(b.id), COUNT(c.id), COUNT(a.name), COUNT(b.name), COUNT(c.name), COUNT(a.deptId)
FROM A AS a 
CROSS JOIN A AS b
CROSS JOIN A AS c;


----  --------  --------  --------  ----
SELECT * FROM A AS a
INTERSECT
SELECT * FROM A AS b

----  ----
SELECT * FROM A AS a
UNION
SELECT * FROM A AS b

----  ----
SELECT * FROM A AS a
UNION ALL
SELECT * FROM A AS b

----  ----
SELECT * FROM A AS a
EXCEPT
SELECT * FROM A AS b

----  ----
SELECT COUNT(*), COUNT(a.id), COUNT(a.name)
FROM (
	SELECT * FROM A AS a
	INTERSECT
	SELECT * FROM A AS b
) AS a;


------------------------------------------------------------------------------
--(Q5) 
------------------------------------------------------------------------------
IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_NAME = 'A')
	DROP TABLE A;
IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_NAME = 'B')
	DROP TABLE B;

CREATE TABLE A (id INT, name NVARCHAR(1));
CREATE TABLE B (id INT);

INSERT INTO A VALUES
(1, 'a'),
(1, 'b'),
(2, 'c'),
(NULL, 'd');

INSERT INTO B 
VALUES (2), (NULL);

SELECT * FROM A;
SELECT * FROM B;

----  --------  --------  --------  ----
SELECT a.id, a.name
FROM A AS a
WHERE a.id IN (
	SELECT id FROM B
	);

----  ----
SELECT a.id, a.name
FROM A AS a
WHERE a.id NOT IN (
	SELECT id FROM B
	WHERE id IS NOT NULL
	);

----  ----
SELECT a.id, a.name
FROM A AS a
WHERE a.id NOT IN (
	SELECT id FROM B
	);

----  --------  --------  --------  ----
SELECT COUNT(*), COUNT(a.id), COUNT(a.name)
FROM A AS a
WHERE a.id NOT IN (
	SELECT id FROM B
	WHERE id IS NOT NULL
	);

----  ----
SELECT a.id, a.name
FROM A AS a
WHERE a.id NOT IN (
	SELECT id FROM B
	WHERE id IS NOT NULL
	);

----  ----
SELECT COUNT(a.*), COUNT(a.id), COUNT(a.name)
FROM A AS a
WHERE a.id NOT IN (
	SELECT id FROM B
	WHERE id IS NOT NULL
	);

----  --------  --------  --------  ----
SELECT COUNT(*), COUNT(a.id)
FROM (
	SELECT id FROM A AS x
	EXCEPT
	SELECT id FROM B
	WHERE id IS NOT NULL
	) AS a;

SELECT a.id
FROM (
	SELECT id FROM A AS x
	EXCEPT
	SELECT id FROM B
	WHERE id IS NOT NULL
	) AS a;


------------------------------------------------------------------------------
--(Q6) for same memberNbr and AcctNbr, fetch only the latest entry in the results
------------------------------------------------------------------------------
IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_NAME = 'A')
	DROP TABLE A;

CREATE TABLE A (memberNbr INT, acctNbr INT, entryDt DATE);

INSERT INTO A VALUES
(1, 1, '2024-07-29'),
(1, 1, '2024-07-30'),
(2, 1, '2024-07-29'),
(2, 1, '2024-07-31'),
(2, 2, '2024-07-28'),
(3, 3, '2024-07-25');

SELECT * FROM A;


---- USING GROUP BY ----
SELECT memberNbr, acctNbr, MAX(entryDt)
FROM A
GROUP BY memberNbr, acctNbr


---- USING ROWNUMBER & SUBQUERY/ DERIVED TABLE ----
SELECT memberNbr, acctNbr, entryDt
FROM (
	SELECT *, 
		ROW_NUMBER() OVER (
			PARTITION BY memberNbr, acctNbr 
			ORDER BY entryDt DESC) AS rw
	FROM A
) AS a
WHERE rw = 1;



---- USING ROWNUMBER & CTE ----
WITH cte
AS (
	SELECT *, 
		ROW_NUMBER() OVER (
			PARTITION BY memberNbr, acctNbr 
			ORDER BY entryDt DESC) AS rw
	FROM A
) SELECT  memberNbr, acctNbr, entryDt
FROM cte
WHERE rw = 1;


------------------------------------------------------------------------------
----  --------  ---- FOR XML PATH ----  --------  ----
------------------------------------------------------------------------------
IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_NAME = 'A')
	DROP TABLE A;

CREATE TABLE A (memberNbr INT, acctNbr INT, entryDt DATE);


INSERT INTO A VALUES
(1, 1, '2024-07-29'),
(2, NULL, '2024-07-28'),
(3, 3, '2024-07-25');

SELECT * FROM A;


---- XML format output + with NULL values ----
SELECT memberNbr,
	acctNbr,
	entryDt
FROM A
FOR XML PATH;

---- XML Attributes ----
SELECT memberNbr AS '@memberNbr',
	acctNbr,
	entryDt
FROM A
FOR XML PATH;

---- Column Alias/ Custom Children ----
SELECT memberNbr,
	acctNbr AS 'new/acctNr',
	entryDt AS 'new/entryDt'
FROM A
FOR XML PATH;

---- Custom Row Element Name ----
SELECT memberNbr,
	acctNbr,
	entryDt
FROM A
FOR XML PATH('newRow');


---- No Row Element ----
SELECT memberNbr,
	acctNbr,
	entryDt
FROM A
FOR XML PATH('');


---- Custom Root ----
SELECT memberNbr,
	acctNbr,
	entryDt
FROM A
FOR XML PATH('');


---- String Concatenation  ----
SELECT CAST(memberNbr as NVARCHAR(20)) + ' - ' + CAST(acctNbr as NVARCHAR(20)) AS tmp
FROM A
FOR XML PATH;


----  ----
SELECT CAST(memberNbr as NVARCHAR(20)) + ' - ' + CAST(acctNbr as NVARCHAR(20)) AS tmp
FROM A
FOR XML PATH('');

----  ----
SELECT CAST(memberNbr as NVARCHAR(20)) + ' - ' + CAST(acctNbr as NVARCHAR(20))
FROM A
FOR XML PATH('');





------------------------------------------------------------------------------
--(Q6.B) Get comma seperated values for the entryDt, instead of the latest
------------------------------------------------------------------------------
SELECT STUFF(
	(
		SELECT ',' + CAST(memberNbr as NVARCHAR(20))
		FROM A
		FOR XML PATH('')
	), 1, 1, '') AS joinedCol
FROM A;





















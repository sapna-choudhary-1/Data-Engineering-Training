------------------------------------------------------------------------------
---- PRACTISE INTERVIEW QUESTIONS ----
------------------------------------------------------------------------------

USE db1;

------------------------------------------------------------------------------
--(Q1) 
------------------------------------------------------------------------------
SELECT * FROM (SELECT 100) AS t;
SELECT * FROM (SELECT 100) AS tmp;
SELECT * FROM (SELECT 100 AS sq) AS t;
SELECT * FROM (SELECT 100 AS sq) AS tmp;


------------------------------------------------------------------------------
--(Q2) 
------------------------------------------------------------------------------
SELECT @;
SELECT '@';

SELECT COUNT(1), COUNT(*);

SELECT (SELECT 'A' AS efg) AS abc;

SELECT 'A'+123 AS abc;

----  ----
SELECT SUM(5*10) AS abc;

SELECT SUM(5*10+NULL) AS abc;

SELECT SUM(NULL) AS abc;

SELECT SUM('250') AS abc;

DECLARE @A INT
SET @A=NULL
SELECT SUM(@A) AS abc;

----  ----
SELECT NULL=NULL AS abc;
SELECT NULL IS NULL;
SELECT 1=1;


SELECT NULL AS Value1, NULL AS Value2, NULL = NULL AS IsEqual;

----  ----
SELECT MAX(100, 200, 5, 6) AS abc;

SELECT MAX(col) AS abc
FROM (
	SELECT id AS col
	FROM [TableA]
) AS t

----  ----
SELECT CONCAT('A', 100);
SELECT CONCAT(100, 'A', 200);
SELECT CONCAT('A', NULL);
SELECT CONCAT(NULL, NULL);
SELECT CONCAT(NULL);

----  ----
SELECT 100+100;
SELECT 100+'100';
SELECT 'A'+'100';
SELECT 'A'+100;



------------------------------------------------------------------------------
--(Q3) 
------------------------------------------------------------------------------
SELECT 100 AS a
	UNION ALL
	SELECT NULL AS a
	UNION ALL
	SELECT 2 AS a
	
----  ----
SELECT COUNT(a)
FROM (SELECT 100 AS a
	UNION ALL
	SELECT NULL AS a
	UNION ALL
	SELECT 2 AS a) AS abc

------------------------------------------------------------------------------
--(Q4) 
------------------------------------------------------------------------------
DECLARE @V NUMERIC(14, 2)
SET @V=10/3
SELECT @V

----  ----
DECLARE @V NUMERIC(14, 2)
SET @V=10/CAST(3 AS NUMERIC)
SELECT @V

----  ----
DECLARE @V NUMERIC(14, 3)
SET @V=10.0/3
SELECT @V

----  ----
DECLARE @V INT
SET @V=100/3.0
SELECT @V


------------------------------------------------------------------------------
--(Q5) 
------------------------------------------------------------------------------
SELECT CASE 
		WHEN 1=1 THEN 'A'
		WHEN 2=2 THEN 'B'
		ELSE 'D'
	END AS name;

----  ----
SELECT CASE 
		WHEN NULL=NULL THEN 'TRUE'
		ELSE 'FALSE'
	END;


------------------------------------------------------------------------------
--(Q6) 
------------------------------------------------------------------------------
SELECT * FROM 'TableA';
SELECT * FROM "TableA";

------------------------------------------------------------------------------
--(Q7) 
------------------------------------------------------------------------------
DROP TABLE A;
DROP TABLE B;

CREATE TABLE A (id INT);
CREATE TABLE B (id INT);

INSERT INTO A VALUES (NULL), (1);
INSERT INTO B VALUES (NULL), (2);

SELECT * FROM A;
SELECT * FROM B;

----  ----
SELECT A.id, B.id FROM A
JOIN B ON A.id = B.id;

----  ----
SELECT A.id, B.id FROM A
LEFT JOIN B ON A.id = B.id;

----  ----
SELECT A.id, B.id FROM A
JOIN B ON A.id = A.id;

----  ----
SELECT A.id, B.id FROM A
JOIN B ON B.id = B.id;

----  ----
SELECT A.id, B.id FROM A
CROSS JOIN B;

----  ----
SELECT COUNT(A.id), COUNT(B.id), COUNT(*)
FROM A
JOIN B
ON A.id = B.id;

----  ----
SELECT COUNT(A.id), COUNT(B.id), COUNT(*)
FROM A
LEFT JOIN B
ON A.id = B.id;

----  ----
SELECT COUNT(A.id), COUNT(B.id), COUNT(*)
FROM A
JOIN B
ON A.id = A.id;

----  ----
SELECT COUNT(A.id), COUNT(B.id), COUNT(*)
FROM A
JOIN B
ON B.id = B.id;

----  ----
SELECT COUNT(A.id), COUNT(B.id), COUNT(*)
FROM A
CROSS JOIN B;


------------------------------------------------------------------------------
--(Q8) 
------------------------------------------------------------------------------
DROP TABLE A;

CREATE TABLE A (id INT, name NVARCHAR(1), deptId INT);

INSERT INTO A VALUES
(1, 'a', 1),
(2, 'b', 2),
(3, 'c', 3),
(NULL, 'd', NULL);

SELECT * FROM A;

----  ----
SELECT a.id, b.id 
FROM A AS a
JOIN A AS b
ON a.id = b.id;


----  ----
SELECT COUNT(a.id), COUNT(b.id)
FROM A AS a
JOIN A AS b
ON a.id = b.id;

----  ----
SELECT a.id, b.id 
FROM A AS a
LEFT JOIN A AS b
ON a.id = b.id;


----  ----
SELECT COUNT(a.id), COUNT(b.id), COUNT(*)
FROM A AS a
LEFT JOIN A AS b
ON a.id = b.id;

----  ----
SELECT a.name, b.name AS b_name, b.id AS id, b.deptId AS deptId
FROM A AS a
RIGHT JOIN A AS b
ON a.id = b.id;

----  ----
SELECT COUNT(a.name), COUNT(b.name), COUNT(*)
FROM A AS a
RIGHT JOIN A AS b
ON a.id = b.id;

----  ----
SELECT a.id, b.id 
FROM A AS a
CROSS JOIN A AS b;

----  ----
SELECT COUNT(a.id), COUNT(b.id), COUNT(*)
FROM A AS a
CROSS JOIN A AS b;

---- Cross Join with Where clause ==> Inner Join ----
SELECT a.id, b.id, a.deptId
FROM A AS a
CROSS JOIN A AS b
WHERE a.id = b.id;

----  ----
SELECT COUNT(a.id), COUNT(b.id), COUNT(*), COUNT(a.deptId)
FROM A AS a
CROSS JOIN A AS b
WHERE a.id = b.id;
















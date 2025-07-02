------------------------------------------------------------------------------
--(Q1) Return a comma-separated list of email IDs for each department. 
------------------------------------------------------------------------------
CREATE TABLE Comma_Separated_Email (
EMPID int,
Gender varchar,
EmailID varchar(30),
DeptID int)
INSERT INTO Comma_Separated_Email VALUES (1001,'M','YYYYY@gmaix.com',104)
INSERT INTO Comma_Separated_Email VALUES (1002,'M','ZZZ@gmaix.com',103)
INSERT INTO Comma_Separated_Email VALUES (1003,'F','AAAAA@gmaix.com',102)
INSERT INTO Comma_Separated_Email VALUES (1004,'F','PP@gmaix.com',104)
INSERT INTO Comma_Separated_Email VALUES (1005,'M','CCCC@yahu.com',101)
INSERT INTO Comma_Separated_Email VALUES (1006,'M','DDDDD@yahu.com',100)
INSERT INTO Comma_Separated_Email VALUES (1007,'F','E@yahu.com',102)
INSERT INTO Comma_Separated_Email VALUES (1008,'M','M@yahu.com',102)
INSERT INTO Comma_Separated_Email VALUES (1009,'F','SS@yahu.com',100)

SELECT * FROM Comma_Separated_Email

SELECT 104 AS deptId, 'YYYYY@gmaix.com, PP@gmaix.com' AS EmailId

SELECT DeptId, 
 (SELECT STUFF(
	(
		SELECT ',' + EmailID
		FROM Comma_Separated_Email
		FOR XML PATH('')
	), 1, 1, '') AS EmailId
  )
FROM Comma_Separated_Email
GROUP BY  DeptId


-- Method-1: Using STUFF and FOR XML PATH
SELECT
     DISTINCT DeptID,
     STUFF((SELECT ' '+EmailId FROM Comma_Separated_Email I WHERE I.DeptID=o.DeptID FOR XML PATH('')),1,1,'') AS Email_List
FROM Comma_Separated_Email O

-- Method-2: Using STRING_AGG
SELECT
     DeptID, 
     STRING_AGG(EmailID , ',') AS EmailID
FROM Comma_Separated_Email O
GROUP BY DeptId


------------------------------------------------------------------------------
--(Q1) Get the minimum and maximum sequence number for each group in a table.
------------------------------------------------------------------------------
CREATE TABLE Min_Max_Sequence(
[Group]  varchar(20),
[Sequence]  int )
INSERT INTO Min_Max_Sequence VALUES('A',1)
INSERT INTO Min_Max_Sequence VALUES('A',2)
INSERT INTO Min_Max_Sequence VALUES('A',3)
INSERT INTO Min_Max_Sequence VALUES('A',5)
INSERT INTO Min_Max_Sequence VALUES('A',6)
INSERT INTO Min_Max_Sequence VALUES('A',8)
INSERT INTO Min_Max_Sequence VALUES('A',9)
INSERT INTO Min_Max_Sequence VALUES('B',11)
INSERT INTO Min_Max_Sequence VALUES('C',1)
INSERT INTO Min_Max_Sequence VALUES('C',2)
INSERT INTO Min_Max_Sequence VALUES('C',3)
SELECT * FROM Min_Max_Sequence;

WITH cte 
AS (
	SELECT 
		[Group], 
		[Sequence], 
		ROW_NUMBER() OVER (PARTITION BY [Group] ORDER BY [Sequence]) AS [breaks],
		[Sequence] - ROW_NUMBER() OVER (PARTITION BY [Group] ORDER BY [Sequence]) AS [grps]
	FROM Min_Max_Sequence
)
SELECT 
	[Group], 
	MIN([Sequence]), 
	MAX([Sequence])
FROM cte
GROUP BY 
	[Group], 
	[grps]
ORDER BY [Group]







	
USE company;
SELECT * FROM [tblMail];

------------------------------------------------------------------------------
---- AFTER/ FOR TRIGGERS ----
------------------------------------------------------------------------------

CREATE TABLE [tblAudit] (
id INT IDENTITY(1,1),
audit NVARCHAR(MAX)
);

SELECT * FROM [tblAudit];

DELETE FROM [tblMail] WHERE id>8;
DROP TRIGGER [tr_tblMail_ForInsert];
DROP TABLE [tblAudit];

------------------------------------------------------------------------------
---- INSERT TRIGGER ----
CREATE TRIGGER [tr_tblMail_ForInsert]
ON tblMail
FOR Insert
AS
BEGIN
	SELECT * FROM inserted
END;

INSERT INTO [tblMail]
VALUES (9, 'Lucy', 'Larsen', 'lucy@ddd.com', GETDATE()); -- See result of 'inserted' table

SELECT * FROM [tblMail];
SELECT * FROM [tblAudit];


----- Add 1 row -----
ALTER TRIGGER [tr_tblMail_ForInsert]
ON [tblMail]
FOR INSERT
AS
BEGIN
	DECLARE @id INT, @fname NVARCHAR(20), @lname NVARCHAR(20);
--	SELECT @id = id FROM inserted  -- ❌ Will give errro 'Must declare the scalar variable "@id".'
	SELECT TOP 1 @id = id, @fname = f_name, @lname = l_name FROM inserted;
	
	INSERT INTO [tblAudit]
	VALUES ('New employee with Id = ' + CAST(@id AS VARCHAR(5)) + ' and Name = ' + @fname + ' ' + @lname + ' is added at ' + CAST(GETDATE() AS NVARCHAR(20)));
END;

-- WHY WORKED  ONLY ONCE??!! ---

INSERT INTO [tblMail]
VALUES (10, 'Liam', 'Larsen', 'liam@ddd.com', GETDATE());

SELECT * FROM [tblMail];
SELECT * FROM [tblAudit];

----- Add multiple rows -----
ALTER TRIGGER [tr_tblMail_ForInsert]
ON tblMail
FOR INSERT
AS
BEGIN	
	INSERT INTO [tblAudit] (audit)
	SELECT 'New employee with Id = ' + CAST(id AS VARCHAR(5)) + ' and Name = ' + f_name + ' ' + l_name + ' is added at ' + CAST(GETDATE() AS NVARCHAR(20))
	FROM inserted
END;

INSERT INTO [tblMail] VALUES
(11, 'Marlin', 'Larsen', 'marlin@ddd.com', GETDATE()),
(12, 'Megan', 'Larsen', 'megan@ddd.com', GETDATE()),
(13, 'Robin', 'Larsen', 'robin@ddd.com', GETDATE()),
(14, 'Ray', 'Larsen', 'ray@ddd.com', GETDATE()),
(15, 'Bruno', 'Larsen', 'bruno@ddd.com', GETDATE());

-- !!! Result stored in the tblAudit is in non-sorted manner, because order is not maintained !!! --

SELECT * FROM [tblMail];
SELECT * FROM [tblAudit];

----- Add multiple rows: while ensuring rows are inserted in right order -----
DELETE FROM [tblAudit] WHERE id>1;
DELETE FROM [tblMail] WHERE id>10;
DBCC CHECKIDENT([tblAudit], RESEED, 1);

ALTER TRIGGER [tr_tblMail_ForInsert]
ON tblMail
FOR INSERT
AS
BEGIN	
	INSERT INTO [tblAudit] (audit)
	SELECT 'New employee with Id = ' + CAST(id AS VARCHAR(5)) + ' and Name = ' + f_name + ' ' + l_name + ' is added at ' + CAST(GETDATE() AS NVARCHAR(20))
	FROM inserted
	ORDER BY id;
END;

INSERT INTO [tblMail] VALUES
(11, 'Marlin', 'Larsen', 'marlin@ddd.com', GETDATE()),
(12, 'Megan', 'Larsen', 'megann@ddd.com', GETDATE()),
(13, 'Robin', 'Larsen', 'robin@ddd.com', GETDATE()),
(14, 'Ray', 'Larsen', 'ray@ddd.com', GETDATE()),
(15, 'Bruno', 'Larsen', 'bruno@ddd.com', GETDATE());

SELECT * FROM [tblMail];
SELECT * FROM [tblAudit];


------------------------------------------------------------------------------
---- DELETE TRIGGER ----

CREATE TRIGGER [tr_tblMail_ForDelete]
ON [tblMail]
FOR DELETE
AS
BEGIN
	SELECT * FROM [DELETED];
END;

DELETE FROM [tblMail] WHERE id = 15; 

SELECT * FROM [tblMail];
SELECT * FROM [tblAudit];

----- Remove 1 row -----
ALTER TRIGGER [tr_tblMail_ForDelete]
ON [tblMail]
FOR DELETE
AS
BEGIN
	DECLARE @id INT, @fname NVARCHAR(20), @lname NVARCHAR(20); 
	SELECT @id = id, @fname = f_name, @lname = l_name FROM DELETED
	INSERT INTO [tblAudit] (audit)
	VALUES ('An existing employee with Id = ' + CAST(@id AS NVARCHAR(5)) + ' and Name = ' + @fname + ' ' + @lname + ' is deleted at ' + CAST(GETDATE() AS NVARCHAR(20)) );
END;

DELETE FROM [tblMail] WHERE id = 14; 


SELECT * FROM [tblMail];
SELECT * FROM [tblAudit];

----- Remove multiple rows -----

INSERT INTO [tblMail] VALUES
(11, 'Marlin', 'Larsen', 'marlin@ddd.com', GETDATE()),
(12, 'Megan', 'Larsen', 'megann@ddd.com', GETDATE()),
(13, 'Robin', 'Larsen', 'robin@ddd.com', GETDATE()),
(14, 'Ray', 'Larsen', 'ray@ddd.com', GETDATE()),
(15, 'Bruno', 'Larsen', 'bruno@ddd.com', GETDATE());

SELECT * FROM [tblMail];
SELECT * FROM [tblAudit];

ALTER TRIGGER [tr_tblMail_ForDelete]
ON [tblMail]
FOR DELETE
AS
BEGIN
	INSERT INTO [tblAudit] (audit)
--	SELECT ('An existing employee with Id = ' + CAST(@id AS NVARCHAR(5)) + ' and Name = ' + @fname + ' ' + @lname + ' is deleted at ' + CAST(GETDATE() AS NVARCHAR(20)) ) -- ❌ Watch-out the variables usage
	SELECT ('An existing employee with Id = ' + CAST(id AS NVARCHAR(5)) + ' and Name = ' + f_name + ' ' + l_name + ' is deleted at ' + CAST(GETDATE() AS NVARCHAR(20)) )
	FROM DELETED;
END;

DELETE FROM [tblMail] WHERE id > 10; 


SELECT * FROM [tblMail];
SELECT * FROM [tblAudit];


----- Remove multiple rows: keeping the order intact -----

INSERT INTO [tblMail] VALUES
(11, 'Marlin', 'Larsen', 'marlin@ddd.com', GETDATE()),
(12, 'Megan', 'Larsen', 'megann@ddd.com', GETDATE()),
(13, 'Robin', 'Larsen', 'robin@ddd.com', GETDATE()),
(14, 'Ray', 'Larsen', 'ray@ddd.com', GETDATE()),
(15, 'Bruno', 'Larsen', 'bruno@ddd.com', GETDATE());

SELECT * FROM [tblMail];
SELECT * FROM [tblAudit];

ALTER TRIGGER [tr_tblMail_ForDelete]
ON [tblMail]
FOR DELETE
AS
BEGIN
	INSERT INTO [tblAudit] (audit)
	SELECT ('An existing employee with Id = ' + CAST(id AS NVARCHAR(5)) + ' and Name = ' + f_name + ' ' + l_name + ' is deleted at ' + CAST(GETDATE() AS NVARCHAR(20)) )
	FROM DELETED
	ORDER BY id;
END;

DELETE FROM [tblMail] WHERE id > 10; 


SELECT * FROM [tblMail];
SELECT * FROM [tblAudit];


------------------------------------------------------------------------------
---- UPDATE TRIGGER ----

CREATE TRIGGER [tr_tblMail_ForUpdate]
ON [tblMail]
FOR UPDATE
AS
BEGIN
	SELECT * FROM [DELETED];
	SELECT * FROM [INSERTED];
END;

UPDATE [tblMail] SET f_name = 'Lucyy', email = 'lucyy@ddd.com' 
WHERE f_name = 'Lucy' AND l_name = 'Larsen';

SELECT * FROM [tblMail];
DELETE FROM [tblAudit];
SELECT * FROM [tblAudit];

----- Update 1 row -----
ALTER TRIGGER [tr_tblMail_ForUpdate]
ON [tblMail]
AFTER UPDATE
AS
BEGIN
	DECLARE  @auditStr NVARCHAR(MAX), @id INT, 
		@oldname NVARCHAR(50), @newname NVARCHAR(50), 
		@oldemail NVARCHAR(20), @newemail NVARCHAR(20), 
		@oldrgtrdt NVARCHAR(50), @newrgtrdt NVARCHAR(50); 

	SELECT TOP 1 
		@id = id, 
		@oldname = f_name + ' ' + l_name, 
		@oldemail = email, 
		@oldrgtrdt = CAST(registered_date AS NVARCHAR(50))
	FROM DELETED;
	
	SELECT TOP 1 
		@newname = f_name + ' ' + l_name, 
		@newemail = email, 
		@newrgtrdt = CAST(registered_date AS NVARCHAR(50))
	FROM INSERTED;
	
	SET @auditStr = 'Employee with Id = ' + CAST(@id AS NVARCHAR(5)) + ' changed ';
	IF (@oldname <> @newname) 
		SET @auditStr = @auditStr + ' Name from = ' + @oldname + ' to = ' + @newname;
	IF (@oldemail <> @newemail) 
		SET @auditStr = @auditStr + ' Email from = ' + @oldemail + ' to = ' + @newemail;
	IF (@oldrgtrdt <> @newrgtrdt) 
		SET @auditStr = @auditStr + ' Registered_date from = ' + CAST(@oldrgtrdt AS NVARCHAR(50)) + ' to = ' + CAST(@newrgtrdt AS NVARCHAR(50));
	
	INSERT INTO [tblAudit] (audit) VALUES (@auditStr);
END;

UPDATE [tblMail] SET f_name = 'Lucy', email = 'lucy@ddd.com' 
WHERE f_name = 'Lucyy' AND l_name = 'Larsen';


SELECT * FROM [tblMail];
SELECT * FROM [tblAudit];

----- Update multiple rows -----

INSERT INTO [tblMail] VALUES
(11, 'Marlin', 'Larsen', 'marlin@ddd.com', GETDATE()),
(12, 'Megan', 'Larsen', 'megann@ddd.com', GETDATE()),
(13, 'Robin', 'Larsen', 'robin@ddd.com', GETDATE()),
(14, 'Ray', 'Larsen', 'ray@ddd.com', GETDATE()),
(15, 'Bruno', 'Larsen', 'bruno@ddd.com', GETDATE());

ALTER TRIGGER [tr_tblMail_ForUpdate]
ON [tblMail]
AFTER UPDATE
AS
BEGIN
	INSERT INTO [tblAudit] (audit)
    SELECT 
        'Employee with Id = ' + CAST(i.id AS NVARCHAR(10)) + ' changed ' +
        CASE 
            WHEN d.f_name + ' ' + d.l_name <> i.f_name + ' ' + i.l_name 
                THEN 'Name from = ' + d.f_name + ' ' + d.l_name + ' to = ' + i.f_name + ' ' + i.l_name + ' '
            ELSE ''
        END +
        CASE 
            WHEN d.email <> i.email 
                THEN 'Email from = ' + d.email + ' to = ' + i.email + ' '
            ELSE ''
        END +
        CASE 
            WHEN d.registered_date <> i.registered_date 
                THEN 'Registered_date from = ' + CONVERT(NVARCHAR(50), d.registered_date) + 
                     ' to = ' + CONVERT(NVARCHAR(50), i.registered_date)
            ELSE ''
        END
    FROM INSERTED i
    JOIN DELETED d ON i.id = d.id
    WHERE 
        d.f_name + ' ' + d.l_name <> i.f_name + ' ' + i.l_name OR
        d.email <> i.email OR
        d.registered_date <> i.registered_date
END;

UPDATE [tblMail]
SET email = REPLACE(email, '@ddd', '@eee') 
WHERE email LIKE '%@ddd%';

SELECT * FROM [tblMail];
SELECT * FROM [tblAudit];


----- Remove multiple rows: keeping the order intact -----
 --- ❓NOT WORKING ❓------
ALTER TRIGGER [tr_tblMail_ForUpdate]
ON [tblMail]
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO [tblAudit] (audit)
    SELECT 
        'Employee with Id = ' + CAST(i.id AS NVARCHAR(10)) + ' changed ' +
        CASE 
            WHEN d.f_name + ' ' + d.l_name <> i.f_name + ' ' + i.l_name 
                THEN 'Name from = ' + d.f_name + ' ' + d.l_name + ' to = ' + i.f_name + ' ' + i.l_name + ' '
            ELSE ''
        END +
        CASE 
            WHEN d.email <> i.email 
                THEN 'Email from = ' + d.email + ' to = ' + i.email + ' '
            ELSE ''
        END +
        CASE 
            WHEN d.registered_date <> i.registered_date 
                THEN 'Registered_date from = ' + CONVERT(NVARCHAR(50), d.registered_date) + 
                     ' to = ' + CONVERT(NVARCHAR(50), i.registered_date)
            ELSE ''
        END
    FROM INSERTED i
    JOIN DELETED d ON i.id = d.id
    WHERE 
        d.f_name + ' ' + d.l_name <> i.f_name + ' ' + i.l_name OR
        d.email <> i.email OR
        d.registered_date <> i.registered_date
    ORDER BY id
END;

UPDATE [tblMail]
SET email = REPLACE(email, '@eee', '@ddd') 
WHERE email LIKE '%@eee%';

SELECT * FROM [tblMail];
SELECT * FROM [tblAudit];





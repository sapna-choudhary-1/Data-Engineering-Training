USE [company];


------------------------------------------------------------------------------
---- INSTEAD OF TRIGGERS ----
------------------------------------------------------------------------------
SELECT * FROM [empls];
DELETE FROM [empls] WHERE id > 5;
SELECT * FROM [depts];

DROP VIEW [vWEmplsByDepts];
CREATE VIEW [vWEmplsByDepts]
AS
SELECT e.id, name, gender_id, dept_name
FROM [empls] e
JOIN [depts] d
ON e.dept_id = d.id;

SELECT * FROM [vWEmplsByDepts];


INSERT INTO [vWEmplsByDepts] (id, name, gender_id, dept_name)
VALUES (1, 'Sana', 2, 'HR'); -- ❌ Will fail with 'View or function 'vWEmplsByDepts' is not updatable because the modification affects multiple base tables'

------------------------------------------------------------------------------
---- INSTEAD OF: INSERT TRIGGER ----

CREATE TRIGGER [tr_vWEmplsByDepts_InsteadOfInsert]
ON [vWEmplsByDepts]
INSTEAD OF INSERT
AS
BEGIN
	SELECT * FROM INSERTED;
	SELECT * FROM DELETED;
END;

INSERT INTO [vWEmplsByDepts] (id, name, gender_id, dept_name)
VALUES (1, 'Sana', 2, 'HR'); -- No error this time, instead [inserted] table displayed with data and [deleted] tbl with no data


-----  ❓NOT WORKING❓-----
ALTER TRIGGER [tr_vWEmplsByDepts_InsteadOfInsert]
ON [vWEmplsByDepts]
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @deptId INT

	--Check if there is a valid DepartmentId for the given DepartmentName
	SELECT @deptId = d.id
	FROM [depts] d
	JOIN INSERTED i
	ON d.dept_name = i.dept_name

	--If DepartmentId is null throw an error and stop processing
	IF (@deptId IS NULL)
	BEGIN
		RAISERROR ('Invalid Department Name. Statement terminated', 16, 1)
		RETURN
	END

	--Finally insert into tblEmployee table
	INSERT INTO [empls] (id, name, dept_id)
	SELECT id, name, @deptId
--	INSERT INTO [empls] (id, name, gender_id, salary, dept_id, join_date)
--	SELECT id, name, 2, 5000, @deptId, '2023-05-10'
	FROM INSERTED
END;







------------------------------------------------------------------------------
---- INSTEAD OF: UPDATE TRIGGER ----


CREATE TRIGGER tr_vWEmployeeDetails_InsteadOfUpdate ON vWEmployeeDetails
INSTEAD OF UPDATE
AS
BEGIN
	-- if EmployeeId is updated
	IF (
			UPDATE (Id)
			)
	BEGIN
		RAISERROR (
				'Id cannot be changed'
				,16
				,1
				)

		RETURN
	END

	-- If DeptName is updated
	IF (
			UPDATE (DeptName)
			)
	BEGIN
		DECLARE @DeptId INT

		SELECT @DeptId = DeptId
		FROM tblDepartment
		JOIN inserted ON inserted.DeptName = tblDepartment.DeptName

		IF (@DeptId IS NULL)
		BEGIN
			RAISERROR (
					'Invalid Department Name'
					,16
					,1
					)

			RETURN
		END

		UPDATE tblEmployee
		SET DepartmentId = @DeptId
		FROM inserted
		JOIN tblEmployee ON tblEmployee.Id = inserted.id
	END

	-- If gender is updated
	IF (
			UPDATE (Gender)
			)
	BEGIN
		UPDATE tblEmployee
		SET Gender = inserted.Gender
		FROM inserted
		JOIN tblEmployee ON tblEmployee.Id = inserted.id
	END

	-- If Name is updated
	IF (
			UPDATE (Name)
			)
	BEGIN
		UPDATE tblEmployee
		SET Name = inserted.Name
		FROM inserted
		JOIN tblEmployee ON tblEmployee.Id = inserted.id
	END
END


------------------------------------------------------------------------------
---- INSTEAD OF: DELETE TRIGGER ----

DELETE
FROM vWEmployeeDetails
WHERE Id = 1 Script TO

CREATE INSTEAD OF

DELETE

trigger:

CREATE TRIGGER tr_vWEmployeeDetails_InsteadOfDelete ON vWEmployeeDetails
INSTEAD OF DELETE
AS
BEGIN
	DELETE tblEmployee
	FROM tblEmployee
	JOIN deleted ON tblEmployee.Id = deleted.Id
		--Subquery
		--Delete from tblEmployee 
		--where Id in (Select Id from deleted)
END



------------------------------------------------------------------------------
---- DB operations ----
------------------------------------------------------------------------------

CREATE DATABASE Company;
USE [Company];

USE [db1];
DROP DATABASE [Company];

CREATE DATABASE [company];
USE [company];


------------------------------------------------------------------------------
---- TABLE creation with constraints ----
------------------------------------------------------------------------------

CREATE TABLE [departments]
(
dept_id INT PRIMARY KEY,
dept_name VARCHAR(50) NOT NULL
);
DROP TABLE [departments];

CREATE TABLE [depts]
(
dept_id INT PRIMARY KEY,
dept_name VARCHAR(50) NOT NULL
);

CREATE TABLE [empls]
(
emp_id INT PRIMARY KEY,
emp_name VARCHAR(50) NOT NULL,
age INT CHECK (age >= 18),
salary DECIMAL(10, 2) DEFAULT 3000 CHECK (salary > 0),
dept_id INT,
CONSTRAINT fk_Company_empls FOREIGN KEY (dept_id)
	REFERENCES [depts] (dept_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);


------------------------------------------------------------------------------
---- remove previous constraints & add modified constraints and cols_type ----
------------------------------------------------------------------------------

ALTER TABLE [empls]
ALTER COLUMN [emp_name] NVARCHAR(50);

SELECT name
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID('empls');

ALTER TABLE [empls]
DROP CONSTRAINT CK__empls__age__3B75D760, CK__empls__salary__3D5E1FD2, fk_Company_empls;

ALTER TABLE [empls]
ADD CONSTRAINT CK_empls_age CHECK (age >= 18 AND age <= 150);

ALTER TABLE [empls]
ADD CONSTRAINT CK_empls_salary CHECK (salary > 0);

ALTER TABLE [empls]
ADD CONSTRAINT FK_empls_salary FOREIGN KEY (dept_id)
	REFERENCES [depts] (dept_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE

ALTER TABLE [depts]
ALTER COLUMN [dept_name] NVARCHAR(50);


------------------------------------------------------------------------------
---- add rows ----
------------------------------------------------------------------------------

INSERT INTO [depts] (dept_id, dept_name)
VALUES (1, 'HR'), (2, 'IT');

INSERT INTO [empls]
VALUES
(101, 'Alice', 25, 500000, 1),
(102, 'Bob', 30, 60000, 1),
(103, 'Charlie', 28, 40000, 2);


------------------------------------------------------------------------------
---- try to add rows with values contradicting with constraints----
------------------------------------------------------------------------------

INSERT INTO [empls]
VALUES (104, 'David', 16, 35000, 2);  -- ❌ Will fail with 'conflicted with the CHECK constraint "CK_empls_age"'

INSERT INTO [empls]
VALUES (105, 'Emma', 24, 0, 2);  -- ❌ Will fail with 'conflicted with the CHECK constraint'


------------------------------------------------------------------------------
---- delete rows & chk on delete cascade ----
------------------------------------------------------------------------------

DELETE FROM [depts]
WHERE dept_id = 2;

INSERT INTO [depts] (dept_id, dept_name)
VALUES (1, 'HR'), (2, 'IT');  -- ❌ Will fail with 'duplicate key value' for dept_id=1

INSERT INTO [depts] (dept_id, dept_name)
VALUES (2, 'IT');

ALTER TABLE [depts]
ADD CONSTRAINT NOT NULL;  -- ❌ Will fail with 'Incorrect syntax near the keyword 'NOT' '

INSERT INTO [depts] (dept_id)
VALUES (4);

DELETE FROM [depts]
WHERE dept_id = 4;


------------------------------------------------------------------------------
---- add 'not null', default constraint & chk on update cascade ----
------------------------------------------------------------------------------

ALTER TABLE [depts]
ALTER COLUMN [dept_name] NVARCHAR(50) NOT NULL;

INSERT INTO [depts] (dept_id)
VALUES (3);  -- ❌ Will fail with 'Cannot insert the value NULL'

ALTER TABLE [depts]
ADD CONSTRAINT DF_depts_dept_name DEFAULT 'Unkown' FOR [dept_name];

INSERT INTO [depts] (dept_id)
VALUES (4);

INSERT INTO [empls]
VALUES
(103, 'Charlie', 28, 40000, 2),
(104, 'David', 23, 35000, 4),
(105, 'Emma', 24, 20000, 4);

UPDATE [depts]
SET dept_id = 3
WHERE dept_id = 4;


------------------------------------------------------------------------------
---- update constraint on age using 'CAST' from str->int ----
------------------------------------------------------------------------------

ALTER TABLE [empls]
DROP CONSTRAINT [CK_empls_age];

INSERT INTO [empls]
VALUES
(106, 'Charls', 8, 30000, 2);  -- Will pass

DELETE FROM [empls]
WHERE emp_id = 106;

ALTER TABLE [empls]
ALTER COLUMN age NVARCHAR(3);

ALTER TABLE [empls]
ADD CONSTRAINT CK_empls_age CHECK (
	CAST(age AS INT) >= 18 AND CAST(age AS INT) <=150
);

INSERT INTO [empls]
VALUES
(106, 'Charls', 8, 30000, 2); -- ❌ Will fail with 'conflicted with the CHECK constraint "CK_empls_age"'


------------------------------------------------------------------------------
---- add new column & use 'DATE' ----
------------------------------------------------------------------------------

ALTER TABLE [empls]
ADD join_date DATE NOT NULL CONSTRAINT DF_empls_join_date DEFAULT GETDATE();

ALTER TABLE [empls]
ADD CONSTRAINT CK_empls_join_date CHECK (join_date <= GETDATE());

INSERT INTO [empls]
VALUES
(106, 'Charls', 25, 30000, 2); -- ❌ Will fail with 'Column name or number of supplied values does not match table definition.'

INSERT INTO empls
VALUES (106, 'Charls', 25, 30000, 2, DEFAULT);

INSERT INTO [empls] (emp_id, emp_name, age, salary, dept_id)
VALUES (107, 'Anna', 23, 25000, 1);


------------------------------------------------------------------------------
---- add 'IDENTITY' property to the already existing column & removing P.K. ----
------------------------------------------------------------------------------

ALTER TABLE [empls]
ADD emp_id_new INT IDENTITY(1,1);

SELECT name
FROM sys.key_constraints
WHERE parent_object_id = OBJECT_ID('empls') AND type = 'PK';

ALTER TABLE [empls]
DROP CONSTRAINT [PK__empls__1299A861B42B297A];

ALTER TABLE [empls]
DROP COLUMN emp_id;

EXEC sp_rename 'empls.emp_id_new', 'emp_id', 'COLUMN';

ALTER TABLE [empls]
ADD CONSTRAINT PK_empls_emp_id PRIMARY KEY (emp_id);

EXEC sp_rename 'dbo.FK_empls_salary', 'FK_empls_dept_id', 'OBJECT'; -- You can omit the table name, because Constraints are not scoped by table in sp_rename'


------------------------------------------------------------------------------
---- trying 'SET IDENTITY_INSERT' ----
------------------------------------------------------------------------------

ALTER TABLE [empls]
ADD CONSTRAINT DF_empls_dept_id DEFAULT 3 FOR [dept_id];

SET IDENTITY_INSERT [empls] ON;

INSERT INTO [empls] (emp_id, emp_name, age, salary, join_date)
VALUES (108, 'Alec', 30, 50000, '2023-05-28');

SET IDENTITY_INSERT [empls] OFF;

INSERT INTO [empls] (emp_name, age, salary, join_date)
VALUES ('Bruno', 36, 50000, '2020-05-10');

DELETE FROM [empls]
WHERE emp_id = 109;

INSERT INTO [empls] (emp_name, age, salary, join_date)
VALUES ('Bruno', 36, 50000, '2020-05-10');

SET IDENTITY_INSERT [empls] ON;

INSERT INTO [empls] (emp_name, age, salary, join_date)
VALUES ('Bob', 26, 34000, '2024-05-10'); -- ❌ Will fail with 'Explicit value must be specified for identity column in table 'empls' either when IDENTITY_INSERT is set to ON'

DELETE FROM [empls]
WHERE emp_id = 3 OR emp_id = 4;

INSERT INTO [empls] (emp_id, emp_name, age, salary)
VALUES (3, 'Charlie', 28, 40000);

SET IDENTITY_INSERT [empls] OFF;

INSERT INTO [empls] (emp_name, age, salary)
VALUES ('David', 23, 35000);


------------------------------------------------------------------------------
---- trying 'DBCC CHECKIDENT' ----
------------------------------------------------------------------------------

DELETE FROM [empls];

INSERT INTO [empls] (emp_name, age, salary, dept_id)
VALUES ('Alice', 25, 500000, 1); -- Will add with id = 113 and not 1

DELETE FROM [empls];

DBCC CHECKIDENT('empls', RESEED, 0);

INSERT INTO [empls] (emp_name, age, salary, dept_id)
VALUES ('Alice', 25, 500000, 1); -- Will add with id = 1 (0++)

INSERT INTO [empls] (emp_name, age, salary, dept_id)
VALUES 
('Bob', 30, 60000, 2),
('Charlie', 28, 40000, 3);

INSERT INTO [empls] (emp_name, age, salary, dept_id, join_date)
VALUES ('Emma', 24, 50000, 2, '2020-05-10');


------------------------------------------------------------------------------
---- finding last identity value ----
------------------------------------------------------------------------------

SELECT SCOPE_IDENTITY();
SELECT @@IDENTITY;
SELECT IDENT_CURRENT('empls');


------------------------------------------------------------------------------
---- add 'UNIQUE' constraint ----
------------------------------------------------------------------------------

ALTER TABLE [depts]
ADD CONSTRAINT UK_depts_dept_name UNIQUE (dept_name);

EXEC sp_rename 'dbo.UK_depts_dept_name', 'UQ_depts_dept_name', 'OBJECT';

INSERT INTO [depts] (dept_id)
VALUES (4); -- ❌ Will fail with 'Violation of UNIQUE KEY constraint 'UQ_depts_dept_name' '



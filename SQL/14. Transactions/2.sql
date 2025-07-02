
------------------------------------------------------------------------------
---- DEADLOCK ----
------------------------------------------------------------------------------
USE [db1]

DROP TABLE [tblSrc];
DROP TABLE [tblTarget];

CREATE TABLE [tblSrc]
(
	id INT,
	name NVARCHAR(20)
);
CREATE TABLE [tblTarget]
(
	id INT,
	name NVARCHAR(20)
);

INSERT INTO [tblSrc] VALUES
(1, 'Mike'),
(2, 'Sara');
INSERT INTO [tblTarget] VALUES
(1, 'Mike M'),
(3, 'John');

SELECT * FROM [tblSrc];
SELECT * FROM [tblTarget];

------------------------------------------------------------------------------
---------- Merge  ----------

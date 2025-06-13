------------------------------------------------------------------------------
---- DB operations ----
------------------------------------------------------------------------------

CREATE DATABASE db1;

SELECT name, state_desc 
FROM sys.databases;

USE db1;

CREATE DATABASE db;

DROP DATABASE db;


------------------------------------------------------------------------------
---- TABLE creation ----
------------------------------------------------------------------------------

CREATE TABLE "info"
(
ID int NOT NULL PRIMARY KEY,
Name NVARCHAR(50) NOT NULL,
Email NVARCHAR(50) NOT NULL,
GenderID int
);

CREATE TABLE gender (
ID int NOT NULL PRIMARY KEY,
Gender NVARCHAR(50) NOT NULL
);

----
CREATE TABLE "infoo"
(
ID int NOT NULL PRIMARY KEY,
Name NVARCHAR(50) NOT NULL,
Email NVARCHAR(50) NOT NULL,
GenderID int
);

DROP TABLE infoo;


------------------------------------------------------------------------------
---- add 'FOREIGN KEY' constraint ----
------------------------------------------------------------------------------

ALTER TABLE "info" ADD CONSTRAINT info_genderId_fk
FOREIGN KEY (GenderId) REFERENCES "gender" (ID);

--or---
ALTER TABLE [infoo] ADD CONSTRAINT info_genderId_fkk
FOREIGN KEY (GenderId) REFERENCES gender (ID);


------------------------------------------------------------------------------
---- View TABLE data ----
------------------------------------------------------------------------------

SELECT * FROM info;
SELECT * FROM gender;


------------------------------------------------------------------------------
---- Add rows ----
------------------------------------------------------------------------------

INSERT INTO info (ID, Name, Email) VALUES (5, 'Simon', 's@s.com');
INSERT INTO info (ID, Name, Email, GenderID) VALUES (6, 'Katy', 'ka@ka.com', 2 );


------------------------------------------------------------------------------
---- add 'DEFAULT' constraint ----
------------------------------------------------------------------------------

ALTER TABLE info ADD CONSTRAINT info_genderId_df
DEFAULT 3 FOR GenderId;

INSERT INTO info (ID, Name, Email) VALUES (7, 'Sam', 'sa@sa.com');
INSERT INTO info (ID, Name, Email, GenderID) VALUES (8, 'Kat', 'kt@kt.com', Null );

----




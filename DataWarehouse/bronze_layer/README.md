## STEPS

1. Create Tables
2. Insert Data into the tables:-
    - To find access path in local machine:

        - `
    SELECT SERVERPROPERTY('InstanceDefaultDataPath') AS DataPath;
    `
    - Check whether the csv input-file exists on the path:

        - `
    EXEC xp_fileexist '/var/opt/mssql/data/DWH_raw_dataset/dim_category.csv';
    `

3. Create Stored Procedure
4. Add TRY-CATCH Blocks 
5. Add Loading Duration for each table 
6. Add Loading Duration for the whole Bronze layer batch

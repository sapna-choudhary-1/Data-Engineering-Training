## TOPICS COVERED

1. Stored Procedures
    - Creation, Aletering, Deletion
    - Exec/Execution Keyword
    - To view:-
        - dependencies: sp_depends
        - text: sp_helptext
        - information: sp_help
    - Output Parameter
    - Optional Parameter
    - Return Value
        - Return Value Vs. Output Parameter
    Connecting SQL with HTML Form, using stored procedures
    
2. Table Operations
    - List all tables in a specific db
        - sysobjects
        - sys.tables
        - information_schema.tables
    - Check table existence
        - Exists/ Not Exists
    - Check object existence
        - ObjectId(obj) IS Null/ Not Null
    - Check column existence
        - Exists/ Not Exists
        - Col_Length()
    - ReRunnable Script
    - Operations
        - Add new column
        - Rename column
        - Delete column
        - Set column as Null/ Not Null
        - Add, Delete Default Constraint
        - Add, Delete other constraints
        - Check different constraints put on the table
            - sys.objects
            - sys.default_constraints
            - sys.check_constraints
            - sys.foreign_keys

3. Data Insertion:
    - Select Into
        - Create table with only columns & data types matching, not data
    - Insert Into -> Select

4. Table Valued Parameters

5. Object dependencies
    - Schema-bound dependency
    - Non-Schema-bound dependency
    - Check all the object dependencies
        - sys.dm_sql_referencing_entities()
        - sys.dm_sql_referenced_entities()
    - Check foreign key relationships
        - sys.foreign_keys
    - Object_Name(), Object_Id()


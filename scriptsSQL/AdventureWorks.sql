USE AdventureWords2017
go
DECLARE Employee_Cursos CURSOR FOR
	SELECT BusinessEntityID, JobTitle
	FROM AdventureWorks2017.HumanResources.Employee;
OPEN Employee_Cursos;
FETCH NEXT FROM Employee_Cursor;
WHILE @@FETCH_STATUS = 0
	BEGIN
		FETCH NEXT FROM Employee_Cursor
	END;
CLOSE Employe_Cursor;
DEALLOCATE Employee_Cursor;
GO
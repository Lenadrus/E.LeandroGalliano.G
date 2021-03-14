
-- Create a “Last Modified” Column in SQL Server



USE tempdb
GO
CREATE TABLE dbo.Books (
	BookId int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	BookName nvarchar(1000) NOT NULL,
	CreateDate datetime DEFAULT CURRENT_TIMESTAMP,
	ModifiedDate datetime DEFAULT CURRENT_TIMESTAMP
);
GO

CREATE OR ALTER TRIGGER trg_Books_UpdateModifiedDate
ON dbo.Books
AFTER UPDATE
AS
	UPDATE dbo.Books
	SET ModifiedDate = CURRENT_TIMESTAMP
	WHERE BookId IN (SELECT DISTINCT BookId FROM inserted);
GO

INSERT INTO Books (BookName) 
VALUES ('Trigger Happy');
GO

INSERT INTO Books (BookName) 
VALUES ('DAGON');
GO

INSERT INTO Books (BookName) 
VALUES ('invento');
GO

SELECT * FROM Books;
GO

UPDATE Books
SET Bookname = 'Logos'
WHERE BookId = 2;
GO
-- Inventu: 2021-02-23 21:17:49.630 , Invento: 2021-02-23 21:18:16.893 .
-- El Caos: 2021-02-23 21:20:29.723 , Logos: 2021-02-23 21:21:45.160 .
--BookId	BookName		CreateDate					ModifiedDate
--1			Trigger Happy	2021-02-11 08:45:07.293		2021-02-11 08:45:07.293

UPDATE Books 
SET BookName = 'Trigger Hippy'
WHERE BookId = 1;
GO

SELECT * FROM Books;
GO

--BookId	BookName			CreateDate						ModifiedDate
--1			Trigger Hippy	2021-02-11 08:45:07.293			2021-02-11 08:47:23.203

USE pubs
GO
DROP TABLE IF EXISTS autores
GO
SELECT *
	INTO autores
	FROM authors
GO
IF OBJECT_ID ('trg-actualizar_ciudad', 'TR') IS NOT NULL
	DROP TRIGGER trf_actualizar_ciudad;
GO
DROP TRIGGER IF EXISTS trg_actualizar_ciudad
GO
CREATE OR ALTER TRIGGER trg_actualizar_ciudad
ON autores
FOR UPDATE
AS
	IF UPDATE (city)
		BEGIN
			RAISERROR('No puedes cambiar la ciudad', 15, 1)
			ROLLBACK TRAN
		END
	ELSE
		PRINT 'Operación Correcta'
GO
CREATE OR ALTER TRIGGER trg_actualizar_grupo
ON autores
FOR UPDATE
AS
	IF UPDATE
SELECT * FROM autores
GO
UPDATE autores
SET au_lname = 'Verde' 
WHERE au_id = '213-46-8915';
GO

UPDATE autores
SET city = 'Santiago De Compostela'
WHERE au_fname = 'San Jose';
GO

USE Northwind
GO
DROP TRIGGER IF EXISTS trg_soloBorraUno;
CREATE OR ALTER TRIGGER trg_SoloBorraUno
ON Employees
FOR DELETE
AS
	IF (@@ROWCOUNT>1)
		BEGIN
			RAISERROR('No puedes borrar más de un registro',15,1)
			ROLLBACK TRAN
		END
	ELSE
		PRINT 'Operación Correcta'
GO

DELETE Employees
GO
DELETE Employees
AS
	IF (@@ROWCOUNT > 1)
		BEGIN
			RAISERROR('No puedes borrar más de un registro', 15, 1)
			ROLLBACK TRAN
		END
	ELSE
		PRINT 'Operación Correcta'
GO

USE AdventureWorks2017
GO
DROP TABLE IF EXISTS Employees
GO
SELECT * 
INTO employees
FROM [HumanResources].[Employee]
GO
SELECT * FROM employees
GO

CREATE OR ALTER TRIGGER trg_no_borrar_empleados
ON employees
INSTEAD OF DELETE
	AS
		DECLARE @Count int
		SET @Count = @@ROWCOUNT;
		IF @Count = 0 
			RETURN;
	BEGIN
		RAISERROR
			('Los empleados no pueden ser eliminados. Sólamente pueden ser marcados como no presentes.',10,1); -- Message, -- Severity, --State.

		-- Rollback any active or uncommittable transactions
		IF @@ROWCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
		END
	END;
END;




USE AdventureWorks2017;
IF OBJECT_ID ('Person.Direcciones', 'U') IS NOT NULL
		DROP TABLE Person.Direcciones
GO

--DROP TABLE IF EXISTS Person.Address
--GO
SELECT [AddressLine1],[City],[StateProvinceID],[PostalCode]
	INTO Person.Direcciones
	FROM Person.Address
GO
SELECT * FROM Person.Direcciones
GO





USE AdventureWorks2017;
-- Existen triggers en todos los sistemas. MySQL, PostGress, etc...
IF OBJECT_ID('tr_Direcciones','TR') IS NOT NULL
		DROP TRIGGER tr_Direcciones
GO
CREATE OR ALTER TRIGGER tr_Direcciones
ON Person.Direcciones
INSTEAD OF INSERT
AS
BEGIN 
	IF EXISTS
		(
		SELECT AddressLine1
		FROM Inserted
		WHERE RIGHT(AddressLine1, 3) = 'Ave' -- En realidad quiso decir "LEFT", pero dejar RIGHT().
		)
		INSERT INTO Person.Direcciones
			(AddressLine1,City,StateProvinceID,PostalCode)
			SELECT REPLACE(AddressLine1, 'Ave', 'Avenue'), City, StateProvinceID, PostalCode
			FROM Inserted;
	ELSE
		INSERT INTO Person.Direcciones
			(AddressLine1,City,StateProvinceID,PostalCode)
			SELECT AddressLine1, City, StateProvinceID, PostalCode
			FROM Inserted;
END
GO
SELECT * FROM Person.Direcciones;
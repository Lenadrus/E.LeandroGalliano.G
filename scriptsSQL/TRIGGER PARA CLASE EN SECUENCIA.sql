

-- TRIGGER PARA CLASE EN SECUENCIA

------------------------------------------------

-- Create a “Last Modified” Column in SQL Server

-- https://database.guide/create-a-last-modified-column-in-sql-server/

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

SELECT * FROM Books;
GO

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


INSERT INTO Books (BookName) 
VALUES ('libro 2');
GO

SELECT * FROM Books;
GO


--BookId	BookName			CreateDate				ModifiedDate
--1			Trigger Happy	2021-02-23 21:09:51.530		2021-02-23 21:09:51.530
--2			libro 2			2021-02-23 21:10:50.423		2021-02-23 21:10:50.423



UPDATE Books 
SET BookName = 'primer Libro'
WHERE BookId = 1;
GO

-- 2021-02-23								 21:09:51.530

SELECT * FROM Books;
GO

--2021-02-23								21:16:42.430
UPDATE Books 
SET BookName = 'Mi segundo libro Libro'
WHERE BookId = 2;
GO


SELECT * FROM Books;
GO



-- EXPLANATION

--When it runs, it updates the ModifiedDate column to the CURRENT_TIMESTAMP (but only on the row that was updated, of course).

--I’m able to determine which row was updated by checking the inserted table. The inserted table is a temporary, memory-resident table that SQL Server creates and maintains.

--The inserted table stores copies of the affected rows during INSERT and UPDATE statements. During an insert or update transaction, new rows are added to both the inserted table and the trigger table. The rows in the inserted table are copies of the new rows in the trigger table.

--In addition to the inserted table, SQL Server also creates and maintains a deleted table. An update transaction is similar to a delete operation followed by an insert operation; the old rows are copied to the deleted table first, and then the new rows are copied to the trigger table and to the inserted table.



---------------------------------------
--Trigger con estructura condicional sobre un campo
---------------------------------------
USE pubs
GO
DROP TABLE IF EXISTS AUTORES
GO
SELECT *
	INTO AUTORES
	FROM AUTHORS
GO
IF OBJECT_ID ('trg_actualizar_ciudad', 'TR') IS NOT NULL
   DROP TRIGGER trg_actualizar_ciudad;
GO
DROP TRIGGER IF EXISTS trg_actualizar_ciudad
GO
CREATE OR ALTER TRIGGER trg_actualizar_ciudad
ON autores
FOR UPDATE
AS
	IF UPDATE (city)
			BEGIN 
					RAISERROR('No puedes cambiar la ciudad', 15,1)
					ROLLBACK TRAN
			END
	ELSE
			PRINT 'Operación Correcta'
GO
SELECT * FROM AUTORES
GO

-- No cambia city
UPDATE Autores
SET contract= 0
WHERE city='Oakland' ;
GO

UPDATE Autores
SET au_lname = 'BLANCO'
WHERE au_fname='Johnson' ;
GO
SELECT * 
FROM Autores
WHERE au_fname='Johnson'
GO


UPDATE Autores
SET city = 'CORUÑA'
WHERE au_fname='Johnson' ;
GO

SELECT * 
FROM Autores
WHERE au_fname='Johnson'
GO
-- cambia city

update Autores
set city='AC' 
where state='CA'
go	

SELECT * FROM Autores
go
------

-----------------------------------------------------------------------------------------------
				--Trigger que nos impide actualizar un campo determinado UPDATE
-----------------------------------------------------------------------------------------------
USE AdventureWorks2017
GO

SELECT *
INTO DEPARTAMENTO
FROM HumanResources.Department
GO

SELECT * FROM DEPARTAMENTO
GO

create OR ALTER trigger trg_U_Departmento
on DEPARTAMENTO
after update --after y for se pueden emplear indistintamente
as
	if UPDATE(groupname)
		BEGIN
			PRINT 'Updates to Groupname requires DBA involvement.';
			ROLLBACK TRAN;
		END
GO
	
--Intentamos actualizar groupname
UPDATE DEPARTAMENTO
SET GroupName='Research an Development'
WHERE DepartmentID=10;
--------------Updates to Groupname requires DBA involvement.
--------------Msg 3609, Level 16, State 1, Line 1
--------------The transaction ended in the trigger. The batch has been aborted.

--Probamos a actualizar otro campo
select * from DEPARTAMENTO WHERE DepartmentID=10;
----10		Finance		Executive General and Administration		2002-06-01 00:00:00.000
UPDATE DEPARTAMENTO
SET Name='Finanzas'
WHERE DepartmentID=10;
--10	Finanzas	Executive General and Administration	2002-06-01 00:00:00.000
--Volvemos al estado inicial
UPDATE DEPARTAMENTO
SET Name='Finance'
WHERE DepartmentID=10;
GO

-------------------------------------------------------------------------------------
--Crear un trigger que no permita borrar más de un registro con una sentencia delete
--Tabla Employees de Northwind
USE Northwind
GO
IF OBJECT_ID('Empleados','U')is not null
DROP TABLE Empleados
GO
SELECT EmployeeID, LastName 
INTO Empleados 
FROM Employees ;
GO
SELECT * FROM Empleados ORDER BY EmployeeID
GO
-- 1 Solucion
DROP TRIGGER IF EXISTS trg_SoloBorraUno
GO
CREATE OR ALTER TRIGGER trg_SoloBorraUno
ON Empleados
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
DELETE Empleados
GO
--Msg 50000, Level 15, State 1, Procedure trg_SoloBorraUno, Line 7 [Batch Start Line 267]
--No puedes borrar más de un registro
--Msg 3609, Level 16, State 1, Line 268
--The transaction ended in the trigger. The batch has been aborted.

DELETE Empleados
WHERE EmployeeID=1
GO
--Operación Correcta

--(1 row affected)
------------------------

-- 2 Solucion
IF OBJECT_ID ('trg_delete_individual', 'TR') IS NOT NULL
   DROP TRIGGER trg_delete_individual;
GO
CREATE OR ALTER TRIGGER trg_delete_individual
ON Empleados
FOR DELETE
AS
	IF (SELECT COUNT(*) FROM deleted) > 1
			BEGIN 
				RAISERROR('Borra sólo un empleado',16,3);
				ROLLBACK
				RETURN
			END
	ELSE
			PRINT 'Empleado Borrado'
GO

delete Empleados 
where EmployeeID >5;
go	
--Devuelve:
------------Msg 50000, Level 16, State 3, Procedure trg_delete_individual, Line 7
------------Borra sólo un empleado
------------Msg 3609, Level 16, State 1, Line 1
------------The transaction ended in the trigger. The batch has been aborted.

-- Borra 5 , Trigger no lo impide
delete Empleados 
where EmployeeID =5;
go

--Empleado Borrado
--(1 row(s) affected)
-- 
SELECT * FROM  Empleados 
where EmployeeID =5;
go


--drop table Empleados;
--drop trigger trg_delete_individual;


-------------------------

-- 3 Solución 

-- TRIGGER INSTEAD OF DELETE 

-- USO DE FUNCIONES @@ROWCOUNT -  @@TRANCOUNT

-- @@ROWCOUNT

--Returns the number of rows affected by the last statement. 
--If the number of rows is more than 2 billion, use ROWCOUNT_BIG.

-- @@TRANCOUNT

-- @@TRANCOUNT returns the count of open transactions in the current session. 
-- It increments the count value whenever we open a transaction and decrements 
-- the count whenever we commit the transaction.
-- Rollback sets the trancount to zero and transaction with save point does to affect the trancount value.

USE ADVENTUREWORKS2017
GO
DROP TABLE IF EXISTS EMPLEADOS
GO
SELECT *
INTO EMPLEADOS
FROM [HumanResources].[Employee]
GO
SELECT * from EMPLEADOS
go
-- (290 rows affected)

CREATE  OR ALTER TRIGGER trg_no_borrar_empleados
ON EMPLEADOS 
INSTEAD OF DELETE 
 AS 
BEGIN
    DECLARE @Count int;

    SET @Count = @@ROWCOUNT;
    IF @Count = 0 
        RETURN;

    BEGIN
        RAISERROR
            ('Employees cannot be deleted. They can only be marked as not current.', -- Message
            10, -- Severity.
            1); -- State.

        -- Rollback any active or uncommittable transactions
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END
    END;
END;
GO


-- PRUEBA

DELETE EMPLEADOS
GO


--Employees cannot be deleted. They can only be marked as not current.
--Msg 3609, Level 16, State 1, Line 45
--The transaction ended in the trigger. The batch has been aborted.


DELETE EMPLEADOS
	WHERE BusinessEntityID =1 -- EXISTE
GO

--Employees cannot be deleted. They can only be marked as not current.
--Msg 3609, Level 16, State 1, Line 62
--The transaction ended in the trigger. The batch has been aborted.

DELETE EMPLEADOS
	WHERE BusinessEntityID =300 -- NO EXISTE
GO

--(0 rows affected)



GO




---------------------
-- The purpose of this trigger is to monitor every insert for the abbreviation ‘Ave’ 
-- and replace it with the full word ‘Avenue’.


Use AdventureWorks2017
GO
--DISABLE TRIGGER Person.uAddress ON Person.Address;
--GO
--DISABLE TRIGGER safety ON DATABASE;
--GO

-- USO DE LA FUNCIÓN DE CADENA REPLACE  RIGHT

-- Replaces all occurrences of a specified string value with another string value.

-- SYNTAX
-- REPLACE ( string_expression , string_pattern , string_replacement )

IF OBJECT_ID('Person.Direcciones','U') is not Null
		DROP TABLE Person.Direcciones
GO

DROP TABLE IF EXISTS Person.Direcciones
GO
SELECT [AddressLine1],[City],[StateProvinceID],[PostalCode]
	INTO Person.Direcciones
	FROM Person.Address
GO
SELECT * FROM Person.Direcciones
GO








IF OBJECT_ID('tr_Direcciones','TR') is not Null
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
		WHERE RIGHT(AddressLine1, 3) = 'Ave'
		)



		INSERT INTO Person.Direcciones
			(AddressLine1, City, StateProvinceID, PostalCode)
			SELECT REPLACE(AddressLine1	, 'Ave', 'Avenue'), City, StateProvinceID, PostalCode
			FROM Inserted;
	ELSE
		INSERT INTO Person.Direcciones
			(AddressLine1, City, StateProvinceID, PostalCode)
			SELECT AddressLine1, City, StateProvinceID, PostalCode
			FROM Inserted;
END
GO

-- PROBANDO

-- Next, we use the “Instead of Insert” key phrase so our trigger will fire prior to the new row 
-- being inserted. The “If Exists” statement looks for the abbreviation “Ave” at the end the new row 
-- to be inserted. 
-- If it exists, we replace it with the word “Avenue”, 
-- if it doesn’t exist, we’ll just insert what was entered.








INSERT INTO Person.Direcciones	(AddressLine1, City, StateProvinceID, PostalCode)
			VALUES	('Honduras Ave', 'city3', 79, '33333')
GO

--(1 row affected)

--(1 row affected)


-- Avenue por Ave
SELECT AddressLine1
	FROM Person.Direcciones
	WHERE PostalCode = '33333';
GO

--AddressLine1
--Honduras Avenue

SELECT *
	FROM Person.Direcciones
	WHERE PostalCode = '33333';
GO









INSERT INTO Person.Direcciones	(AddressLine1, City, StateProvinceID, PostalCode)
			VALUES	('Perez Ave', 'city3', 79, '44444');
GO	

SELECT AddressLine1
	FROM Person.Direcciones
	WHERE PostalCode = '44444'
GO
SELECT *
	FROM Person.Direcciones
	WHERE PostalCode = '44444'
GO

INSERT INTO Person.Direcciones	(AddressLine1, City, StateProvinceID, PostalCode)
			VALUES	('Juan florez', 'city3', 79, '55555');
GO	


-- Sin Cambio
SELECT AddressLine1
	FROM Person.Direcciones
	WHERE PostalCode = '55555'
GO

SELECT AddressLine1
	FROM Person.Direcciones
	WHERE PostalCode = '55555'
GO

--------------------------

-- DESENCADENADOR (TRIGGER) QUE DESCUENTA LAS EXISTENCIAS DE LA TABLA PRODUCTOS SEGUN EL PEDIDO

-- Inserta pedido y descuenta Existencias. 
-- La INTEGRIDAD REFERENCIAL controla si intentas servir un Pedido sobre un Producto que no existe

-- Mal funcionamiento. Añadir ROLLBACK

-- Controlar si hay Existencias para hacer frente al Pedido

DROP DATABASE IF EXISTS Almacen
GO
Create Database Almacen
Go
Use Almacen
Go

-- ERROR por  --Could not drop object 'Productos' because it is referenced by a FOREIGN KEY constraint.

DROP TABLE IF EXISTS Productos
GO
DROP TABLE IF EXISTS Pedidos
GO
-- Hint
-- Error incluso con Pedidos !!!!
--Msg 3726, Level 16, State 1, Line 8
--Could not drop object 'Productos' because it is referenced by a FOREIGN KEY constraint.

sp_helpconstraint productos
GO
sp_helpconstraint pedidos
GO
ALTER TABLE Pedidos
	NOCHECK CONSTRAINT  Pk_Id_Producto
GO
ALTER TABLE Pedidos
	CHECK CONSTRAINT  Pk_Id_Producto
GO

DROP TABLE IF EXISTS Productos
GO
Create  Table Productos (
	Id_Producto Char (8) Primary Key Not Null,
	Nombreproducto Varchar (25) Not Null,
	Existencia Int Null,
	Precio Decimal(10,2) Not Null,
	Precioventa Decimal (10,2)
)
Go

DROP TABLE IF EXISTS Pedidos
GO

Create Table Pedidos ( 
	Id_Pedido Int Identity,
	Id_Producto Char (8) Not Null,
	Cantidad_Pedido Int 
	Constraint  Pk_Id_Producto Foreign Key (Id_Producto)
	References Productos (Id_Producto)
)
Go 












--INSERTAMOS REGISTROS A LA TABLA PRODUCTOS PARA REALIZAR LA DEMOSTRACIÓN



Insert Into Productos Values ('P001', 'Filtros Pantalla', 5, 10, 12.5)
Insert Into Productos Values ('P002', 'Teclados', 7, 10, 11.5)
Insert Into Productos Values ('P003', 'Mouse', 8, 4.5, 6)
Go 


SELECT * 
	FROM Productos
	ORDER BY Id_Producto
GO

--Id_Producto	Nombreproducto			Existencia	Precio	Precioventa
--P001    	Filtros Pantalla		5		10.00	12.50
--P002    	Teclados			7		10.00	11.50
--P003    	Mouse				8		4.50	6.00


SELECT * FROM Pedidos
GO











--CREAMOS DESENCADENADOR CON TRIGGER

-- Insertamos en Pedidos y descontamos en Productos

-- La no existencia del Ariculo en el Pedido
-- se controla con la INTEGRIDAD REFERENCIAL

DROP TRIGGER IF EXISTS Trg_Pedido_Articulos
GO
Create or Alter Trigger Trg_Pedido_Articulos
On Pedidos
For Insert
As
		Update Productos 
		Set Existencia = Existencia - (Select Cantidad_Pedido From Inserted)
		Where Id_Producto = (Select Id_Producto From Inserted)
Go

















-- PUEDES VERIFICAR LAS CANTIDADES, LUEGO REALIZAS EL PEDIDO DE LA SIGUIENTE MANERA
-- 
-- En Productos
-- P003    	Mouse	8	4.50	6.00

-- Producto Existe

Insert Into Pedidos 
	Values ('P003',5)
GO
-- FUNCIONA, EL TRIGGER DESCONTÓ LA CANTIDAD SEGÚN EL PEDIDO
Select * 
	From Productos
	where [Id_Producto] = 'P003'
GO
--P003    	Mouse	3	4.50	6.00

Select * From Pedidos
GO
-- 1	P003    	5


-- Producto NO Existe 'P033'

Insert Into Pedidos 
	Values ('P033',5)
GO

--Msg 547, Level 16, State 0, Line 94
--The INSERT statement conflicted with the FOREIGN KEY constraint "Pk_Id_Producto". The conflict occurred in database "Almacen", table "dbo.Productos", column 'Id_Producto'.
--The statement has been terminated.




-- Contolar si hay suficiente Existencias para cubrir Pedido

DROP TRIGGER IF EXISTS Trg_Pedido_Articulos
GO
Create or Alter Trigger Trg_Pedido_Articulos
On Pedidos
For Insert
As
		DECLARE @Existencias int
		SELECT  @Existencias=Existencia
		FROM Productos 
		Where Id_Producto = (Select Id_Producto From Inserted)
		IF  @Existencias < (Select Cantidad_Pedido From Inserted)
			BEGIN
				RAISERROR ('No hay Existencias.', -- Message text.  
               16, -- Severity.  
               1 -- State.  
               ); 
				RETURN
			END
		ELSE
			BEGIN	
				Update Productos 
				Set Existencia = Existencia - (Select Cantidad_Pedido From Inserted)
				Where Id_Producto = (Select Id_Producto From Inserted)
			END
Go

SELECT * FROM Productos
GO
--Id_Producto	Nombreproducto			Existencia	Precio	Precioventa
--P001    		Filtros Pantalla			5		10.00	12.50
--P002    		Teclados					7		10.00	11.50
--P003    		Mouse						3		4.50	6.00


-- Se piden mas Existencias de las que hay

Insert Into Pedidos 
	Values ('P003',9)
GO

--Msg 50000, Level 16, State 1, Procedure Trg_Pedido_Articulos, Line 11 [Batch Start Line 112]
--No hay Existencias.

--(1 row affected)

SELECT * FROM Productos
GO
-- No hace el descuento en productos
-- P003    	Mouse	8	4.50	6.00

SELECT * FROM Pedidos
GO

-- Mal Funcionamiento
-- Hace el pedido
-- 3	P003    	9

DELETE Pedidos
	WHERE Id_Pedido = 3
GO

SELECT * FROM Pedidos
GO

--Id_Pedido	Id_Producto	Cantidad_Pedido
--1				P003    	5


-- Igual anterior
-- Añadir ROLLBACK TRAN
DROP TRIGGER IF EXISTS Trg_Pedido_Articulos
GO
Create or Alter Trigger Trg_Pedido_Articulos
On Pedidos
For Insert
As
		DECLARE @Existencias int
		SELECT  @Existencias=Existencia
		FROM Productos 
		Where Id_Producto = (Select Id_Producto From Inserted)
		IF  @Existencias < (Select Cantidad_Pedido From Inserted)
			BEGIN
				RAISERROR ('No hay Existencias.', -- Message text.  
               16, -- Severity.  
               1 -- State.  
               ); 
			   ROLLBACK TRAN
			   RETURN
			END
		ELSE
			BEGIN	
				Update Productos 
				Set Existencia = Existencia - (Select Cantidad_Pedido From Inserted)
				Where Id_Producto = (Select Id_Producto From Inserted)
			END
Go

SELECT * FROM Productos
GO
-- P003    	Mouse	3	4.50	6.00


-- Se piden mas Existencias de las que hay

Insert Into Pedidos 
	Values ('P003',9)
GO

--Msg 50000, Level 16, State 1, Procedure Trg_Pedido_Articulos, Line 11 [Batch Start Line 165]
--No hay Existencias.
--Msg 3609, Level 16, State 1, Line 166
--The transaction ended in the trigger. The batch has been aborted.

SELECT * FROM Productos
GO

-- P003    	Mouse	8	4.50	6.00

SELECT * FROM Pedidos
GO
-- Sin Pedido

-- Pedido que SI se puede cubrir
-- P002    	Teclados	7	10.00	11.50

Insert Into Pedidos 
	Values ('P002',2)
GO

SELECT * FROM Productos
GO

-- P002    	Teclados	5	10.00	11.50


SELECT * FROM Pedidos
GO

-- 2	P002    	2


--------------------------



-------------------------------------


--  Usar un desencadenador DML AFTER para exigir una regla de negocios entre las tablas PurchaseOrderHeader y Vendor
-- Debido a que las restricciones CHECK solo pueden hacer referencia a las columnas
-- en las que se han definido las restricciones de columna o de tabla, 
-- cualquier restricción entre tablas, en este caso, reglas de negocios, 
-- debe definirse como desencadenadores.

-- En el ejemplo siguiente se crea un desencadenador DML en la base de datos AdventureWorks2017.

-- El desencadenador comprueba que la solvencia del proveedor es satisfactoria (no es 5) 
-- cuando se intenta insertar un nuevo pedido de compra en la tabla PurchaseOrderHeader. 
-- Para obtener la solvencia del proveedor, debe hacerse referencia a la tabla Vendor. 
-- Si la solvencia no es satisfactoria, se obtiene un mensaje y no se ejecuta la inserción.


USE AdventureWorks2017
GO
sp_help "Purchasing.PurchaseOrderHeader"
GO
sp_help "Purchasing.Vendor"
GO	
SELECT * FROM Purchasing.PurchaseOrderHeader
GO
SELECT * FROM Purchasing.Vendor
GO
-- [Purchasing].[PurchaseOrderHeader] PK[PurchaseOrderID] FK[VendorID]
-- [Purchasing].[Vendor] PK [BusinessEntityID]
-- CREANDO DIGRAMA 
-- TABLES Purchasing.PurchaseOrderHeader  Purchasing.Vendor

ALTER AUTHORIZATION ON DATABASE::[AdventureWorks2017] TO sa
GO

SELECT [BusinessEntityID],[Name],[CreditRating],p.[PurchaseOrderID],p.[VendorID]
	FROM Purchasing.PurchaseOrderHeader p JOIN Purchasing.Vendor v
	ON v.BusinessEntityID = p.VendorID
GO
-------------------------------------- SIN CREAR TABLA DE EJEMPLO
-- CREANDO TABLAS DE EJEMPLO

DROP TABLE IF EXISTS Purchasing.PedidosCompra
GO
SELECT *
	INTO Purchasing.PedidosCompra
	FROM Purchasing.PurchaseOrderHeader
GO

SELECT * FROM Purchasing.PedidosCompra
GO

-- This trigger prevents a row from being inserted in the Purchasing.PurchaseOrderHeader 
-- table when the credit rating of the specified vendor is set to 5 (below average).  


-------------USARIAMOS

--IF EXISTS (SELECT *  
--           FROM Purchasing.PurchaseOrderHeader AS p   
--           JOIN inserted AS i   
--           ON p.PurchaseOrderID = i.PurchaseOrderID   
--           JOIN Purchasing.Vendor AS v   
--           ON v.BusinessEntityID = p.VendorID  
--           WHERE v.CreditRating = 5  
          )  
------------------------
DROP TRIGGER IF EXISTS Purchasing.LowCredit
GO
CREATE OR ALTER TRIGGER Purchasing.LowCredit 
ON Purchasing.PedidosCompra
AFTER INSERT
AS  
IF (@@ROWCOUNT= 0)
RETURN;
IF EXISTS (SELECT *  
           FROM Purchasing.PedidosCompra AS p   
           JOIN inserted AS i   
           ON p.PurchaseOrderID = i.PurchaseOrderID   
           JOIN Purchasing.Vendor AS v   
           ON v.BusinessEntityID = p.VendorID  
           WHERE v.CreditRating = 5  
          )  
BEGIN  
		RAISERROR ('A vendor''s credit rating is too low to accept new  
		purchase orders.', 16, 1);  
		ROLLBACK TRANSACTION;  
		RETURN   
END;  
GO  

SELECT * 
FROM Purchasing.PedidosCompra 
ORDER BY VendorID
GO
-- This statement attempts to insert a row into the PurchaseOrderHeader table  
-- for a vendor that has a below average credit rating.  
-- The AFTER INSERT trigger is fired and the INSERT transaction is rolled back.  


SELECT BusinessEntityID,CreditRating FROM Purchasing.Vendor
GO
SELECT BusinessEntityID 
FROM Purchasing.Vendor 
WHERE CreditRating=5
GO

-- ESTOS VENDEDORES TIENEN UN RATING DE 5 (MALO)
--BusinessEntityID
--1550
--1652

SELECT * 
FROM Purchasing.PedidosCompra 
WHERE VendorID IN (1550,1632) 
ORDER BY VendorID
GO

SELECT TOP 3 BusinessEntityID 
FROM Purchasing.Vendor 
WHERE CreditRating!=5
GO

--BusinessEntityID
--1492
--1494
--1496


-- VENDOR 1652   RATING 5 NO SE LE PERMITE
 SELECT [BusinessEntityID],[Name],[CreditRating]
FROM [Purchasing].[Vendor] 
WHERE [BusinessEntityID] = 1652
GO 


INSERT INTO Purchasing.PedidosCompra (RevisionNumber, Status, EmployeeID,  
VendorID, ShipMethodID, OrderDate, ShipDate, SubTotal, TaxAmt, Freight,[TotalDue],[ModifiedDate])  
VALUES (  
2  
,3  
,261  
,1652  
,4  
,GETDATE()  
,GETDATE()  
,44594.55  
,3567.564  
,1114.8638
,13
,GETDATE());  
GO

--Msg 50000, Level 16, State 1, Procedure LowCredit, Line 16 [Batch Start Line 114]
--A vendor's credit rating is too low to accept new  
--		purchase orders.
--Msg 3609, Level 16, State 1, Line 115
--The transaction ended in the trigger. The batch has been aborted.

 -- VENDOR 1492   RATING 5 SE LE PERMITE

SELECT [BusinessEntityID],[Name],[CreditRating]
FROM [Purchasing].[Vendor] 
WHERE [BusinessEntityID] = 1492
GO 

INSERT INTO Purchasing.PedidosCompra (RevisionNumber, Status, EmployeeID,  
VendorID, ShipMethodID, OrderDate, ShipDate, SubTotal, TaxAmt, Freight,[TotalDue],[ModifiedDate])  
VALUES (  
2  
,3  
,261  
,1492 
,4  
,GETDATE()  
,GETDATE()  
,44594.55  
,3567.564  
,1114.8638
,14
,GETDATE());  
GO
--(1 row affected)

SELECT *
FROM Purchasing.PedidosCompra 
order by [ModifiedDate] DESC
--WHERE [ModifiedDate]=GETDATE()
GO

--PurchaseOrderID	RevisionNumber	Status	EmployeeID	VendorID	ShipMethodID	OrderDate	ShipDate	SubTotal	TaxAmt	Freight	TotalDue	ModifiedDate
--4014					2			3			261			1492		4	2021-03-02 17:07:37.720	2021-03-02 17:07:37.720	44594.55	3567.564	1114.8638	14.00	2021-03-02 17:07:37.720

-- VendorID 131313  ERROR??

INSERT INTO Purchasing.PedidosCompra (RevisionNumber, Status, EmployeeID,  
VendorID, ShipMethodID, OrderDate, ShipDate, SubTotal, TaxAmt, Freight,[TotalDue],[ModifiedDate])  
VALUES (  
22  
,3  
,261  
,131313 
,4  
,GETDATE()  
,GETDATE()  
,44594.55  
,3567.564  
,1114.8638
,14
,GETDATE());  
GO

SELECT *
FROM Purchasing.PedidosCompra 
order by [ModifiedDate] DESC
go

-- 4015	22	3	261	131313	4	2021-03-02 17:30:19.647	2021-03-02 17:30:19.647	44594.55	3567.564	1114.8638	14.00	2021-03-02 17:30:19.647

SELECT *
FROM [Purchasing].[Vendor]
WHERE [BusinessEntityID]= 131313
GO

-- INSERTA EN [Purchasing].[PedidosCompra] SIN EXISTIR VENDOR
-- AL CREAR CON SELECT INTO [Purchasing].[PedidosCompra] PERDIO PK Y FK


---------

CREATE OR ALTER TRIGGER Purchasing.CREDITOBAJO 
ON [Purchasing].[PurchaseOrderHeader]
AFTER INSERT
AS  
IF (@@ROWCOUNT= 0)
RETURN;
IF EXISTS (SELECT *  
           FROM [Purchasing].[PurchaseOrderHeader] AS p   
           JOIN inserted AS i   
           ON p.PurchaseOrderID = i.PurchaseOrderID   
           JOIN Purchasing.Vendor AS v   
           ON v.BusinessEntityID = p.VendorID  
           WHERE v.CreditRating = 5  
          )  
BEGIN  
		RAISERROR ('MINORISTA''s credit rating is too low to accept new  
		purchase orders.', 16, 1);  
		ROLLBACK TRANSACTION;  
		RETURN   
END;  
GO 

INSERT INTO [Purchasing].[PurchaseOrderHeader] (RevisionNumber, Status, EmployeeID,  
VendorID, ShipMethodID, OrderDate, ShipDate, SubTotal, TaxAmt, Freight,[TotalDue],[ModifiedDate])  
VALUES (  
2  
,3  
,261  
,1492 
,4  
,GETDATE()  
,GETDATE()  
,44594.55  
,3567.564  
,1114.8638
,GETDATE());  
GO

SELECT *
FROM [Purchasing].[PurchaseOrderHeader]
order by [ModifiedDate] DESC
--WHERE [ModifiedDate]=GETDATE()
GO
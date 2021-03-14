DROP DATABASE IF EXISTS Almacen
GO

CREATE DATABASE Almacen
GO
USE Almacen
GO
USE Almacen;
GO
DROP TABLE IF EXISTS Productos
GO
CREATE TABLE Productos (
	Id_Producto CHAR (8) Primary key NOT NULL,
	Nombreproducto VARCHAR (25) NOT NULL,
	Existencia INT NULL,
	Precio Decimal(10,2) NOT NULL,
	Precioventa Decimal (10,2)
)
GO
INSERT INTO Productos VALUES ('P001','Filtros Pantalla', 5, 10, 12.5)
INSERT INTO Productos VALUES ('P002','Teclado', 7, 10, 11.2)
INSERT INTO Productos VALUES ('P003','Mouse', 8, 4.5, 6)
SELECT * FROM Productos;
GO
DROP TABLE IF EXISTS Pedidos
GO
CREATE TABLE Pedidos (
	Id_Pedido INT IDENTITY,
	Id_Producto CHAR (8) NOT NULL,
	Cantidad_Pedido INT
	CONSTRAINT Pk_Id_Producto FOREIGN KEY (Id_Producto)
	REFERENCES Productos (Id_Producto)
)
GO

INSERT INTO Pedidos
		VALUES ('P003',5)
GO
SELECT * FROM Productos WHERE Productos.Id_Producto = 'P003';
GO
sp_helpconstraint Productos
GO
sp_helpconstraint Pedidos
GO
ALTER TABLE Pedidos
	NOCHECK CONSTRAINT Pk_Id_Producto
GO
ALTER TABLE Pedidos
	CHECK CONSTRAINT Pk_Id_Producto
GO

DROP TRIGGER IF EXISTS trg_Pedido_Articulos
ON Pedidos
FOR INSERT
AS
		UPDATE Productos
		SET Existencia = Existencia - (Select Cantidad_pedido FROM INSERTED)
		WHERE Id_Producto = (SELECT Id_Producto FROM INSERTED)
GO
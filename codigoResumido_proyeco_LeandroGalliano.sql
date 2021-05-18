CREATE DATABASE PanelesSolares_ELGG
USE PanelesSolares_ELGG;
GO
--Realizo la base de datos tomando de referencia el esquema relacional de mi proyecto:
CREATE TABLE Cliente (DNI_cliente NVARCHAR(9) PRIMARY KEY NOT NULL,
nombre_cliente CHAR(20), apellido1_cliente CHAR(20) NOT NULL,
apellido2_cliente CHAR(20) NOT NULL, direccion_cliente VARCHAR(20) ,
telefono_cliente NUMERIC(9) NOT NULL
)
GO
--
CREATE OR ALTER TRIGGER valorUnico ON PanelSolar
FOR INSERT AS IF('%' IN (SELECT tipo_panel FROM PanelSolar WHERE tipo_panel NOT IN ('termico','fotovoltaico')))
BEGIN
ROLLBACK;
PRINT 
--Comprobamos su funcionamiento:
INSERT INTO PanelSolar VALUES ('100N','electrotermico');
GO
--Sólamente puedes insertar dos únicos posibles valores de tipo de panel específicos que debes conocer...
--Msg 3609, Level 16, State 1, Line 31
--The transaction ended in the trigger. The batch has been aborted.
SELECT * FROM PanelSolar;
Go
--
CREATE TABLE PanelSolar (ID_panel VARCHAR(4) PRIMARY KEY NOT NULL,
tipo_panel CHAR(20) NOT NULL
);
GO
--
CREATE TABLE Fotovoltaico (
ID_fotovoltaico VARCHAR(4) NOT NULL FOREIGN KEY REFERENCES PanelSolar(ID_panel),
marca_fotovoltaico CHAR(20),
modelo_fotovoltaico CHAR(20),
potencia_fotovoltaico NUMERIC(4));
GO
--
CREATE TABLE Termico (
ID_termico VARCHAR(4) NOT NULL FOREIGN KEY REFERENCES PanelSolar(ID_panel),
marca_colector CHAR(20), modelo_colector CHAR(20), longitud_tuberia NUMERIC(2));
GO
--
CREATE OR ALTER FUNCTION asignarFotovoltaico (@storeid VARCHAR(4))
RETURNS TABLE
AS RETURN (
SELECT DISTINCT(FIRST_VALUE(ID_panel) OVER(ORDER BY ID_panel)) AS 'ID' FROM PanelSolar
WHERE ID_panel NOT IN (SELECT ID_termico FROM Termico));
GO
--
CREATE OR ALTER TRIGGER auto_Fotovoltaico
ON PanelSolar FOR INSERT 
AS IF('fotovoltaico' IN (SELECT tipo_panel FROM PanelSolar WHERE tipo_panel IN ('fotovoltaico')))
BEGIN -- El WHERE anterior sirve para prevenir el error "Msg 512".
INSERT INTO Fotovoltaico(ID_fotovoltaico) VALUES ((SELECT * FROM asignarFotovoltaico(1)));
--UPDATE Fotovoltaico SET ID_fotovoltaico = (SELECT * FROM asignarFotovoltaico(1));
END
GO
--
CREATE OR ALTER FUNCTION asignarTermico (@storeid VARCHAR(4))
RETURNS TABLE
AS RETURN (
SELECT DISTINCT(FIRST_VALUE(ID_panel) OVER(ORDER BY ID_panel)) AS 'ID' FROM PanelSolar
WHERE ID_panel --NOT IN (SELECT ID_termico FROM Termico)
NOT IN (SELECT ID_fotovoltaico FROM Fotovoltaico)
AND ID_panel IS NOT NULL); -- He agregado ésta línea.
GO
--
CREATE OR ALTER TRIGGER auto_Termico
ON [dbo].[PanelSolar] FOR INSERT 
AS IF('termico' IN (SELECT tipo_panel FROM PanelSolar WHERE tipo_panel IN ('%')))
BEGIN -- El WHERE anterior sirve para prevenir el error "Msg 512".
INSERT INTO Termico(ID_termico) VALUES ((SELECT * FROM asignarTermico(0)));
--UPDATE Termico SET ID_termico = (SELECT * FROM asignarTermico(0)); -- He cambiado INSERT por UPDATE.
END
GO
--
CREATE TABLE pedidos (
ID_pedido INT PRIMARY KEY NOT NULL, -- Ésta clave es un anzuelo para que pueda crearse la tabla.
ID_cliente NVARCHAR(9) FOREIGN KEY REFERENCES Cliente(DNI_cliente) NOT NULL,
ID_compra VARCHAR(4) NOT NULL,
CONSTRAINT compra FOREIGN KEY (ID_compra) REFERENCES PanelSolar(ID_panel),
momentoCompra DATETIME2 GENERATED ALWAYS AS ROW START,
caduca DATETIME2 GENERATED ALWAYS AS ROW END,
PERIOD FOR SYSTEM_TIME (momentoCompra, caduca)
) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.historialPedidos));
--
CREATE OR ALTER FUNCTION pedidoCliente (@storeid INT)
RETURNS TABLE
AS RETURN (
	SELECT DISTINCT(FIRST_VALUE(DNI_Cliente) OVER (ORDER BY DNI_cliente ASC)) AS 'DNI'
	FROM dbo.Cliente WHERE DNI_cliente NOT IN (SELECT ID_cliente FROM pedidos)
	AND DNI_cliente NOT IN (SELECT ID_cliente FROM historialPedidos)
);
--
CREATE OR ALTER TRIGGER clientePedido
ON Cliente FOR INSERT
AS BEGIN
DECLARE @anzuelo INT; SET @anzuelo =(SELECT DISTINCT(FIRST_VALUE(ID_pedido) OVER(ORDER BY ID_pedido ASC))
FROM pedidos)+1;
INSERT INTO pedidos (ID_pedido,ID_cliente,ID_compra) VALUES 
((@anzuelo),(SELECT * FROM pedidoCliente(1)),
(SELECT DISTINCT(FIRST_VALUE(ID_panel) OVER (ORDER BY ID_panel ASC)) FROM PanelSolar
	WHERE tipo_panel IN (SELECT tipoPedido FROM Cliente)
	AND ID_panel NOT IN (SELECT ID_compra FROM pedidos)
	AND ID_panel NOT IN (SELECT ID_compra FROM historialPedidos)
));
END
GO
--
ALTER TABLE Cliente
ADD tipoPedido CHAR(20) NOT NULL; 
--
CREATE OR ALTER TRIGGER pedidoUnico ON Cliente
FOR INSERT AS IF('fotovoltaico'<>(SELECT tipoPedido FROM Cliente WHERE tipoPedido NOT IN ('termico','fotovoltaico')))
BEGIN
ROLLBACK;
PRINT 'Sólamente puedes insertar dos únicos posibles valores de tipo de pedido específicos que debes conocer...';
END
-- He tenido que regresar en scroll y agregar el "tipoPedido" al trigger "clientePedido"...
-- Compruebo otra vez a insertar en cliente:
INSERT INTO Cliente(DNI_cliente,apellido1_cliente,apellido2_cliente,telefono_cliente, tipoPedido)
	VALUES ('12345678A','emiliano','lopez','123456789','fotovoltaico');
GO
--
ALTER TABLE PanelSolar ADD precio_panel MONEY;
GO
--
CREATE OR ALTER TRIGGER calcularPrecio_minum 
ON Fotovoltaico FOR INSERT, UPDATE
AS IF ('minum' = (SELECT modelo_fotovoltaico FROM Fotovoltaico
					WHERE ID_fotovoltaico IN (SELECT DISTINCT(LAST_VALUE(ID_fotovoltaico) 
						OVER (ORDER BY ID_fotovoltaico ASC)))))
BEGIN
UPDATE PanelSolar SET precio_panel = 200
	WHERE ID_panel IN (SELECT DISTINCT(FIRST_VALUE(ID_fotovoltaico) 
						OVER (ORDER BY ID_fotovoltaico ASC)) FROM Fotovoltaico
						WHERE ID_fotovoltaico NOT IN (SELECT ID_compra FROM pedidos));
END
GO
--
CREATE OR ALTER TRIGGER calcularPrecio_maxell
ON Fotovoltaico FOR INSERT, UPDATE
AS IF ('maxell' = (SELECT modelo_fotovoltaico FROM Fotovoltaico
					WHERE ID_fotovoltaico IN (SELECT DISTINCT(LAST_VALUE(ID_fotovoltaico) 
						OVER (ORDER BY ID_fotovoltaico ASC)))))
BEGIN
UPDATE PanelSolar SET precio_panel = 1150
	WHERE ID_panel IN (SELECT DISTINCT(FIRST_VALUE(ID_fotovoltaico) 
						OVER (ORDER BY ID_fotovoltaico ASC)) FROM Fotovoltaico
						WHERE ID_fotovoltaico NOT IN (SELECT ID_compra FROM pedidos));
END
GO
--
CREATE OR ALTER TRIGGER calcularPrecio_seriem
ON Termico FOR INSERT, UPDATE
AS IF ('seriem' = (SELECT modelo_colector FROM Termico
					WHERE ID_termico IN (SELECT DISTINCT(LAST_VALUE(ID_termico) 
						OVER (ORDER BY ID_termico ASC)))))
BEGIN
UPDATE PanelSolar SET precio_panel = 490
	WHERE ID_panel IN (SELECT DISTINCT(FIRST_VALUE(ID_termico) 
						OVER (ORDER BY ID_termico ASC)) FROM Termico
						WHERE ID_termico NOT IN (SELECT ID_compra FROM pedidos));
END
GO
--
CREATE OR ALTER TRIGGER calcularPrecio_simetra
ON Termico FOR INSERT, UPDATE
AS IF ('simetra' = (SELECT modelo_colector FROM Termico
					WHERE ID_termico IN (SELECT DISTINCT(LAST_VALUE(ID_termico) 
						OVER (ORDER BY ID_termico ASC)))))
BEGIN
UPDATE PanelSolar SET precio_panel = 1300
	WHERE ID_panel IN (SELECT DISTINCT(FIRST_VALUE(ID_termico) 
						OVER (ORDER BY ID_termico ASC)) FROM Termico
						WHERE ID_termico NOT IN (SELECT ID_compra FROM pedidos));
END
GO
--

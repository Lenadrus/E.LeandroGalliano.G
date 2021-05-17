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
CREATE TABLE PanelSolar (ID_panel VARCHAR(4) PRIMARY KEY NOT NULL,
tipo_panel CHAR(20) NOT NULL
);
GO
--
/*
El atributo "tipo_panel" de la entidad "PanelSolar" sólo puede obtener dos posibles valores
que el usuario debería conocer. Éstos son: 'fotovoltaico' o 'termico', todo en minúsculas.
Si el atributo "tipo_panel" recibe un valor distinto de los mencionados, salta el trigger
que ejecuta un ROLLBACK:
*/
CREATE OR ALTER TRIGGER valorUnico ON PanelSolar
FOR INSERT AS IF('fotovoltaico'<>(SELECT tipo_panel FROM PanelSolar WHERE tipo_panel NOT IN ('termico','fotovoltaico')))
BEGIN
ROLLBACK;
PRINT 'Sólamente puedes insertar dos únicos posibles valores de tipo de panel específicos que debes conocer...';
END
GO
--Comprobamos su funcionamiento:
INSERT INTO PanelSolar VALUES ('100N','electrotermico');
GO
--Sólamente puedes insertar dos únicos posibles valores de tipo de panel específicos que debes conocer...
--Msg 3609, Level 16, State 1, Line 31
--The transaction ended in the trigger. The batch has been aborted.
SELECT * FROM PanelSolar;
Go
--
--ID_panel	tipo_panel
/*
Como se muestra en el esquema relacional, PanelSolar es una Entidad que después bifurca en dos
subentidades o entidades débiles; Fotovoltaico y Termico.

La tabla "PanelSolar" sólo tiene dos atributos porque su clave primaria servirá como clave ajena
en otras dos tablas que la necesitarán: "Fotovoltaico" y "Térmico". El atributo "tipo_panel"
se utilizará en un trigger cuya tarea será la de prevenir que las claves ajenas coincidan:

La ID del panel solar no podrá coincidir como clave ajena en las sub-entidades
"Fotovoltaico" y "Térmico". Es decir, un coche diésel y otro coche eléctrico no pueden tener 
la misma matrícula... 
*/
-- Procedo a crear las sub-entidades y posteriormente el trigger mencionado: 
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
--Trigger para diferenciar el Fotovoltaico del Termico:
CREATE OR ALTER TRIGGER dbo.diferenciarPanel_fotovoltaico ON dbo.Termico
FOR INSERT AS IF ('fotovoltaico'=(SELECT tipo_panel FROM PanelSolar WHERE ID_panel IN (SELECT ID_termico FROM Termico)))
BEGIN
DELETE FROM Termico WHERE ID_termico = (SELECT ID_panel FROM PanelSolar WHERE tipo_panel LIKE 'fotovoltaico');
PRINT 'No es posible insertar el ID de un panel fotovoltaico en la tabla de un panel térmico...';
END
GO
-- Lo compruebo:
INSERT INTO PanelSolar VALUES('100A','fotovoltaico');
Go
INSERT INTO PanelSolar VALUES('100M','termico');
GO
SELECT * FROM PanelSolar;
INSERT INTO Termico(ID_termico) VALUES ((SELECT ID_panel FROM PanelSolar WHERE tipo_panel LIKE 'fotovoltaico'));
GO
--(1 row affected)
--No es posible insertar el ID de un panel fotovoltaico en la tabla de un panel térmico...
--
--(1 row affected)
SELECT * FROM Termico
--ID_termico	marca_colector	modelo_colector	longitud_tuberia
DELETE FROM Termico;DELETE FROM PanelSolar; -- Para continuar con pruebas...
-- Ahora hago lo mismo pero con el panel térmico:
CREATE OR ALTER TRIGGER dbo.diferenciarPanel_termico ON dbo.Fotovoltaico
FOR INSERT AS IF ('termico'=(SELECT tipo_panel FROM PanelSolar WHERE ID_panel IN (SELECT ID_fotovoltaico FROM Fotovoltaico)))
BEGIN
DELETE FROM Fotovoltaico WHERE ID_fotovoltaico = (SELECT ID_panel FROM PanelSolar WHERE tipo_panel LIKE 'termico');
PRINT 'No es posible insertar el ID de un panel termico en la tabla de un panel fotovoltaico...';
END
GO
-- Lo compruebo:
INSERT INTO PanelSolar VALUES('100A','fotovoltaico');
Go
INSERT INTO PanelSolar VALUES('100M','termico');
GO
SELECT * FROM PanelSolar;
INSERT INTO Fotovoltaico(ID_fotovoltaico) VALUES ((SELECT ID_panel FROM PanelSolar WHERE tipo_panel LIKE 'termico'));
GO
--(1 row affected)
--No es posible insertar el ID de un panel termico en la tabla de un panel fotovoltaico...
--
--(1 row affected)
SELECT * FROM Fotovoltaico
--ID_fotovoltaico	marca_fotovoltaico	modelo_fotovoltaico	potencia_fotovoltaico
--
DELETE FROM Fotovoltaico;DELETE FROM Termico;DELETE FROM PanelSolar;-- Para continuar con pruebas...
/*
Ahora tengo que conseguir que, al insertar un ID de panel de un tipo determinado
en la tabla "PanelSolar", se inserte automáticamente en las sub-entidades correspondientes.
Para lo que me valdré de un par triggers más...
Para que el siguiente trigger funcione, debo crear una función que detecte
que lo que voy a insertar no se encuentra ya en la sub-entidad correspondiente.
*/
--
CREATE OR ALTER FUNCTION asignarFotovoltaico (@storeid VARCHAR(4))
RETURNS TABLE
AS RETURN (
SELECT DISTINCT(FIRST_VALUE(ID_panel) OVER(ORDER BY ID_panel)) AS 'ID' FROM PanelSolar
WHERE ID_panel NOT IN (SELECT ID_fotovoltaico FROM Fotovoltaico));
GO
--
DELETE FROM Fotovoltaico;DELETE FROM Termico;DELETE FROM PanelSolar;-- Por si me hace falta...
--Ésta función previene que inserte dos veces el mismo ID en la sub-entidad correspondiente
--
--Procedo a crear el trigger mencionado en el anterior comentario de líneas múltiples:
CREATE OR ALTER TRIGGER auto_Fotovoltaico
ON PanelSolar FOR INSERT 
AS --IF('fotovoltaico' = (SELECT tipo_panel FROM PanelSolar WHERE tipo_panel IN ('%')))
BEGIN -- El WHERE anterior sirve para prevenir el error "Msg 512".
INSERT INTO Fotovoltaico(ID_fotovoltaico) VALUES (
(SELECT * FROM asignarFotovoltaico(1)));
END
GO
-- Lo compruebo:
SELECT * FROM PanelSolar;
INSERT INTO PanelSolar VALUES ('A001','fotovoltaico');
GO
--
--(1 row affected)
--
--(1 row affected)
SELECT * FROM Fotovoltaico;
Go
--ID_fotovoltaico	marca_fotovoltaico	modelo_fotovoltaico	potencia_fotovoltaico
--A001	NULL	NULL	NULL
--
--Procedo a crear un la función y el trigger correspondiente para el Termico:
INSERT INTO PanelSolar VALUES ('A002','fotovoltaico');
GO
--Msg 512, Level 16, State 1, Procedure diferenciarPanel_termico, Line 2 [Batch Start Line 151]
--Subquery returned more than 1 value. This is not permitted when the subquery follows =, !=, <, <= , >, >= or when the subquery is used as an expression.
--The statement has been terminated.
/*
Ahora el problema se haya en el trigger "diferenciarPanel_termico". Ocurrirá lo mismo con el
correspondiente al Fotovoltaico... así que traré de solucionar el problema modificando ese trigger...
*/
CREATE OR ALTER TRIGGER dbo.diferenciarPanel_termico ON dbo.Fotovoltaico
FOR INSERT AS IF ('termico' IN (SELECT tipo_panel FROM PanelSolar WHERE ID_panel IN (SELECT ID_fotovoltaico FROM Fotovoltaico)))
BEGIN
DELETE FROM Fotovoltaico WHERE ID_fotovoltaico IN (SELECT ID_panel FROM PanelSolar WHERE tipo_panel LIKE 'termico');
PRINT 'No es posible insertar el ID de un panel termico en la tabla de un panel fotovoltaico...';
END
GO
-- Intento insertar de nuevo:
INSERT INTO PanelSolar VALUES ('A002','fotovoltaico');
GO
--(1 row affected)
SELECT * FROM Fotovoltaico;
GO
--ID_fotovoltaico	marca_fotovoltaico	modelo_fotovoltaico	potencia_fotovoltaico
--A001	NULL	NULL	NULL
--A002	NULL	NULL	NULL
/*
Simplemente cambié '=' por 'IN'. Realizo lo mismo para el diferenciador del panel fotovoltaico:
*/
--
CREATE OR ALTER TRIGGER dbo.diferenciarPanel_fotovoltaico ON dbo.Termico
FOR INSERT AS IF ('fotovoltaico' IN (SELECT tipo_panel FROM PanelSolar WHERE ID_panel IN (SELECT ID_termico FROM Termico)))
BEGIN
DELETE FROM Termico WHERE ID_termico IN (SELECT ID_panel FROM PanelSolar WHERE tipo_panel LIKE 'fotovoltaico');
PRINT 'No es posible insertar el ID de un panel fotovoltaico en la tabla de un panel térmico...';
END
GO
--
/*
Procedo a hacer lo mismo para el panel Termico. Las funciones y el trigger:
*/
CREATE OR ALTER FUNCTION asignarTermico (@storeid VARCHAR(4))
RETURNS TABLE
AS RETURN (
SELECT DISTINCT(FIRST_VALUE(ID_panel) OVER(ORDER BY ID_panel)) AS 'ID' FROM PanelSolar
WHERE ID_panel NOT IN (SELECT ID_termico FROM Termico)
AND ID_panel NOT IN (SELECT ID_fotovoltaico FROM Fotovoltaico));
GO
--
CREATE OR ALTER TRIGGER auto_Termico
ON PanelSolar FOR INSERT 
AS --IF('termico' IN (SELECT tipo_panel FROM PanelSolar WHERE tipo_panel IN ('%')))
BEGIN -- El WHERE anterior sirve para prevenir el error "Msg 512".
INSERT INTO Termico(ID_termico) VALUES ((SELECT * FROM asignarTermico(0)));
END
GO
/*
Los IF de los triggers "auto_Termico" y "auto_Fotovoltaico" sobran. Ya que de ello se encargan
los triggers "diferenciadores".
*/
--
-- Lo compruebo:
SELECT * FROM PanelSolar;
Go
--ID_panel	tipo_panel
--100A	fotovoltaico
INSERT INTO PanelSolar VALUES ('M001','termico');
GO
--(1 row affected)
--No es posible insertar el ID de un panel termico en la tabla de un panel fotovoltaico...

--(1 row affected)

--(1 row affected)

--(1 row affected)
SELECT * FROM Termico;
GO
--ID_termico	marca_colector	modelo_colector	longitud_tuberia
--M001	NULL	NULL	NULL
INSERT INTO PanelSolar VALUES ('M002','termico');
SELECT * FROM Termico;
GO
--ID_termico	marca_colector	modelo_colector	longitud_tuberia
--M001	NULL	NULL	NULL
--M002	NULL	NULL	NULL
--
--Compruebo que los triggers "diferenciadores" han funcionado satisfactoriamente:
SELECT * FROM Fotovoltaico;
Go
--ID_fotovoltaico	marca_fotovoltaico	modelo_fotovoltaico	potencia_fotovoltaico
--A001	NULL	NULL	NULL
--A002	NULL	NULL	NULL
/*
Ahora paso a los pedidos. Las compras serán guardadas como pedidos.
Crearé una tabla temporal "pedidos" que guarde el número de pedido, el DNI del cliente, el ID del panel,
el momento de la compra y la caducidad con la que funciona la tabla temporal.
El ID del panel será el ID de compra en la tabla "pedidos".

Ésta tabla temporal en realidad es una relación en el grafo relacional.

En ésta tabla se conoce la relación entre el Cliente y el PanelSolar. Es aquí donde se establece
la relación "un cliente a varios paneles".
*/
CREATE TABLE pedidos (
ID_pedido INT PRIMARY KEY NOT NULL, -- Ésta clave es un anzuelo para que pueda crearse la tabla.
ID_cliente NVARCHAR(9) FOREIGN KEY REFERENCES Cliente(DNI_cliente) NOT NULL,
ID_compra VARCHAR(4) NOT NULL,
CONSTRAINT compra FOREIGN KEY (ID_compra) REFERENCES PanelSolar(ID_panel),
momentoCompra DATETIME2 GENERATED ALWAYS AS ROW START,
caduca DATETIME2 GENERATED ALWAYS AS ROW END,
PERIOD FOR SYSTEM_TIME (momentoCompra, caduca)
) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.historialPedidos));
/*
Ahora tengo que crear un trigger que que inserte valores en la tabla pedidos
cuando se realice una compra. Una compra se realiza cuando se insertan valores a la tabla
"Cliente":
Creando otro trigger que sirva para evitar que distintos ID de cliente coincidan con el mismo ID de panel.
*/
--
CREATE OR ALTER FUNCTION pedidoCliente (@storeid INT)
RETURNS TABLE
AS RETURN (
	SELECT DISTINCT(FIRST_VALUE(DNI_Cliente) OVER (ORDER BY DNI_cliente ASC)) AS 'DNI'
	FROM dbo.Cliente WHERE DNI_cliente NOT IN (SELECT ID_cliente FROM pedidos)
	AND DNI_cliente NOT IN (SELECT ID_cliente FROM historialPedidos)
);
/*
Ésta función inserta el DNI de clientes en la tabla "pedidos" que no se encuentra en la tabla "pedidos".
Será utilizada en el trigger:
*/
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
/*
Obviamente éste trigger se activa en cada inserción de valores en la tabla Cliente. Razón por la que 
he hecho "DISTINCT(FIRST_VALUE())". Además de que sólo quiero obtener un único valor.
*/
-- Lo compruebo:
SELECT * FROM PanelSolar;
--ID_panel	tipo_panel
--A001	fotovoltaico        
--A002	fotovoltaico        
--M001	termico             
--M002	termico             
SELECT * FROM Cliente; --Vacío.
INSERT INTO Cliente(DNI_cliente,apellido1_cliente,apellido2_cliente,telefono_cliente)
	VALUES ('12345678A','emiliano','lopez','123456789');
--GO
--Msg 208, Level 16, State 1, Procedure clientePedido, Line 5 [Batch Start Line 301]
--Invalid object name 'pedidoPanel'.
/*
Aquel objeto era una función que obtenía un ID de panel. Decidí eliminarla, por eso se retorna éste error.
Voy a solucionar el problema alterando la tabla "Cliente", agregando una nueva columna "tipoPedido",
que sólo podrá obtener dos valores, y se servirá de una copia del trigger "valorUnico" ya creado para poder 
funcionar.
*/
--
ALTER TABLE Cliente
ADD tipoPedido CHAR(20) NOT NULL; 
SELECT * FROM Cliente;
--DNI_cliente	nombre_cliente	apellido1_cliente	apellido2_cliente	direccion_cliente	telefono_cliente	tipoPedido
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
SELECT * FROM pedidos;
--ID_pedido	ID_cliente	ID_compra	momentoCompra	caduca
--	1	     12345678A	A001	     2021-05-17     05:13:38.6068798	9999-12-31 23:59:59.9999999
/*
Ya va funcionando el trigger y la base de datos como la quería encaminar.

Ahora voy a agregar un nuevo elemento. El que controla el precio de los paneles.
Para ésto anotaré un conjunto de modelos y marcas de panel ficticios. Dos de cada tipo de panel.

Modelo: Foseuz (fotovoltaico),  Poseifen (termico).

Marcas: (Minum, Maxell) [Foseuz]. Seriem, Simetra [Poseifen].

Ahora, crearé un trigger que, en función del modelo de panel, se establezca uno u otro precio.
Éste trigger será "FOR INSERT, UPDATE" y actualizará la columna "precio" cuando se detecte el evento.

"Minum" de "mínimo", los fotovoltaicos "Minum" tienen una potencia máxima de 500 watios,
éstos cuestan un total de 200€.
"Maxell" de "Maximum Cells" tienen una potencia máxima de 3250W. Éstos tienen un coste de 1300€.
*/
ALTER TABLE PanelSolar ADD precio_panel MONEY;
GO
--
CREATE OR ALTER TRIGGER calculo_precio_fotovoltaico 
ON Fotovoltaico
FOR INSERT
AS IF(
	'minum' IN (SELECT DISTINCT(modelo_fotovoltaico) FROM Fotovoltaico
	JOIN PanelSolar ON (PanelSolar.ID_panel=Fotovoltaico.ID_fotovoltaico)
	WHERE modelo_fotovoltaico IS NOT NULL
	AND tipo_panel IN (SELECT tipoPedido FROM Cliente WHERE tipoPedido IN ('fotovoltaico'))
))
BEGIN
UPDATE PanelSolar 
	SET precio_panel = 200.0 FROM PanelSolar
	WHERE ID_panel IN (SELECT DISTINCT(ID_panel) FROM PanelSolar JOIN Fotovoltaico ON (ID_panel=ID_fotovoltaico)
		WHERE ID_panel IN (SELECT DISTINCT(FIRST_VALUE(ID_compra) OVER(ORDER BY ID_compra)) 
							FROM pedidos JOIN PanelSolar ON (ID_compra=ID_panel)
							AND ID_compra NOT IN (SELECT ID_fotovoltaico FROM Fotovoltaico)));
END
ELSE IF(
	'maxell' IN (SELECT DISTINCT(modelo_fotovoltaico) FROM Fotovoltaico
	JOIN PanelSolar ON (PanelSolar.ID_panel=Fotovoltaico.ID_fotovoltaico)
	WHERE modelo_fotovoltaico IS NOT NULL
	AND tipo_panel IN (SELECT tipoPedido FROM Cliente WHERE tipoPedido IN ('fotovoltaico'))
))
BEGIN
UPDATE PanelSolar 
	SET precio_panel = 1300.0 FROM PanelSolar
	WHERE ID_panel IN (SELECT DISTINCT(ID_panel) FROM PanelSolar JOIN Fotovoltaico ON (ID_panel=ID_fotovoltaico)
		WHERE ID_panel IN (SELECT DISTINCT(FIRST_VALUE(ID_compra) OVER(ORDER BY ID_compra)) 
							FROM pedidos JOIN PanelSolar ON (ID_compra=ID_panel)
							AND ID_compra NOT IN (SELECT ID_fotovoltaico FROM Fotovoltaico)));
END
GO
--
/*Ahora hay que hacer lo propio con los térmicos.

Los colectores "Seriem" son tipos de colectores cuyos tubos van en serie. Mientras
que los "Simetra" son tipos de colectores cuyos tubos van en paralelo.

Los colectores en paralelo son más caros que los colectores en serie porque tienen más
poder de absorción del calor.
Un colector "Seriem" cuesta 490€. Un colector "Simetra" cuesta 1150€.
*/
CREATE OR ALTER TRIGGER calculo_precio_termico
ON Fotovoltaico
FOR INSERT
AS IF(
	'seriem' IN (SELECT DISTINCT(modelo_colector) FROM Termico
	JOIN PanelSolar ON (ID_panel=ID_termico)
	WHERE modelo_colector IS NOT NULL
	AND tipo_panel IN (SELECT tipoPedido FROM Cliente WHERE tipoPedido IN ('termico'))
))
BEGIN
UPDATE PanelSolar 
	SET precio_panel = 490.0 FROM PanelSolar
	WHERE ID_panel IN (SELECT DISTINCT(ID_panel) FROM PanelSolar JOIN Termico ON (ID_panel=ID_termico)
		WHERE ID_panel IN (SELECT DISTINCT(FIRST_VALUE(ID_compra) OVER(ORDER BY ID_compra)) 
							FROM pedidos JOIN PanelSolar ON (ID_compra=ID_panel)
							AND ID_compra NOT IN (SELECT ID_termico FROM Termico)));
END
ELSE IF(
	'simetra' IN (SELECT DISTINCT(modelo_colector) FROM Termico
	JOIN PanelSolar ON (ID_panel=ID_termico)
	WHERE modelo_colector IS NOT NULL
	AND tipo_panel IN (SELECT tipoPedido FROM Cliente WHERE tipoPedido IN ('termico'))
))
BEGIN
UPDATE PanelSolar 
	SET precio_panel = 1150.0 FROM PanelSolar
	WHERE ID_panel IN (SELECT DISTINCT(ID_panel) FROM PanelSolar JOIN Termico ON (ID_panel=ID_termico)
		WHERE ID_panel IN (SELECT DISTINCT(FIRST_VALUE(ID_compra) OVER(ORDER BY ID_compra)) 
							FROM pedidos JOIN PanelSolar ON (ID_compra=ID_panel)
							AND ID_compra NOT IN (SELECT ID_termico FROM Termico)));
END
GO
/*
Ahora sólo tengo que asegurar que los atributos "modelo_fotovoltaico" y "modelo_colector"
sólo puedan obtener valores únicos que el usuario administrador debe conocer. En éste caso, los
modelos ficticios de las marcas ficticias.
*/
CREATE OR ALTER TRIGGER modelo_unico_fotovoltaico
ON Fotovoltaico
FOR INSERT
AS IF ('minum')<>(SELECT modelo_fotovoltaico 
					FROM Fotovoltaico WHERE modelo_fotovoltaico IN ('%'))
BEGIN
ROLLBACK;PRINT 'No puedes insertar un modelo de panel que no conozca la base de datos...';
END
ELSE IF ('maxell')<>(SELECT modelo_fotovoltaico 
					FROM Fotovoltaico WHERE modelo_fotovoltaico IN ('%'))
BEGIN
ROLLBACK;PRINT 'No puedes insertar un modelo de panel que no conozca la base de datos...';
END
GO
-- Lo mismo para los térmicos:
CREATE OR ALTER TRIGGER modelo_unico_termico
ON Termico
FOR INSERT
AS IF ('seriem')<>(SELECT modelo_colector 
					FROM Termico WHERE modelo_colector IN ('%'))
BEGIN
ROLLBACK;PRINT 'No puedes insertar un modelo de panel que no conozca la base de datos...';
END
ELSE IF ('simetra')<>(SELECT modelo_colector 
					FROM Termico WHERE modelo_colector IN ('%'))
BEGIN
ROLLBACK;PRINT 'No puedes insertar un modelo de panel que no conozca la base de datos...';
END
GO
--
DELETE FROM Termico;DELETE FROM Fotovoltaico;DELETE FROM Cliente;DELETE FROM pedidos;
DELETE FROM PanelSolar;
--Realizo pruebas:
INSERT INTO PanelSolar(ID_panel,tipo_panel) VALUES ('A001','fotovoltaico');
--Msg 515, Level 16, State 2, Procedure auto_Termico, Line 6 [Batch Start Line 471]
--Cannot insert the value NULL into column 'ID_termico', table 'PanelesSolares_ELGG.dbo.Termico'; column does not allow nulls. INSERT fails.

-- Hay un problema en "auto_Termico"...
CREATE OR ALTER TRIGGER auto_Termico
ON PanelSolar FOR INSERT 
AS --IF('termico' IN (SELECT tipo_panel FROM PanelSolar WHERE tipo_panel IN ('%')))
BEGIN -- El WHERE anterior sirve para prevenir el error "Msg 512".
INSERT INTO Termico(ID_termico) VALUES ((SELECT * FROM asignarTermico(0)));
END
GO
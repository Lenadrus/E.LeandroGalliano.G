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
El atributo "tipo_panel" de la entidad "PanelSolar" s�lo puede obtener dos posibles valores
que el usuario deber�a conocer. �stos son: 'fotovoltaico' o 'termico', todo en min�sculas.
Si el atributo "tipo_panel" recibe un valor distinto de los mencionados, salta el trigger
que ejecuta un ROLLBACK:
*/
CREATE OR ALTER TRIGGER valorUnico ON PanelSolar
FOR INSERT AS IF('%' IN (SELECT tipo_panel FROM PanelSolar WHERE tipo_panel NOT IN ('termico','fotovoltaico')))
BEGIN
ROLLBACK;
PRINT 
--Comprobamos su funcionamiento:
INSERT INTO PanelSolar VALUES ('100N','electrotermico');
GO
--S�lamente puedes insertar dos �nicos posibles valores de tipo de panel espec�ficos que debes conocer...
--Msg 3609, Level 16, State 1, Line 31
--The transaction ended in the trigger. The batch has been aborted.
SELECT * FROM PanelSolar;
Go
--
--ID_panel	tipo_panel
/*
Como se muestra en el esquema relacional, PanelSolar es una Entidad que despu�s bifurca en dos
subentidades o entidades d�biles; Fotovoltaico y Termico.

La tabla "PanelSolar" s�lo tiene dos atributos porque su clave primaria servir� como clave ajena
en otras dos tablas que la necesitar�n: "Fotovoltaico" y "T�rmico". El atributo "tipo_panel"
se utilizar� en un trigger cuya tarea ser� la de prevenir que las claves ajenas coincidan:

La ID del panel solar no podr� coincidir como clave ajena en las sub-entidades
"Fotovoltaico" y "T�rmico". Es decir, un coche di�sel y otro coche el�ctrico no pueden tener 
la misma matr�cula... 
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

/*
Ahora tengo que conseguir que, al insertar un ID de panel de un tipo determinado
en la tabla "PanelSolar", se inserte autom�ticamente en las sub-entidades correspondientes.
Para lo que me valdr� de un par triggers m�s...
Para que el siguiente trigger funcione, debo crear una funci�n que detecte
que lo que voy a insertar no se encuentra ya en la sub-entidad correspondiente.
*/
--
CREATE OR ALTER FUNCTION asignarFotovoltaico (@storeid VARCHAR(4))
RETURNS TABLE
AS RETURN (
SELECT DISTINCT(FIRST_VALUE(ID_panel) OVER(ORDER BY ID_panel)) AS 'ID' FROM PanelSolar
WHERE ID_panel NOT IN (SELECT ID_termico FROM Termico));
GO
--
DELETE FROM Fotovoltaico;DELETE FROM Termico;DELETE FROM PanelSolar;-- Por si me hace falta...
--�sta funci�n previene que inserte dos veces el mismo ID en la sub-entidad correspondiente
--
--Procedo a crear el trigger mencionado en el anterior comentario de l�neas m�ltiples:
CREATE OR ALTER TRIGGER auto_Fotovoltaico
ON PanelSolar FOR INSERT 
AS IF('fotovoltaico' IN (SELECT tipo_panel FROM PanelSolar WHERE tipo_panel IN ('fotovoltaico')))
BEGIN -- El WHERE anterior sirve para prevenir el error "Msg 512".
INSERT INTO Fotovoltaico(ID_fotovoltaico) VALUES ((SELECT * FROM asignarFotovoltaico(1)));
--UPDATE Fotovoltaico SET ID_fotovoltaico = (SELECT * FROM asignarFotovoltaico(1));
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
WHERE ID_panel --NOT IN (SELECT ID_termico FROM Termico)
NOT IN (SELECT ID_fotovoltaico FROM Fotovoltaico)
AND ID_panel IS NOT NULL); -- He agregado �sta l�nea.
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
Ahora paso a los pedidos. Las compras ser�n guardadas como pedidos.
Crear� una tabla temporal "pedidos" que guarde el n�mero de pedido, el DNI del cliente, el ID del panel,
el momento de la compra y la caducidad con la que funciona la tabla temporal.
El ID del panel ser� el ID de compra en la tabla "pedidos".

�sta tabla temporal en realidad es una relaci�n en el grafo relacional.

En �sta tabla se conoce la relaci�n entre el Cliente y el PanelSolar. Es aqu� donde se establece
la relaci�n "un cliente a varios paneles".
*/
CREATE TABLE pedidos (
ID_pedido INT PRIMARY KEY NOT NULL, -- �sta clave es un anzuelo para que pueda crearse la tabla.
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
�sta funci�n inserta el DNI de clientes en la tabla "pedidos" que no se encuentra en la tabla "pedidos".
Ser� utilizada en el trigger:
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
Obviamente �ste trigger se activa en cada inserci�n de valores en la tabla Cliente. Raz�n por la que 
he hecho "DISTINCT(FIRST_VALUE())". Adem�s de que s�lo quiero obtener un �nico valor.
*/
-- Lo compruebo:
SELECT * FROM PanelSolar;
--ID_panel	tipo_panel
--A001	fotovoltaico        
--A002	fotovoltaico        
--M001	termico             
--M002	termico             
SELECT * FROM Cliente; --Vac�o.
INSERT INTO Cliente(DNI_cliente,apellido1_cliente,apellido2_cliente,telefono_cliente)
	VALUES ('12345678A','emiliano','lopez','123456789');
--GO
--Msg 208, Level 16, State 1, Procedure clientePedido, Line 5 [Batch Start Line 301]
--Invalid object name 'pedidoPanel'.
/*
Aquel objeto era una funci�n que obten�a un ID de panel. Decid� eliminarla, por eso se retorna �ste error.
Voy a solucionar el problema alterando la tabla "Cliente", agregando una nueva columna "tipoPedido",
que s�lo podr� obtener dos valores, y se servir� de una copia del trigger "valorUnico" ya creado para poder 
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
PRINT 'S�lamente puedes insertar dos �nicos posibles valores de tipo de pedido espec�ficos que debes conocer...';
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
Ya va funcionando el trigger y la base de datos como la quer�a encaminar.

Ahora voy a agregar un nuevo elemento. El que controla el precio de los paneles.
Para �sto anotar� un conjunto de modelos y marcas de panel ficticios. Dos de cada tipo de panel.

Modelo: Foseuz (fotovoltaico),  Poseifen (termico).

Marcas: (Minum, Maxell) [Foseuz]. Seriem, Simetra [Poseifen].

Ahora, crear� un trigger que, en funci�n del modelo de panel, se establezca uno u otro precio.
�ste trigger ser� "FOR INSERT, UPDATE" y actualizar� la columna "precio" cuando se detecte el evento.

"Minum" de "m�nimo", los fotovoltaicos "Minum" tienen una potencia m�xima de 500 watios,
�stos cuestan un total de 200�.
"Maxell" de "Maximum Cells" tienen una potencia m�xima de 3250W. �stos tienen un coste de 1150�.

"Seriem" , "de serie". Son colectores m�s baratos que los colectores en paralelo porque
tienen un poder de absorci�n del calor menor que los paralelos. Cuestan un total de 490�.
Los paralelos "Simetra", cuestan un total de 1300�
*/
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
DELETE FROM Termico;DELETE FROM Fotovoltaico;DELETE FROM PanelSolar;DELETE FROM Cliente;
GO
INSERT INTO PanelSolar(ID_panel,tipo_panel) VALUES ('A001','fotovoltaico');
GO
SELECT * FROM Fotovoltaico;
GO
UPDATE Fotovoltaico SET modelo_fotovoltaico = 'minum';
GO
SELECT * FROM PanelSolar;
--ID_panel	tipo_panel	precio_panel
--A001	fotovoltaico        	200,00
--
--Lo mismo para todo lo dem�s:
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
--Lo compruebo:
DELETE FROM Termico;DELETE FROM Fotovoltaico;DELETE FROM PanelSolar;
SELECT * FROM PanelSolar;
GO
INSERT INTO PanelSolar(ID_panel,tipo_panel) VALUES ('A001','fotovoltaico');
GO
SELECT * FROM Termico;SELECT * FROM Fotovoltaico;
UPDATE Fotovoltaico SET modelo_fotovoltaico = 'minum';
--ID_panel	tipo_panel	precio_panel
--A001	fotovoltaico        	200,00
--
/*
Falta establecer la relaci�n de los fotovoltaicos con las bater�as y la relaci�n
de los coelctores con los acumuladores y �stos con las calderas.
*/
-- Bater�as:
CREATE TABLE bateria (
ID_bateria VARCHAR(5) PRIMARY KEY NOT NULL,
enchufe VARCHAR(4), -- Ser� el valor del Fotovoltaico al que refencia.
tipo_bateria CHAR(20),
precio_bateria MONEY);
--
);
END
GO
-- Creo un trigger que controle que el atributo "enchufe" �nicamente pueda llevar
-- un valor igual a una clave de la entidad Fotovoltaico.
-- El uso de las bater�as es siempre opcional. Por eso no se establece ninguna relaci�n
-- de clave for�nea con Fotovoltaico. Adem�s de que Fotovoltaico no dispone de clave principal.
CREATE OR ALTER TRIGGER alimentacion ON bateria
FOR INSERT,UPDATE 
AS IF('%' <> (SELECT enchufe FROM bateria 
		WHERE enchufe IN (SELECT ID_fotovoltaico FROM Fotovoltaico)))
BEGIN
PRINT 'S�lo puedes insertar el valor del ID del panel Fotovoltaico al que quieres relacionar �sta bater�a...';
DELETE FROM bateria WHERE enchufe NOT IN (
	SELECT ID_fotovoltaico FROM Fotovoltaico)
END
Go
SELECT * FROM Fotovoltaico;
-- Lo compruebo:
INSERT INTO bateria(ID_bateria, enchufe)
VALUES ('P0001','A001');
SELECT * FROM bateria;
--ID_bateria	enchufe	tipo_bateria	precio_bateria
--P0001	A001	NULL	NULL
-- Ahora intendo insertar un valor distinto:
INSERT INTO bateria(ID_bateria, enchufe)
VALUES ('P0002','M001');
--S�lo puedes insertar el valor del ID del panel Fotovoltaico al que quieres relacionar �sta bater�a...

--(1 row affected)

--(1 row affected)
/*
Como establecido en el enunciado, s�lo hay dos tipos de bater�as. Las de litio y las de plomo-�cido.
El precio se establecer� en funci�n al tipo de bater�a.
As� que tengo que crear dos triggers m�s: "diferenciar_tipo_bateria" y "establecer_precio_bateria".
*/
CREATE OR ALTER TRIGGER diferenciar_plomo
ON bateria
FOR INSERT, UPDATE
AS IF ('plomo' NOT IN (SELECT DISTINCT(tipo_bateria) FROM bateria WHERE tipo_bateria IS NOT NULL))
BEGIN
PRINT 'S�lo puedes insertar alguno de los valores de tipo de bater�a que debes conocer.';
END
GO
SELECT * FROM bateria;
INSERT INTO bateria(ID_bateria,tipo_bateria) VALUES('P0001','plomo');
SELECT * FROM bateria;
--ID_bateria	enchufe	tipo_bateria	precio_bateria
--P0001	NULL	plomo               	NULL
-- Controlamos el precio de la bater�a de plomo.
-- Las bater�as de plomo-�cido son m�s baratas, porque 
-- se desgastan mucho antes tras varos usos, y tardan m�s en cargar.
CREATE OR ALTER TRIGGER precio_plomo ON bateria
FOR INSERT,UPDATE
AS IF ('plomo' IN (SELECT DISTINCT(tipo_bateria) FROM bateria WHERE tipo_bateria IS NOT NULL))
BEGIN
UPDATE bateria SET precio_bateria = 50
WHERE tipo_bateria LIKE 'plomo';
END
GO
DELETE FROM bateria;
INSERT INTO bateria (ID_bateria,tipo_bateria) VALUES ('P0001','plomo');
SELECT * FROM bateria;
--ID_bateria	enchufe	tipo_bateria	precio_bateria
--P0001	NULL	plomo               	50,00
/*
Lo mismo para las bater�as de litio:
*/
CREATE OR ALTER TRIGGER diferenciar_litio
ON bateria
FOR INSERT, UPDATE
AS IF ('litio' NOT IN (SELECT DISTINCT(tipo_bateria) FROM bateria WHERE tipo_bateria IS NOT NULL))
BEGIN
PRINT 'S�lo puedes insertar alguno de los valores de tipo de bater�a que debes conocer.';
END
GO
--
CREATE OR ALTER TRIGGER precio_litio ON bateria
FOR INSERT, UPDATE
AS IF ('litio' IN (SELECT DISTINCT(tipo_bateria) FROM bateria WHERE tipo_bateria IS NOT NULL))
BEGIN
UPDATE bateria SET precio_bateria = 150 WHERE tipo_bateria LIKE 'litio';
END
GO
-- Las bater�as de litio tienen m�s vida util en cantidad de uso (por carga y descarga),
-- adem�s, tarda menos en cargar que la de plomo-�cido. Es m�s cara.
SELECT * FROM bateria;
INSERT INTO bateria(ID_bateria,tipo_bateria) VALUES ('L0001','litio');
--Maximum stored procedure, function, trigger, or view nesting level exceeded (limit 32).

/*
He superado el l�mite de "anidado" de llamadas a funciones en la base de datos SQL.
Por lo que decido modificar mi esquema relacional, as� como el grafo relacional, eliminando
las entidades de "Bateria", "Acumuladores" y "calderas". Dej�ndo s�lo a los t�cnicos, los paneles
y los clientes. Proceder� a crear las relaciones entre los t�cnicos y los paneles, as� como
establecer el precio de mano de obra de los mismo (que ser�a un 33% de la instalaci�n),
que era lo que ten�a pensado dejar para el final.
*/
DROP TABLE bateria;
--
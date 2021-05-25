CREATE DATABASE PanelesSolares_ELGG
USE PanelesSolares_ELGG;
GO
--Realizo la base de datos tomando de referencia el esquema relacional de mi proyecto:
CREATE TABLE Cliente (DNI_cliente NVARCHAR(9) PRIMARY KEY NOT NULL,
nombre_cliente CHAR(20), apellido1_cliente CHAR(20) NOT NULL,
apellido2_cliente CHAR(20) NOT NULL, direccion_cliente VARCHAR(40) ,
telefono_cliente NUMERIC(9) NOT NULL
)
GO
--
CREATE TABLE PanelSolar (ID_panel VARCHAR(4) PRIMARY KEY NOT NULL,
tipo_panel CHAR(20) NOT NULL
);
GO
/*
Como se muestra en el esquema relacional, PanelSolar es una Entidad que después bifurca en dos
subentidades o entidades débiles; Fotovoltaico y Colector.

La tabla "PanelSolar" sólo tiene dos atributos porque su clave primaria servirá como clave ajena
en otras dos tablas que la necesitarán: "Fotovoltaico" y "Térmico". El atributo "tipo_panel"
se utilizará en un trigger cuya tarea será la de prevenir que las claves ajenas coincidan:

La ID del panel solar no podrá coincidir como clave ajena en las sub-entidades
"Fotovoltaico" y "Térmico". Es decir, un coche diésel y otro coche eléctrico no pueden tener 
la misma matrícula... 
*/
CREATE TABLE Fotovoltaico (
ID_fotovoltaico VARCHAR(4) FOREIGN KEY REFERENCES PanelSolar(ID_panel),
marca_fotovoltaico CHAR(20),
modelo_fotovoltaico CHAR(20),
potencia_fotovoltaico NUMERIC(4));
GO
--
CREATE TABLE Colector (
ID_termico VARCHAR(4) FOREIGN KEY REFERENCES PanelSolar(ID_panel),
marca_colector CHAR(20), modelo_colector CHAR(20), longitud_tuberia NUMERIC(2));
GO
-- Se declaran las FK como "NULL" porque existe un error después al hacer un trigger...
--
/*
El atributo "tipo_panel" de la entidad "PanelSolar" sólo puede obtener dos posibles valores
que el usuario debería conocer. Éstos son: 'fotovoltaico' o 'termico', todo en minúsculas.
Si el atributo "tipo_panel" recibe un valor distinto de los mencionados, salta el trigger
que ejecuta un ROLLBACK.
Ahora tengo que conseguir que, al insertar un ID de panel de un tipo determinado
en la tabla "PanelSolar", se inserte automáticamente en las sub-entidades correspondientes.
Para lo que fusionaré dos IFs al trigger de "valor único"...
*/
--
--
--
--
--
--CREATE OR ALTER TRIGGER denominacionPanel ON PanelSolar
--AFTER INSERT AS IF('fotovoltaico' <> (
--SELECT DISTINCT(LAST_VALUE(tipo_panel) OVER (ORDER BY tipo_panel ASC)) 
--FROM PanelSolar WHERE tipo_panel NOT LIKE 'termico'))
--BEGIN
--ROLLBACK TRANSACTION;
--PRINT 'Debe insertar un nombre de tipo de panel válido.';
--END ELSE
--IF('termico' <> (SELECT DISTINCT(LAST_VALUE(tipo_panel) OVER (ORDER BY tipo_panel ASC)) 
--FROM PanelSolar WHERE tipo_panel NOT LIKE 'fotovoltaico'))
--BEGIN
--ROLLBACK TRANSACTION;
--PRINT 'Debe insertar un nombre de tipo de panel válido.';
--END
--GO
--Comprobamos su funcionamiento:
INSERT INTO PanelSolar(ID_panel,tipo_panel) VALUES ('100N','electro');
GO
--Sólamente puedes insertar dos únicos posibles valores de tipo de panel específicos que debes conocer...
--Msg 3609, Level 16, State 1, Line 31
--The transaction ended in the trigger. The batch has been aborted.
SELECT * FROM PanelSolar;
Go
--
--ID_panel	tipo_panel

-- Procedo a crear las sub-entidades y posteriormente el trigger mencionado: 
--
DELETE FROM Fotovoltaico;DELETE FROM Colector;DELETE FROM PanelSolar;-- Por si me hace falta...
--Ésta función previene que inserte dos veces el mismo ID en la sub-entidad correspondiente
--
--Procedo a crear el trigger mencionado en el anterior comentario de líneas múltiples:
--
CREATE OR ALTER TRIGGER asignarPanel
ON PanelSolar
FOR INSERT
AS IF('fotovoltaico' IN (SELECT tipo_panel FROM PanelSolar))
BEGIN
INSERT INTO Fotovoltaico(ID_fotovoltaico) VALUES (
(SELECT TOP 1 ID_panel FROM PanelSolar
WHERE tipo_panel IN ('fotovoltaico') 
AND ID_panel NOT IN (SELECT ID_fotovoltaico FROM Fotovoltaico)
ORDER BY ID_panel DESC))
DELETE FROM Colector WHERE ID_termico IS NULL;
DELETE FROM Fotovoltaico WHERE ID_fotovoltaico IS NULL;

END
IF('termico' IN (SELECT tipo_panel FROM PanelSolar))
BEGIN
INSERT INTO Colector(ID_termico) VALUES (
(SELECT TOP 1 ID_panel FROM PanelSolar
WHERE tipo_panel IN ('termico')
AND ID_panel NOT IN (SELECT ID_termico FROM Colector)
ORDER BY ID_panel DESC))
DELETE FROM Fotovoltaico WHERE ID_fotovoltaico IS NULL;
DELETE FROM Colector WHERE ID_termico IS NULL;
END
GO
--
DELETE FROM Fotovoltaico;DELETE FROM Colector;DELETE FROM PanelSolar;
SELECT * FROM PanelSolar;
INSERT INTO PanelSolar(ID_panel,tipo_panel) VALUES('A002','fotovoltaico');
SELECT * FROM Fotovoltaico;
GO
--
/*
Procedo a hacer lo mismo para el panel Termico (el Colector). Las funciones y el trigger:
*/
--CREATE OR ALTER FUNCTION asignarTermico (@storeid VARCHAR(4))
--RETURNS TABLE
--AS RETURN (
--SELECT DISTINCT(FIRST_VALUE(ID_panel) OVER(ORDER BY ID_panel)) AS 'ID' FROM PanelSolar
--WHERE ID_panel NOT IN (SELECT ID_termico FROM Colector)
-- AND ID_panel NOT IN (SELECT ID_fotovoltaico FROM Fotovoltaico)
--AND ID_panel IS NOT NULL); -- He agregado ésta línea.
--GO
--

--
-- Lo compruebo:
SELECT * FROM PanelSolar;
Go
--ID_panel	tipo_panel
--100A	fotovoltaico
INSERT INTO PanelSolar(ID_panel,tipo_panel) VALUES ('M001','termico');
GO
SELECT * FROM Colector;
--(1 row affected)
--No es posible insertar el ID de un panel termico en la tabla de un panel fotovoltaico...

--(1 row affected)

--(1 row affected)

--(1 row affected)
SELECT * FROM Colector;
GO
--ID_termico	marca_colector	modelo_colector	longitud_tuberia
--M001	NULL	NULL	NULL
INSERT INTO PanelSolar VALUES ('M002','termico');
SELECT * FROM Colector;
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
CREATE TABLE Pedidos (
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
AS 
BEGIN
DECLARE @anzuelo INT; 
SET @anzuelo = (SELECT COUNT(ID_pedido) FROM Pedidos) + 1;
INSERT INTO Pedidos(ID_pedido,ID_cliente,ID_compra) VALUES 
((SELECT @anzuelo),(SELECT TOP 1 DNI_cliente FROM Cliente ORDER BY DNI_cliente DESC),
(SELECT TOP 1 ID_panel FROM PanelSolar
	WHERE tipo_panel IN (SELECT tipoPedido FROM Cliente)
ORDER BY ID_panel DESC));
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
"Maxell" de "Maximum Cells" tienen una potencia máxima de 3250W. Éstos tienen un coste de 1150€.

"Seriem" , "de serie". Son colectores más baratos que los colectores en paralelo porque
tienen un poder de absorción del calor menor que los paralelos. Cuestan un total de 490€.
Los paralelos "Simetra", cuestan un total de 1300€
*/
ALTER TABLE PanelSolar ADD precio_panel MONEY;
GO
--
DELETE FROM Fotovoltaico;DELETE FROM PanelSolar;
Go
--
--CREATE OR ALTER TRIGGER calcularPrecio_fotovoltaico
--ON Fotovoltaico
--FOR INSERT, UPDATE 
--AS IF('minum' IN (SELECT DISTINCT(LAST_VALUE(modelo_fotovoltaico) OVER (ORDER BY modelo_fotovoltaico ASC)) 
--FROM Fotovoltaico WHERE ID_fotovoltaico IS NOT NULL))
--BEGIN
--UPDATE PanelSolar SET precio_panel = 200 WHERE ID_panel IN (SELECT
--DISTINCT(ID_fotovoltaico) FROM Fotovoltaico
--WHERE modelo_fotovoltaico LIKE 'minum');
--END ELSE IF('maxell' IN (SELECT DISTINCT(LAST_VALUE(modelo_fotovoltaico) OVER (ORDER BY modelo_fotovoltaico ASC)) 
--FROM Fotovoltaico WHERE ID_fotovoltaico IS NOT NULL))
--BEGIN
--UPDATE PanelSolar SET precio_panel = 1150 WHERE ID_panel IN (SELECT
--DISTINCT(ID_fotovoltaico) FROM Fotovoltaico
--WHERE modelo_fotovoltaico LIKE 'maxell');
--END
GO
--
DELETE FROM Fotovoltaico;DELETE FROM Colector;DELETE FROM PanelSolar;
GO
--
--CREATE OR ALTER TRIGGER calcularPrecio_termico
--ON Termico
--FOR INSERT, UPDATE 
--AS IF('seriem' IN (SELECT DISTINCT(modelo_fotovoltaico) FROM Fotovoltaico
--								WHERE ID_fotovoltaico IS NOT NULL))
--BEGIN
--UPDATE PanelSolar SET precio_panel = 490 WHERE ID_panel = (SELECT
--DISTINCT(ID_fotovoltaico) FROM Fotovoltaico);
--END ELSE IF('simetra' IN (SELECT DISTINCT(modelo_fotovoltaico) FROM Fotovoltaico
--								WHERE ID_fotovoltaico IS NOT NULL))
--BEGIN
--UPDATE PanelSolar SET precio_panel = 1300 WHERE ID_panel = (SELECT
--DISTINCT(ID_fotovoltaico) FROM Fotovoltaico);
--END

----
--DELETE FROM Fotovoltaico;DELETE FROM PanelSolar;
Go
--
SELECT * FROM PanelSolar;
INSERT INTO PanelSolar(ID_panel,tipo_panel) VALUES ('A001','fotovoltaico');
SELECT * FROM Fotovoltaico;
UPDATE Fotovoltaico SET modelo_fotovoltaico = 'minum' WHERE ID_fotovoltaico LIKE 'A001';
--
/*
Falta establecer la relación de los fotovoltaicos con las baterías y la relación
de los coelctores con los acumuladores y éstos con las calderas.
*/
-- Baterías:
CREATE TABLE Bateria (
ID_bateria VARCHAR(5) PRIMARY KEY NOT NULL,
enchufe VARCHAR(4), -- Será el valor del Fotovoltaico al que refencia.
tipo_bateria CHAR(20),
precio_bateria MONEY);
GO
-- Creo un trigger que controle que el atributo "enchufe" únicamente pueda llevar
-- un valor igual a una clave de la entidad Fotovoltaico.
-- El uso de las baterías es siempre opcional. Por eso no se establece ninguna relación
-- de clave foránea con Fotovoltaico. Además de que Fotovoltaico no dispone de clave principal.
CREATE OR ALTER TRIGGER alimentacion ON bateria
FOR INSERT,UPDATE 
AS IF('%' NOT IN (SELECT enchufe FROM bateria 
		WHERE enchufe IN (SELECT ID_fotovoltaico FROM Fotovoltaico)))
BEGIN
PRINT 'Sólo puedes insertar el valor del ID del panel Fotovoltaico al que quieres relacionar ésta batería...';
DELETE FROM bateria WHERE enchufe NOT IN (
	SELECT ID_fotovoltaico FROM Fotovoltaico)
END
Go
SELECT * FROM PanelSolar;
INSERT INTO PanelSolar(ID_panel,tipo_panel) VALUES ('A002','fotovoltaico');
SELECT * FROM Fotovoltaico;
UPDATE Fotovoltaico SET modelo_fotovoltaico = 'maxell' WHERE ID_fotovoltaico LIKE 'A002';
-- Lo compruebo:
INSERT INTO bateria(ID_bateria, enchufe)
VALUES ('P0001','A001');
SELECT * FROM bateria;
--ID_bateria	enchufe	tipo_bateria	precio_bateria
--P0001	A001	NULL	NULL
-- Ahora intendo insertar un valor distinto:
INSERT INTO PanelSolar(ID_panel,tipo_panel) VALUES ('M001','termico');
INSERT INTO bateria(ID_bateria, enchufe)
VALUES ('P0002','M001');
INSERT INTO PanelSolar(ID_panel,tipo_panel) VALUES ('M001','termico');
SELECT * FROM Colector;
--Sólo puedes insertar el valor del ID del panel Fotovoltaico al que quieres relacionar ésta batería...

--(1 row affected)

--(1 row affected)
/*
Como establecido en el enunciado, sólo hay dos tipos de baterías. Las de litio y las de plomo-ácido.
El precio se establecerá en función al tipo de batería.
Así que tengo que crear dos triggers más: "diferenciar_tipo_bateria" y "establecer_precio_bateria".
*/
CREATE OR ALTER TRIGGER diferenciar_bateria
ON bateria
FOR INSERT, UPDATE
AS IF((SELECT TOP 1 tipo_bateria FROM Bateria WHERE tipo_bateria IS NOT NULL
ORDER BY tipo_bateria DESC) NOT IN ('plomo','litio'))
BEGIN
ROLLBACK TRANSACTION;
PRINT 'Sólo puedes insertar alguno de los valores de tipo de batería que debes conocer.';
END
GO
--
DELETE FROM bateria;
--
SELECT * FROM bateria;
GO
INSERT INTO bateria(ID_bateria,tipo_bateria) VALUES('P0003','litio');
GO
SELECT * FROM bateria;
GO
--
--
GO
DELETE FROM bateria;
INSERT INTO bateria (ID_bateria,tipo_bateria) VALUES ('P0001','plomo');
SELECT * FROM bateria;
-- Las baterías de litio tienen más vida util en cantidad de uso (por carga y descarga),
-- además, tarda menos en cargar que la de plomo-ácido. Es más cara.

/*
Me falta el Acumulador y la Caldera.
El acumulador es abastecido por un colector. Así que crearé un constraint a 
la tabla Termico que almacene la FK del ID del Acumulador.
Asímismo, la caldera es un sistema auxiliar para el acumulador. Por lo que habría
que crear otro constraint entre el acumualdor y la caldera.
*/
CREATE TABLE Acumulador(
ID_acumulador VARCHAR(5) PRIMARY KEY NOT NULL,
marca_acumulador CHAR(20), modelo_acumulador CHAR(20),
capacidad_acumulador NUMERIC(3)
);
GO
--
CREATE TABLE Caldera(
ID_caldera VARCHAR(5) PRIMARY KEY NOT NULL,
marca_caldera CHAR(20), modelo_caldera CHAR(20),
tipo_caldera CHAR(20)
);
GO
--
ALTER TABLE Colector ADD abastece VARCHAR(5);
GO
--
ALTER TABLE Colector ADD CONSTRAINT abastecimiento 
FOREIGN KEY (abastece) REFERENCES Acumulador(ID_acumulador);
GO
--
ALTER TABLE Acumulador ADD auxilio VARCHAR(5);
GO
--
ALTER TABLE Acumulador ADD CONSTRAINT auxiliar FOREIGN KEY (auxilio)
REFERENCES Caldera(ID_caldera);
GO
--
--
/*
Creamos el trigger que diferencia los tipos de caldera:
*/
--
CREATE OR ALTER TRIGGER biomasa ON Caldera
AFTER INSERT,UPDATE AS IF((SELECT TOP 1 tipo_caldera FROM Caldera WHERE tipo_caldera IS NOT NULL
ORDER BY tipo_caldera DESC) NOT IN ('biomasa','gas','electrica'))
BEGIN
ROLLBACK TRANSACTION;
PRINT 'Sólo puedes insertar un valor de entre uno de los tres tipos de caldera que debes conocer...';
END
GO
--
CREATE TABLE Tecnico(
nombre_tecnico VARCHAR(20), primer_apellido_tecnico CHAR(20),
segundo_apellido_tecnico CHAR(20),
especialidad_tecnico CHAR(30),
telefono_tecnico NUMERIC(9),
mobil_tecnico NUMERIC(9));
Go
/*
La PK del técnico puede ir vacía ya que, al insertar un nuevo panel. Inmediatamente
se inserta éste en la columna "orden de servicio".
Me interesa controlar qué panel tiene que instalar o mantener el técnico, para lo que creo
una columna de "orden de servicio":
*/
ALTER TABLE Tecnico ADD orden_servicio_tecnico VARCHAR(4);
GO
--
ALTER TABLE Tecnico ADD CONSTRAINT trabajo FOREIGN KEY (orden_servicio_tecnico)
REFERENCES PanelSolar(ID_panel);
GO -- Éste es el panel que le toca instalar o mantener al técnico.
/*
Ahora sólo queda registrar un historial de actividad de los técnicos, y
calcular el precio final de la instalación. Ésto es; costes + mano de obra.
La mano de obra del técnico suele ser un 33% del precio de la instalación.
El precio total de la instalación sería +33% de la mano de obra del técnico.
*/
CREATE TABLE Actividad_tecnico
(numero_actividad INT PRIMARY KEY NOT NULL, 
panel_objeto VARCHAR(4) FOREIGN KEY REFERENCES PanelSolar(ID_panel),
nombre_tecnico CHAR(20), primer_apellido_tecnico CHAR(20),
segundo_apellido_tecnico CHAR(20),
mano_obra MONEY,
inicio_Actividad DATETIME2 GENERATED ALWAYS AS ROW START,
fin_Seguimiento DATETIME2 GENERATED ALWAYS AS ROW END,
PERIOD FOR SYSTEM_TIME (inicio_Actividad, fin_Seguimiento))
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.historial_tecnico));
GO
--Ahora, para calcular el precio de la mano de obra:
ALTER TABLE Caldera ADD precio_caldera MONEY;
ALTER TABLE Acumulador ADD precio_acumulador MONEY;
ALTER TABLE Colector ADD precio_colector MONEY;
ALTER TABLE Fotovoltaico ADD precio_fotovoltaico MONEY;
Go
--
ALTER TABLE Tecnico ADD mano_obra MONEY;
ALTER TABLE Fotovoltaico ADD precio_Foto_intalacion MONEY;
ALTER TABLE Colector ADD precio_Term_intalacion MONEY;
--
CREATE OR ALTER TRIGGER calcular_obra_fotovoltaica
ON Fotovoltaico
AFTER INSERT, UPDATE 
AS IF ((SELECT TOP 1 precio_fotovoltaico FROM Fotovoltaico ORDER BY ID_fotovoltaico DESC) IS NOT NULL)
BEGIN
DECLARE @precio_bateria MONEY,@precio_fotovoltaico MONEY,
@precioFotovoltaica MONEY, @mano_obra_fotovoltaica MONEY;
SET @precio_bateria = (SELECT TOP 1 precio_bateria FROM Bateria ORDER BY ID_bateria DESC);
SET @precio_fotovoltaico = (SELECT TOP 1 precio_fotovoltaico FROM Fotovoltaico
WHERE ID_fotovoltaico NOT IN (SELECT DISTINCT(panel_objeto) FROM Actividad_tecnico)
ORDER BY ID_fotovoltaico DESC);
SET @precioFotovoltaica = @precio_bateria+@precio_fotovoltaico;
SET @mano_obra_fotovoltaica = (33*@precioFotovoltaica)/100;
UPDATE Tecnico SET mano_obra = (SELECT @mano_obra_fotovoltaica);
UPDATE Fotovoltaico SET precio_Foto_intalacion = (SELECT @mano_obra_fotovoltaica)+(SELECT @precio_fotovoltaico)
WHERE ID_fotovoltaico IN (SELECT TOP 1 ID_fotovoltaico FROM Fotovoltaico
ORDER BY ID_fotovoltaico DESC);
IF((SELECT ID_bateria FROM Bateria) IS NULL)
	BEGIN
	UPDATE Fotovoltaico SET precio_Foto_intalacion = ((33*@precio_fotovoltaico)/100)+@precio_fotovoltaico
	WHERE ID_fotovoltaico IN (SELECT TOP 1 ID_fotovoltaico FROM Fotovoltaico
	ORDER BY ID_fotovoltaico DESC);
	END
END
Go
--
CREATE OR ALTER TRIGGER calcular_obra_colector
ON Colector
AFTER INSERT, UPDATE
AS IF ((SELECT TOP 1 precio_colector FROM Colector ORDER BY ID_termico DESC) IS NOT NULL)
BEGIN
DECLARE @precio_caldera MONEY, @precio_acumualdor MONEY, @precio_colector MONEY,
@precio_Termica MONEY, @mano_obra_colector MONEY;
SET @precio_caldera = (SELECT TOP 1 precio_caldera FROM Caldera ORDER BY ID_caldera DESC);
SET @precio_acumualdor = (SELECT TOP 1 precio_acumulador FROM Acumulador ORDER BY ID_acumulador DESC);
SET @precio_colector = (SELECT TOP 1 precio_colector FROM Colector
WHERE ID_termico NOT IN (SELECT DISTINCT(panel_objeto) FROM Actividad_tecnico)
ORDER BY ID_termico DESC);
SET @precio_Termica = @precio_caldera+@precio_acumualdor+@precio_colector;
SET @mano_obra_colector = (33*@precio_Termica)/100;
UPDATE Tecnico SET mano_obra = (SELECT @mano_obra_colector)
UPDATE Colector SET precio_Term_intalacion = (SELECT @mano_obra_colector)+(SELECT @precio_Termica)
WHERE ID_termico IN (SELECT TOP 1 ID_termico FROM Colector ORDER BY ID_termico DESC);
END
Go
--
/*
Al insertar panel, se inserta en un futuro tecnico (ya que no hay PK en Tecnico):
*/
CREATE OR ALTER TRIGGER asignarTecnico
ON PanelSolar
AFTER INSERT
AS
BEGIN
INSERT INTO Tecnico(orden_servicio_tecnico) VALUES (
(SELECT TOP 1 ID_panel FROM PanelSolar
WHERE ID_panel NOT IN (SELECT DISTINCT(orden_servicio_tecnico) FROM Tecnico)
ORDER BY ID_panel DESC));
END
Go
-- Al insertar un nuevo técnico, se registra la actividad:
CREATE OR ALTER TRIGGER registrarActividad
ON Tecnico
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @manoObra MONEY;
	IF ((SELECT TOP 1 orden_servicio_tecnico FROM Tecnico ORDER BY orden_servicio_tecnico DESC)
	IN (SELECT TOP 1 ID_panel FROM PanelSolar WHERE tipo_panel LIKE 'fotovoltaico'
	ORDER BY ID_panel DESC))
		BEGIN
			SET @manoObra = (SELECT TOP 1 precio_fotovoltaico 
			FROM Fotovoltaico ORDER BY ID_fotovoltaico DESC);
			END ELSE
	IF ((SELECT TOP 1 orden_servicio_tecnico FROM Tecnico ORDER BY orden_servicio_tecnico DESC)
	IN (SELECT TOP 1 ID_panel FROM PanelSolar WHERE tipo_panel LIKE 'termico'
	ORDER BY ID_panel DESC))
		BEGIN
		SET @manoObra = (SELECT TOP 1 precio_colector FROM Colector ORDER BY ID_termico DESC);
		END
	DECLARE @contarActividad INT;
		SET @contarActividad = (SELECT COUNT(numero_actividad) FROM Actividad_tecnico)  + 1;
		UPDATE Actividad_tecnico SET numero_actividad = (SELECT @contarActividad);
		UPDATE Actividad_tecnico SET panel_objeto = (
		SELECT DISTINCT(orden_servicio_tecnico) FROM Tecnico
		WHERE orden_servicio_tecnico IN (SELECT TOP 1 orden_servicio_tecnico FROM Tecnico ORDER BY orden_servicio_tecnico DESC))
		UPDATE Actividad_tecnico SET nombre_tecnico = (SELECT nombre_tecnico FROM Tecnico
		WHERE orden_servicio_tecnico IN (SELECT TOP 1 orden_servicio_tecnico FROM Tecnico ORDER BY orden_servicio_tecnico DESC));
		UPDATE Actividad_tecnico SET primer_apellido_tecnico = (SELECT TOP 1 primer_apellido_tecnico 
		FROM Tecnico ORDER BY orden_servicio_tecnico DESC);
		UPDATE Actividad_tecnico SET segundo_apellido_tecnico = (SELECT TOP 1 segundo_apellido_tecnico
		FROM Tecnico WHERE orden_servicio_tecnico IN (SELECT TOP 1 orden_servicio_tecnico FROM Tecnico ORDER BY orden_servicio_tecnico DESC));
		UPDATE Actividad_tecnico SET mano_obra = (SELECT @manoObra);
END
GO
-- Falta calcular el precio total de la instalación. Se agrega en "pedidos":
ALTER TABLE Pedidos ADD precio_instalacion MONEY;
Go
--
ALTER TABLE PanelSolar DROP COLUMN precio_panel;
/*
Me queda la encriptación de datos que considere sensibles. Por lo que crearé
un usuario ficticio que no pueda ver ciertos datos mediante el enmascaramiento
y la encriptación.
*/
USE PanelesSolares_ELGG;
CREATE USER Ficticius1 WITHOUT LOGIN;
GRANT SELECT ON DATABASE::PanelesSolares_ELGG TO Ficticius1
EXECUTE AS USER = 'Ficticius1';
--REVERT;
GO
PRINT USER;
GO
SELECT * FROM PanelSolar;
GO
REVERT;
GO
--
--La instalación térmica siempre debe ser completa:
ALTER TABLE Colector ALTER COLUMN abastece VARCHAR(5) NOT NULL;
ALTER TABLE Acumulador ALTER COLUMN auxilio VARCHAR(5) NOT NULL;
GO
--
-- Ahora altero las tablas que me interesan, enmascarando los datos que me interesan:
ALTER TABLE Bateria ALTER COLUMN precio_bateria MONEY MASKED
WITH (FUNCTION = 'default()');
ALTER TABLE Bateria ALTER COLUMN tipo_bateria CHAR(20) MASKED
WITH (FUNCTION = 'default()');
SELECT * FROM Bateria;
--ID_bateria	enchufe	tipo_bateria	precio_bateria
--BAT01	A001	litio               	100,00
EXECUTE AS USER = 'Ficticius1';PRINT USER;
SELECT * FROM Bateria;
GO
--ID_bateria	enchufe	tipo_bateria	precio_bateria
--BAT01	A001	litio               	0,00
REVERT;
ALTER TABLE Fotovoltaico ALTER COLUMN precio_fotovoltaico MONEY MASKED WITH(
FUNCTION = 'default()');
ALTER TABLE Fotovoltaico ALTER COLUMN ID_fotovoltaico VARCHAR(4) MASKED WITH(
FUNCTION = 'default()');
ALTER TABLE Fotovoltaico ALTER COLUMN precio_Foto_intalacion MONEY MASKED WITH(
FUNCTION='default()');
ALTER TABLE Fotovoltaico ALTER COLUMN modelo_fotovoltaico CHAR(20) MASKED WITH(
FUNCTION = 'default()');
EXECUTE AS USER = 'Ficticius1';
SELECT * FROM Fotovoltaico;
GO
REVERT;
GO
ALTER TABLE Caldera ALTER COLUMN precio_caldera MONEY MASKED WITH(
FUNCTION = 'default()');
ALTER TABLE Caldera ALTER COLUMN tipo_caldera CHAR(20) MASKED WITH(
FUNCTION = 'default()');
ALTER TABLE Caldera ALTER COLUMN modelo_caldera CHAR(20) MASKED WITH(
FUNCTION = 'default()');
GO
ALTER TABLE Acumulador ALTER COLUMN precio_acumulador MONEY MASKED WITH(
FUNCTION = 'default()');
ALTER TABLE Acumulador ALTER COLUMN modelo_acumulador CHAR(20) MASKED WITH(
FUNCTION = 'default()');
ALTER TABLE Acumulador ALTER COLUMN auxilio VARCHAR(5) MASKED WITH(
FUNCTION = 'default()');
GO
ALTER TABLE Colector ALTER COLUMN precio_Term_intalacion MONEY MASKED WITH(
FUNCTION = 'default()');
ALTER TABLE Colector ALTER COLUMN precio_colector MONEY MASKED WITH(
FUNCTION = 'default()');
ALTER TABLE Colector ALTER COLUMN modelo_colector CHAR(20) MASKED WITH(
FUNCTION = 'default()');
ALTER TABLE Colector ALTER COLUMN abastece VARCHAR(5) MASKED WITH(
FUNCTION = 'default()');
GO
EXECUTE AS USER = 'Ficticius1';
SELECT * FROM Caldera;
SELECT * FROM Acumulador;
SELECT * FROM Colector;
GO
REVERT;
/*
Ahora corregiré una inserción en la BD que no había hecho antes. Que no se pueda
insertar directamente en las subentidades "Colector" y "Fotovoltaico" (al fotovotlaico
también puede llamarse le "placa"), ya que de eso se encarga la Entidad "panel solar".
*/
CREATE OR ALTER TRIGGER cuidarPlaca ON Fotovoltaico
FOR INSERT
AS
BEGIN
ROLLBACK TRANSACTION;
PRINT 'Debes insertar la ID del panel y el tipo (fotovoltaico, o termico), en la tabla Panel Solar.';
END
GO
--
CREATE OR ALTER TRIGGER cuidarColector ON Colector
FOR INSERT
AS
BEGIN
ROLLBACK TRANSACTION;
PRINT 'Debes insertar la ID del panel y el tipo (fotovoltaico, o termico), en la tabla Panel Solar.';
END
GO
--
ALTER TABLE Pedidos DROP COLUMN precio_instalacion; -- Es innecesario...
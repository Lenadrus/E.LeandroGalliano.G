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

--(1 row affected)

--(1 row affected)
SELECT * FROM Fotovoltaico;
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
--
-- intento insertar de nuevo.
INSERT INTO PanelSolar VALUES ('A002','fotovoltaico');

--(1 row affected)
SELECT * FROM Fotovoltaico
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
--ID_panel	tipo_panel
--100A	fotovoltaico
INSERT INTO PanelSolar VALUES ('M001','termico');
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
--ID_fotovoltaico	marca_fotovoltaico	modelo_fotovoltaico	potencia_fotovoltaico
--A001	NULL	NULL	NULL
--A002	NULL	NULL	NULL
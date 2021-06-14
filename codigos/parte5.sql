USE PanelesSolares_ELGG;
GO
--
--
DROP TABLE IF EXISTS Colector;
Go
CREATE TABLE Colector (ID_colector VARCHAR(4) FOREIGN KEY REFERENCES PanelSolar(ID_panel),
long_tuberia NUMERIC(2), precio_colector MONEY);
GO
DROP PROCEDURE IF EXISTS diferenciar_colector;DROP PROCEDURE IF EXISTS diferenciar_placa;
GO
CREATE PROCEDURE diferenciar_colector
AS
SET NOCOUNT ON
BEGIN
	DELETE FROM Colector WHERE ID_colector IN (
		SELECT LAST_VALUE(ID_panel) OVER (ORDER BY ID_panel) FROM PanelSolar WHERE tipo_panel LIKE 'fotovoltaico');
END
GO
CREATE PROCEDURE diferenciar_placa
AS SET NOCOUNT ON
BEGIN
	DELETE FROM Placa WHERE ID_placa IN (
		SELECT LAST_VALUE(ID_panel) OVER(ORDER BY ID_panel ASC) FROM PanelSolar WHERE tipo_panel LIKE 'termico');
END
GO
--
SELECT * FROM sys.procedures;
--name	object_id	principal_id	schema_id	parent_object_id	type	type_desc	create_date	modify_date	is_ms_shipped	is_published	is_schema_published	is_auto_executed	is_execution_replicated	is_repl_serializable_only	skips_repl_constraints
--calcular_presupuesto_fotovoltaico	1234103437	NULL	1	0	P 	SQL_STORED_PROCEDURE	2021-06-11 06:55:59.250	2021-06-11 06:55:59.250	0	0	0	0	0	0	0
--diferenciar_colector	1282103608	NULL	1	0	P 	SQL_STORED_PROCEDURE	2021-06-11 07:38:12.730	2021-06-11 07:38:12.730	0	0	0	0	0	0	0
--diferenciar_placa	1298103665	NULL	1	0	P 	SQL_STORED_PROCEDURE	2021-06-11 07:38:30.867	2021-06-11 07:38:30.867	0	0	0	0	0	0	0
--
DROP TRIGGER IF EXISTS tipo_colector;DROP TRIGGER IF EXISTS tipo_placa;
GO
CREATE TRIGGER tipo_colector ON Colector
FOR INSERT, UPDATE
AS IF ('fotovoltaico' IN (SELECT tipo_panel FROM PanelSolar WHERE ID_panel IN (SELECT ID_placa FROM Placa)))
BEGIN
	EXEC diferenciar_colector;
	PRINT 'No puedes insertar la ID de un panel de tipo fotovoltaico en la ID de un panel de tipo térmico.';
END
GO
--
CREATE TRIGGER  tipo_placa ON Placa
FOR INSERT, UPDATE
AS
IF ('termico' IN (SELECT tipo_panel FROM PanelSolar WHERE ID_panel IN (SELECT ID_colector FROM Colector)))
BEGIN
	EXEC diferenciar_placa;
	PRINT 'No puedes insertar la ID de un panel de tipo térmico en la ID de un panel de tipo fotovoltaico.';
END
GO
--
SELECT * FROM sys.triggers;
Go
--name	object_id	parent_class	parent_class_desc	parent_id	type	type_desc	create_date	modify_date	is_ms_shipped	is_disabled	is_not_for_replication	is_instead_of_trigger
--tipos_paneles	1314103722	1	OBJECT_OR_COLUMN	901578250	TR	SQL_TRIGGER	2021-06-11 07:40:22.957	2021-06-11 07:40:22.957	0	0	0	0
--
/*
Los triggers anteriores, aseguraran de que cuando inserte en "Placa" y en "Colector",
no se inserte la misma FK en la tabla hermana y viceversa.
*/
-- Compruebo:
DELETE FROM Placa;DELETE FROM Colector;
SELECT * FROM Colector;SELECT * FROM Placa;SELECT * FROM PanelSolar;
-- vacías excepto "PanelSolar":
--ID_panel	tipo_panel
--A001	fotovoltaico        
--M001	termico             
Go
INSERT INTO Placa VALUES ('A001',700,50);
GO
INSERT INTO Colector VALUES ('M001',26,90);
GO
SELECT * FROM Colector;SELECT * FROM Placa;
Go
--ID_colector	long_tuberia	precio_colector
--M001	26	90,00

--ID_placa	potencia	precio
--A001	700	50,00
--
-- Ahora es cuando intento insertar la FK fotovoltaica en el Colector.
INSERT INTO Colector VALUES ('A001',30,95);
--No puedes insertar la ID de un panel de tipo fotovoltaico en la ID de un panel de tipo térmico.
--No puedes insertar la ID de un panel de tipo fotovoltaico en la ID de un panel de tipo térmico.
--No puedes insertar la ID de un panel de tipo fotovoltaico en la ID de un panel de tipo térmico.
--No puedes insertar la ID de un panel de tipo fotovoltaico en la ID de un panel de tipo térmico.
--No puedes insertar la ID de un panel de tipo fotovoltaico en la ID de un panel de tipo térmico.
--No puedes insertar la ID de un panel de tipo fotovoltaico en la ID de un panel de tipo térmico.
--No puedes insertar la ID de un panel de tipo fotovoltaico en la ID de un panel de tipo térmico.
--No puedes insertar la ID de un panel de tipo fotovoltaico en la ID de un panel de tipo térmico.

--(1 row affected)
SELECT * FROM Colector;
--ID_colector	long_tuberia	precio_colector
--M001	26	90,00
--
INSERT INTO Placa VALUES ('M001',350,25);
--No puedes insertar la ID de un panel de tipo térmico en la ID de un panel de tipo fotovoltaico.
--No puedes insertar la ID de un panel de tipo térmico en la ID de un panel de tipo fotovoltaico.
--No puedes insertar la ID de un panel de tipo térmico en la ID de un panel de tipo fotovoltaico.
--No puedes insertar la ID de un panel de tipo térmico en la ID de un panel de tipo fotovoltaico.
--No puedes insertar la ID de un panel de tipo térmico en la ID de un panel de tipo fotovoltaico.
--No puedes insertar la ID de un panel de tipo térmico en la ID de un panel de tipo fotovoltaico.
--No puedes insertar la ID de un panel de tipo térmico en la ID de un panel de tipo fotovoltaico.
--No puedes insertar la ID de un panel de tipo térmico en la ID de un panel de tipo fotovoltaico.

--(1 row affected)
SELECT * FROM Placa;
--ID_placa	potencia	precio
--A001	700	50,00
--
SELECT * FROM presupuestos.instalacion_fotovoltaica;
SELECT * FROM Pedidos;SELECT * FROM actividades;
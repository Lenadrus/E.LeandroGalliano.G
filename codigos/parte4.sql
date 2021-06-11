USE master;
GO
USE PanelesSolares_ELGG;
GO
/*
El siguiente procedimiento almacenado calcula el presupuesto para cada instalación.
En éste caso, para la instalación fotovoltaica.
*/
DROP TABLE IF EXISTS Placa
CREATE TABLE Placa (
ID_placa VARCHAR(4) FOREIGN KEY REFERENCES PanelSolar(ID_panel),
potencia NUMERIC(4),
precio MONEY);
GO
-- El siguiente Schema sirve para almacenar los calculos con los precios de cada
-- elemento, así como el conjunto de cada instalación y la mano de obra del técnico (que es un 33%
-- de la instalación).
CREATE SCHEMA presupuestos;
	SELECT precio AS precio_placa, precio_bateria, mano_obra 
	INTO presupuestos.instalacion_fotovoltaica
	FROM Placa JOIN PanelSolar ON (ID_placa=ID_panel)
	JOIN Bateria ON (ID_placa=enchufe)
	JOIN Pedidos ON (ID_pedido=ID_panel)
	JOIN actividades ON (ID_panel=ID_pedido)
	JOIN Tecnico ON (fk_DNI_tecnico=DNI_tecnico);
SELECT * FROM presupuestos.instalacion_fotovoltaica;
--precio_placa	precio_bateria	mano_obra
ALTER TABLE presupuestos.instalacion_fotovoltaica ADD presupuesto_total MONEY;
SELECT * FROM presupuestos.instalacion_fotovoltaica;
--precio_placa	precio_bateria	mano_obra	presupuesto_total
GO
CREATE PROCEDURE calcular_presupuesto_fotovoltaico
AS
SET NOCOUNT ON
BEGIN
 DECLARE @placa MONEY;DECLARE @bateria MONEY; DECLARE @mano_obra MONEY;DECLARE @total MONEY;
		SET @placa = (SELECT LAST_VALUE(precio) OVER (ORDER BY ID_placa ASC) FROM Placa);
		SET @bateria = (SELECT LAST_VALUE(precio_bateria) OVER (ORDER BY ID_bateria ASC) FROM Bateria);
		SET @mano_obra = @placa+@bateria+((33*(@placa+@bateria))/100);
		SET @total = @placa+@bateria+@mano_obra;
INSERT INTO presupuestos.instalacion_fotovoltaica
VALUES (
(SELECT @placa),
(SELECT @bateria),
(SELECT @mano_obra),
(SELECT @total));
END
GO
-- Insert valores para comprobar el uso del procedimiento almacenado que acabo de crear.
DELETE FROM Bateria;DELETE FROM Placa;
SELECT * FROM Placa;SELECT * FROM Bateria;
-- filas vacías.
SELECT * FROM PanelSolar;
INSERT INTO Placa VALUES ('A001',700,50);
INSERT INTO Bateria VALUES ('B01','litio',30,'A001');
SELECT * FROM Placa;SELECT * FROM Bateria;
--ID_placa	potencia	precio
--A001	700	50,00

--ID_bateria	tipo_bateria	precio_bateria	enchufe
--B01	litio               	30,00	A001
EXEC calcular_presupuesto_fotovoltaico;
SELECT * FROM presupuestos.instalacion_fotovoltaica;
--precio_placa	precio_bateria	mano_obra	presupuesto_total
--50,00	30,00	106,40	186,40
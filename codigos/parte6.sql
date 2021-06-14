USE PanelesSolares_ELGG;
GO
SELECT * INTO presupuestos.conjunto_precios FROM presupuestos.instalacion_fotovoltaica;
GO
ALTER TABLE presupuestos.conjunto_precios ADD precio_caldera MONEY;
ALTER TABLE presupuestos.conjunto_precios ADD precio_acumulador MONEY;
ALTER TABLE presupuestos.conjunto_precios ADD precio_colector MONEY;
ALTER TABLE presupuestos.conjunto_precios ADD fecha_factura DATE;
GO
DELETE FROM presupuestos.conjunto_precios;
SELECT * FROM presupuestos.conjunto_precios;
GO
CREATE PROCEDURE calcular_precio_conjunto
AS SET NOCOUNT ON
BEGIN
	DECLARE @placa MONEY;DECLARE @bateria MONEY;DECLARE @obra MONEY;DECLARE @caldera MONEY;
	DECLARE @acumulador MONEY; DECLARE @colector MONEY;DECLARE @conjunto MONEY;DECLARE @total MONEY;
	SET @placa = (SELECT LAST_VALUE(precio_placa) OVER(ORDER BY ID_placa ASC) FROM Placa);
	SET @bateria = (SELECT LAST_VALUE(precio_bateria) OVER (ORDER BY ID_bateria) FROM Bateria);
	SET @colector = (SELECT LAST_VALUE(precio_colector) OVER (ORDER BY ID_colector ASC) FROM Colector);
	--SET @caldera = (SELECT LAST_VALUE(precio_caldera) OVER (ORDER BY ID_caldera) FROM Caldera); -- Aún no existe, así que la comentaré.
	--SET @acumulador = (SElECT LAST_VALUE(precio_acumulador) OVER (ORDER BY ID_acumulador) FROM Acumulador); -- Aún no existe, así que lo comentaré.
	SET @conjunto = @placa+@bateria+@colector--+@caldera+@acumulador
	SET @obra = (33*(@conjunto)/100) + @conjunto;
	SET @total = @conjunto + @obra;
INSERT INTO presupuestos.conjunto_precios
VALUES (
(SELECT @placa),(SELECT @bateria), (SELECT @total), (SELECT @obra), (SELECT @caldera), (SELECT @acumulador),
(SELECT @colector), (SELECT CAST(GETDATE() AS DATE))
);
END
GO
SELECT * FROM Placa;SELECT * FROM Colector;SELECT * FROM Bateria;
--ID_placa	potencia	precio_placa
--A001	700	50,00

--ID_colector	long_tuberia	precio_colector
--M001	26	90,00

--ID_bateria	tipo_bateria	precio_bateria	enchufe
--B01	litio               	30,00	A001
Go
EXEC calcular_precio_conjunto;
GO
SELECT * FROM presupuestos.conjunto_precios;
GO
--precio_placa	precio_bateria	presupuesto_total	mano_obra	precio_caldera	precio_acumulador	precio_colector	fecha_factura
--50,00	30,00	396,10	226,10	NULL	NULL	90,00	2021-06-11
--
-- Ahora particionaré ésta tabla por meses.
ALTER DATABASE CURRENT ADD FILEGROUP Enero;ALTER DATABASE CURRENT ADD FILEGROUP Febrero;
ALTER DATABASE CURRENT ADD FILEGROUP Marzo;ALTER DATABASE CURRENT ADD FILEGROUP Abril;
ALTER DATABASE CURRENT ADD FILEGROUP Mayo;ALTER DATABASE CURRENT ADD FILEGROUP Junio;
ALTER DATABASE CURRENT ADD FILEGROUP Julio;ALTER DATABASE CURRENT ADD FILEGROUP Agosto;
ALTER DATABASE CURRENT ADD FILEGROUP Septiembre;ALTER DATABASE CURRENT ADD FILEGROUP Octubre;
ALTER DATABASE CURRENT ADD FILEGROUP Noviembre;ALTER DATABASE CURRENT ADD FILEGROUP Diciembre;
GO
--
ALTER DATABASE CURRENT ADD FILE (NAME = 'ene_archvo', FILENAME = 'C:\particion\ene.ndf', SIZE = 5MB, MAXSIZE = 100MB)
TO FILEGROUP Enero;
ALTER DATABASE CURRENT ADD FILE (NAME = 'feb_archvo', FILENAME = 'C:\particion\feb.ndf', SIZE = 5MB, MAXSIZE = 100MB)
TO FILEGROUP Febrero;
ALTER DATABASE CURRENT ADD FILE (NAME = 'may_archvo', FILENAME = 'C:\particion\mar.ndf', SIZE = 5MB, MAXSIZE = 100MB)
TO FILEGROUP Marzo;
ALTER DATABASE CURRENT ADD FILE (NAME = 'abr_archvo', FILENAME = 'C:\particion\abr.ndf', SIZE = 5MB, MAXSIZE = 100MB)
TO FILEGROUP Abril;
ALTER DATABASE CURRENT ADD FILE (NAME = 'mar_archvo', FILENAME = 'C:\particion\may.ndf', SIZE = 5MB, MAXSIZE = 100MB)
TO FILEGROUP Mayo;
ALTER DATABASE CURRENT ADD FILE (NAME = 'jun_archvo', FILENAME = 'C:\particion\jun.ndf', SIZE = 5MB, MAXSIZE = 100MB)
TO FILEGROUP Junio;
ALTER DATABASE CURRENT ADD FILE (NAME = 'jul_archvo', FILENAME = 'C:\particion\jul.ndf', SIZE = 5MB, MAXSIZE = 100MB)
TO FILEGROUP Julio;
ALTER DATABASE CURRENT ADD FILE (NAME = 'ago_archvo', FILENAME = 'C:\particion\ago.ndf', SIZE = 5MB, MAXSIZE = 100MB)
TO FILEGROUP Agosto;
ALTER DATABASE CURRENT ADD FILE (NAME = 'sep_archvo', FILENAME = 'C:\particion\sep.ndf', SIZE = 5MB, MAXSIZE = 100MB)
TO FILEGROUP Septiembre;
ALTER DATABASE CURRENT ADD FILE (NAME = 'oct_archvo', FILENAME = 'C:\particion\oct.ndf', SIZE = 5MB, MAXSIZE = 100MB)
TO FILEGROUP Octubre;
ALTER DATABASE CURRENT ADD FILE (NAME = 'nov_archvo', FILENAME = 'C:\particion\nov.ndf', SIZE = 5MB, MAXSIZE = 100MB)
TO FILEGROUP Noviembre;
ALTER DATABASE CURRENT ADD FILE (NAME = 'dic_archvo', FILENAME = 'C:\particion\dic.ndf', SIZE = 5MB, MAXSIZE = 100MB)
TO FILEGROUP Diciembre;
GO
--
CREATE PARTITION FUNCTION particionar_por_mes (DATE)
AS RANGE LEFT FOR VALUES (
'2021-01-01',
'2021-02-01',
'2021-03-01',
'2021-04-01',
'2021-05-01',
'2021-06-01',
'2021-07-01',
'2021-08-01',
'2021-09-01',
'2021-10-01',
'2021-11-01');
GO
--
CREATE PARTITION SCHEME particionPorMes AS PARTITION particionar_por_mes
TO (Enero, Febrero, Marzo, Abril, Mayo, Junio, Julio, Agosto, Septiembre, Octubre, Noviembre, Diciembre);
GO
--
SELECT * FROM presupuestos.conjunto_precios;
Go
CREATE TABLE presupuesto_total (
fecha_factura DATE,
presupuesto_total MONEY)
ON particionPorMes (fecha_factura);
GO
-- Ésta tabla particionada se activará únicamente al insertar valores a la tabla
-- "conjunto_precios" del schema "presupuestos".
SELECT * FROM presupuesto_total;
--fecha_factura	presupuesto_total
GO
CREATE TRIGGER insertarParticion ON presupuestos.conjunto_precios
FOR INSERT
AS
BEGIN
	INSERT INTO presupuesto_total VALUES (
	(SELECT LAST_VALUE(fecha_factura) OVER (ORDER BY fecha_factura ASC) FROM presupuestos.conjunto_precios),
	(SELECT LAST_VALUE(presupuesto_total) OVER (ORDER BY presupuesto_total ASC) FROM presupuestos.conjunto_precios));
END
GO
--
DELETE FROM presupuestos.conjunto_precios;SELECT * FROM presupuestos.conjunto_precios;
-- Vacío
EXEC calcular_precio_conjunto;SELECT * FROM presupuesto_total;
--fecha_factura	presupuesto_total
--2021-06-11	396,10
GO
-- E.Leandro Galliano G.
USE PanelesSolares_ELGG;
GO
--Para ésta partición de tabla, voy a usar únicamente 2 filegroups.
ALTER DATABASE PanelesSolares_ELGG
ADD FILEGROUP grupoArchivos1;
GO
ALTER DATABASE AdventureWorks2017
ADD FILEGROUP grupoArchivos2;
GO
-- Agrego un archivo por grupo...
ALTER DATABASE PanelesSolares_ELGG
ADD FILE (
	NAME = personaDelTecnico,
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\personaDelTecnico.ndf',
	SIZE = 5MB,
	MAXSIZE = 100MB,
	FILEGROWTH = 20MB
) TO FILEGROUP grupoArchivos1;
GO
ALTER DATABASE PanelesSolares_ELGG
ADD FILE (
	NAME = contactoTecnico,
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\contactoTecnico.ndf',
	SIZE = 5MB,
	MAXSIZE = 100MB,
	FILEGROWTH = 20MB
) TO FILEGROUP grupoArchivos2;
GO
-- Creo la función que dividirá a la tabla en dos particiones:
CREATE PARTITION FUNCTION paraTecnicoPR1 (INT)
AS RANGE LEFT FOR VALUES (1, 100);
GO
-- Creo el Scheme de partición que aplica la función de partición a los dos filegroups:
CREATE PARTITION SCHEME tecnicoRango
AS PARTITION paraTecnicoPR1 ALL TO (grupoArchivos1);
GO -- ALL TO es para evitar el Msg 7707.
--
--Ahora procedo a crear la tabla particionada:
CREATE TABLE particionTecnico (TECNICO INT PRIMARY KEY, datos CHAR(20))
ON tecnicoRango (TECNICO);
GO

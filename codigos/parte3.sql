USE PanelesSolares_ELGG;
GO
-- Como indica la documentaci�n, debo habilitar la opci�n MEMEORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT:
ALTER DATABASE CURRENT SET MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT = ON;
Go
-- Debo crear un grupo de archivos optimizado:
ALTER DATABASE CURRENT REMOVE FILEGROUP optimizados_fg;
ALTER DATABASE CURRENT ADD FILEGROUP optimizados_fg CONTAINS MEMORY_OPTIMIZED_DATA;
-- Agregar un archivo a dicho FG:
ALTER DATABASE CURRENT ADD FILE (
NAME='optimizar', FILENAME='C:\data\optimizar.ndf')
TO FILEGROUP optimizados_fg;
GO
/*
Crear� s�lamente una �nica tabla optimizada en memoria (Bateria), ya que "Acumulador" y
"Caldera", tendr�n claves for�neas, y las tablas optimizadas en memoria no soportan
tablas con claves for�neas.
*/
CREATE TABLE Bateria ( ID_bateria VARCHAR(3) PRIMARY KEY NONCLUSTERED,
tipo_bateria CHAR(20), precio MONEY, enchufe VARCHAR(4) -- �sta columna ser� empleada en un trigger.
) WITH (MEMORY_OPTIMIZED = ON);
INSERT INTO Bateria VALUES ('B01', 'litio', 50, 'A001');
SELECT *, ID_panel AS panel_fuente
FROM Bateria JOIN PanelSolar ON (ID_panel=enchufe) WHERE tipo_panel LIKE 'fotovoltaico'
AND enchufe IN (SELECT ID_panel FROM PanelSolar);
GO
--ID_bateria	tipo_bateria	precio	enchufe	ID_panel	tipo_panel	   panel_fuente
--B01			litio           50,00	A001	A001	    fotovoltaico   A001
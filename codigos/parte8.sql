USE PanelesSolares_ELGG;
GO
--
DROP CERTIFICATE certPaneles_server;DROP MASTER KEY;
GO
--
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Abcd1234.';
GO
CREATE CERTIFICATE certPaneles_server WITH SUBJECT = 'Para encriptar la base de datos';
GO
--
SELECT TOP 1 * FROM sys.certificates ORDER BY certificate_id ASC;
GO
--
BACKUP CERTIFICATE certPaneles_server TO FILE = 'C:\certificados\certPaneles.cer'
WITH PRIVATE KEY (FILE = 'C:\certificados\privKey.pvk',
ENCRYPTION BY PASSWORD = 'Abcd1234.');
GO
--
/* Los archivos creados en la carpeta "certificados" ser�n mostrados a las im�genes capturadas,
   y a�adidos al repositorio de GitHub.
*/
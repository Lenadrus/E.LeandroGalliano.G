USE PanelesSolares_ELGG;
GO
-- Antes debo hacer un BK del certificado:
BACKUP CERTIFICATE certPaneles TO FILE 'C:\backups\certPaneles.bk'
WITH PRIVATE KEY (FILE='C:\keys\privK.pvk',
ENCRYPTION BY PASSWORD = 'Abcd1234.');
-- Haciendo la copia de seguridad de toda la Base de Datos:
BACKUP DATABASE PanelesSolares_ELGG
TO DISK 'C:\DBbackups\PanelesSolares_ELGG.bk'
WITH COMPRESSION,
ENCRYPTION (ALGORYTHM = 'AES_256',
SERVER CERTIFICATE = certPaneles), STATS = 10;
GO

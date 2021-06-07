USE PanelesSolares_ELGG;
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Abcd1234.';
GO
CREATE CERTIFICATE certPaneles WITH SUBJECT = 'Para encriptar columnas';
GO
CREATE SYMMETRIC KEY clavePanel WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE certPaneles;
Go
ALTER TABLE Bateria ADD precioEncriptado VARBINARY(MAX);
GO
OPEN SYMMETRIC KEY clavePanel DECRYPTION BY CERTIFICATE certPaneles;
Go
UPDATE Bateria
SET precioEncriptado = (ENCRYPTBYKEY(KEY_GUID('clavePanel'),CAST (precio_bateria AS nvarchar)));
GO
SELECT * FROM Bateria;
--
-- Encripto la base de datos:
USE PanelesSolares_ELGG;
GO
CREATE DATABASE ENCRYPTION KEY WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE certificadoInstalacion;
--Warning: The certificate used for encrypting the database encryption key has not been backed up. 
--You should immediately back up the certificate and the private key associated with the certificate. 
--If the certificate ever becomes unavailable or if you must restore or attach the database on another server, 
--you must have backups of both the certificate and the private key or you will not be able to open the database.
--
-- Prosigo con la copia de seguridad del certificado:
BACKUP CERTIFICATE certificadoInstalacion
TO FILE = 'C:\backups\certBK.bk'
WITH PRIVATE KEY ( FILE = 'C:\backups\certPV.pvk',
ENCRYPTION BY PASSWORD = 'Abcd1234.'
);
-- Si sale el error Msg 15151, hay que volver a crear el certificado.
--
-- Y apuedo activar la encriptación:
ALTER DATABASE PanelesSolares_ELGG SET ENCRYPTION ON;
--
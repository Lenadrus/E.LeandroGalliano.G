-- Falta crear el/los login.
CREATE DATABASE hospitaldb
GO
USE hospitaldb
GO
CREATE LOGIN doctor1 WITH PASSWORD = 'Abcd1234.' --MUST_CHANGE
GO

DROP USER IF EXISTS doctor1
GO
DROP USER IF EXISTS doctor2
GO

CREATE USER doctor1 WITHOUT LOGIN
GO
CREATE USER doctor2 WITHOUT LOGIN
GO
DROP TABLE IF EXISTS patientdata
GO
CREATE TABLE patientdata(
id INT, name NVARCHAR(30), doctorname VARCHAR(25), uid VARBINARY(1000), sympton VARBINARY(4000))
GO
-- Grant acces to the table to both doctors
GRANT SELECT, INSERT ON patientdata TO doctor1;
GRANT SELECT, INSERT ON patientdata TO doctor1;
GO

DROP MASTER KEY
GO
CREATE master KEY encryption BY password = 'Abcd1234.'
GO

SELECT *
FROM sys.symmetric_keys;
GO
--
-- Create a self-signed certificate
--
CREATE CERTIFICATE doctor1cert AUTHORIZATION doctor1
WITH subject = 'Abcd1234.', start_date = '01/01/2021'
GO --No tiene un valor comercial, no es "como el de Hacienda", es sólo para practicar.

CREATE CERTIFICATE doctor2cert AUTHORIZATION doctor2
WITH subject = 'Abcd1234.', start_date = '01/01/2021'
GO

SELECT name CertName,
	certificate_id CertID,
	pvt_key_encryption_type_desc EncryptType,
	issuer_name Issuer
FROM sys.certificates;
GO

CREATE SYMMETRIC KEY doctor1key
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE doctor1cert
GO

CREATE SYMMETRIC KEY doctor2key
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE doctor2cert
GO

SELECT * FROM sys.symmetric_keys;
GRANT VIEW DEFINITION ON CERTIFICATE::doctor1cert TO doctor1;
GRANT VIEW DEFINITION ON SYMMETRIC KEY::doctor2key TO doctor2;
GO

EXECUTE AS USER = 'doctor1'
GO
PRINT USER
GO
USE SYMMETRIC KEY doctor1Key
	DECRYPTION BY CERTIFICATE doctor1cert 
GO
-- Insert into our table.

INSERT INTO patientdata VALUES (1, 'Jack', 'Doctor1', ENCRYPTBYKEY(KEY_GUID('Doctor1Key'),'111111111111'),
ENCRYPTBYKEY(KEY_GUID('Doctor1Key'),'Cat'))
GO
INSERT INTO patientdata VALUES (2, 'Jill', 'Doctor1', ENCRYPTBYKEY(KEY_GUID('Doctor1Key'),'222222222222'),
ENCRYPTBYKEY(KEY_GUID('Doctor1Key'),'Bruise'))
GO
INSERT INTO patientdata VALUES (3, 'Jim', 'Doctor1', ENCRYPTBYKEY(KEY_GUID('Doctor1Key'),'3333333333333'),
ENCRYPTBYKEY(KEY_GUID('Doctor1Key'),'Bruise'))
GO
SELECT * FROM patientdata;
GO
EXECUTE AS USER = 'doctor2'
GO
OPEN SYMMETRIC KEY doctor2key DECRYPTION BY CERTIFICATE doctor2cert
GO
INSERT INTO patientdata
VALUES (4,
'Rick',
'Doctor2',
ENCRYPTBYKEY(KEY_GUID('Doctor2Key'),'4444444444')
ENCRYPTBYKEY(KEY_GUID('Doctor2Key'),'Cough'))
GO
INSERT INTO patientdata
VALUES (5,
'Joe',
'Doctor2',
ENCRYPTBYKEY(KEY_GUID('Doctor2Key'),'5555555555')
ENCRYPTBYKEY(KEY_GUID('Doctor2Key'),'Any'))
GO
INSERT INTO patientdata
VALUES (6,
'Pro',
'Doctor2',
ENCRYPTBYKEY(KEY_GUID('Doctor2Key'),'6666666666')
ENCRYPTBYKEY(KEY_GUID('Doctor2Key'),'Cold'))
GO

SELECT name,uid,sympton FROM patientdata
GO

CLOSE ALL SYMMETRIC KEYS
GO
REVERT
GO
EXECUTE AS USER = 'doctor1'
GO
OPEN SYMMETRIC KEY doctor1Key DECRYPTION BY CERTIFICATE doctor1cert
GO
SELECT id, name, doctorname,
CONVERT(VARCHAR, DECRYPTBYKEY(uid)) AS UID,
CONVERT(VARCHAR, DECRYPTBYKEY(sympton)) AS Sintomas
FROM patientdata
GO

CLOSE ALL SYMMETRIC keys
GO
REVERT
GO
--No se puede borrar el certificado sin antes borrar la clave simétrica.
DROP CERTIFICATE doctor2cert
GO
DROP SYMMETRIC KEY doctor2key
GO
DROP CERTIFICATE doctor2cert
GO

SELECT id, name, doctorname,
CONVERT(VARCHAR, DECRYPTBYKEY(uid)) AS UID,
CONVERT(VARCHAR, DECRYPTBYKEY(sympton)) AS Sintomas
FROM patientdata
GO
REVERT
GO

BACKUP DATABASE Pubs
TO DISK = 'C:\Backup\BackupUserDB1_Encrypt.bak';
WITH
ENCRYPTION
(
ALGORITHM = AES_256,
SERVER CERTIFICATE = DBBackupEncryptCert
),
STATS = 10
----
KILL 54 --¿?
GO
/*
Ejercicio (el que se está procediendo desde las líneas anteriores a éste comentario en adelante):
Crear master key, crear certificado, hacer backup de master key, hacer backup de certificado, hacer
baclkup del encuriptado de la BD, cargarse la BD y restaurar.
*/
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Abcd1234.';
GO
CREATE CERTIFICATE DBBackupEncryptCert
WITH SUBJECT = 'Backup Encryption Certificate'
GO
SELECT name, pvt_key_encryption_type, subject
FROM sys.certificates
GO
--
BACKUP CERTIFICATE DBBackupEncryptCert
TO FILE = 'C:\Backup\BackupEncryptCert.pvk'
WITH PRIVATE KEY
(
FILE = 'C:\Backup\BackupCert.pvk',
ENCRYPTION BY PASSWORD = 'Abcd1234.';
)
GO
--
BACKUP MASTER KEY TO FILE = 'C:\Backup\BackupMasterKey.key'
ENCRYPTION BY PASSWORD = 'Abcd1234.'
GO
--
ALGORITHM
BACKUP DATABASE Pubs TO DISK = 'C:\Backup\BackupuserDB1_Encrypt.bak';
WITH ENCRYPTION (
ALGORITHM = AES_256,
SERVER CERTIFICATE = DBBackupEncryptCert),
STATS = 10
GO
sp_who2
GO
KILL 54
GO
DROP DATABASE Pubs
GO
RESTORE DATABASE Pubs
FROM DISK = 'C:\Backup\BackupUserDB1_Encrypt.bak'
GO
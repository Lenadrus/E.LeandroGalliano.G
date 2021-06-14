USE PanelesSolares_ELGG;
GO
--
SELECT * FROM sys.certificates;
Go
--
CREATE CERTIFICATE certPaneles WITH SUBJECT = 'Para encriptar la base de datos.';
GO
--
BACKUP CERTIFICATE certPaneles_server TO FILE = 'C:\data\certPaneles_server.bk'
WITH PRIVATE KEY (
FILE= 'C:\data\certPrivKey.pvk',
ENCRYPTION BY PASSWORD = 'Abcd1234.');
Go
-- Commands completed successfully.
BACKUP DATABASE PanelesSolares_ELGG TO DISK = 'C:\data\PanelesSolares_ELGG.bk'
WITH COMPRESSION, FORMAT;
GO
--Processed 504 pages for database 'PanelesSolares_ELGG', file 'PanelesSolares_ELGG' on file 1.
--Processed 504 pages for database 'PanelesSolares_ELGG', file 'PanelesSolares_ELGG' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'ene_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'ene_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'feb_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'feb_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'may_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'may_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'abr_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'abr_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'mar_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'mar_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'jun_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'jun_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'jul_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'jul_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'ago_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'ago_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'sep_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'sep_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'oct_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'oct_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'nov_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'nov_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'dic_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'dic_archvo' on file 1.
--Processed 1 pages for database 'PanelesSolares_ELGG', file 'optimizar' on file 1.
--Processed 1 pages for database 'PanelesSolares_ELGG', file 'optimizar' on file 1.
--Processed 95 pages for database 'PanelesSolares_ELGG', file 'PanelesSolares_ELGG_log' on file 1.
--Processed 95 pages for database 'PanelesSolares_ELGG', file 'PanelesSolares_ELGG_log' on file 1.
--BACKUP DATABASE successfully processed 696 pages in 0.612 seconds (8.882 MB/sec).
--BACKUP DATABASE successfully processed 696 pages in 0.612 seconds (8.882 MB/sec).
--
USE master;
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Abcd1234.';
GO
CREATE CERTIFICATE certificado_master WITH SUBJECT = 'Para encriptar la BD.';
GO
BACKUP DATABASE PanelesSolares_ELGG TO DISK = 'C:\data\encriptadaBK_BD.bk'
WITH COMPRESSION, ENCRYPTION (ALGORITHM = AES_256, SERVER CERTIFICATE = certificado_master);
GO
--Warning: The certificate used for encrypting the database encryption key has not been backed up. You should immediately back up the certificate and the private key associated with the certificate. If the certificate ever becomes unavailable or if you must restore or attach the database on another server, you must have backups of both the certificate and the private key or you will not be able to open the database.
--Warning: The certificate used for encrypting the database encryption key has not been backed up. You should immediately back up the certificate and the private key associated with the certificate. If the certificate ever becomes unavailable or if you must restore or attach the database on another server, you must have backups of both the certificate and the private key or you will not be able to open the database.
--Warning: The certificate used for encrypting the database encryption key has not been backed up. You should immediately back up the certificate and the private key associated with the certificate. If the certificate ever becomes unavailable or if you must restore or attach the database on another server, you must have backups of both the certificate and the private key or you will not be able to open the database.
--Warning: The certificate used for encrypting the database encryption key has not been backed up. You should immediately back up the certificate and the private key associated with the certificate. If the certificate ever becomes unavailable or if you must restore or attach the database on another server, you must have backups of both the certificate and the private key or you will not be able to open the database.
--Processed 504 pages for database 'PanelesSolares_ELGG', file 'PanelesSolares_ELGG' on file 1.
--Processed 504 pages for database 'PanelesSolares_ELGG', file 'PanelesSolares_ELGG' on file 1.
--Processed 504 pages for database 'PanelesSolares_ELGG', file 'PanelesSolares_ELGG' on file 1.
--Processed 504 pages for database 'PanelesSolares_ELGG', file 'PanelesSolares_ELGG' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'ene_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'ene_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'ene_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'ene_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'feb_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'feb_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'feb_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'feb_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'may_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'may_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'may_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'may_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'abr_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'abr_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'abr_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'abr_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'mar_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'mar_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'mar_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'mar_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'jun_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'jun_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'jun_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'jun_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'jul_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'jul_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'jul_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'jul_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'ago_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'ago_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'ago_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'ago_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'sep_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'sep_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'sep_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'sep_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'oct_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'oct_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'oct_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'oct_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'nov_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'nov_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'nov_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'nov_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'dic_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'dic_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'dic_archvo' on file 1.
--Processed 8 pages for database 'PanelesSolares_ELGG', file 'dic_archvo' on file 1.
--Processed 1 pages for database 'PanelesSolares_ELGG', file 'optimizar' on file 1.
--Processed 1 pages for database 'PanelesSolares_ELGG', file 'optimizar' on file 1.
--Processed 1 pages for database 'PanelesSolares_ELGG', file 'optimizar' on file 1.
--Processed 1 pages for database 'PanelesSolares_ELGG', file 'optimizar' on file 1.
--Processed 101 pages for database 'PanelesSolares_ELGG', file 'PanelesSolares_ELGG_log' on file 1.
--Processed 101 pages for database 'PanelesSolares_ELGG', file 'PanelesSolares_ELGG_log' on file 1.
--Processed 101 pages for database 'PanelesSolares_ELGG', file 'PanelesSolares_ELGG_log' on file 1.
--Processed 101 pages for database 'PanelesSolares_ELGG', file 'PanelesSolares_ELGG_log' on file 1.
--BACKUP DATABASE successfully processed 702 pages in 0.429 seconds (12.776 MB/sec).
--BACKUP DATABASE successfully processed 702 pages in 0.429 seconds (12.776 MB/sec).
--BACKUP DATABASE successfully processed 702 pages in 0.429 seconds (12.776 MB/sec).
--BACKUP DATABASE successfully processed 702 pages in 0.429 seconds (12.776 MB/sec).
BACKUP CERTIFICATE certificado_master TO FILE = 'C:\data\certificado_master.bk'
WITH PRIVATE KEY (FILE='C:\data\certificado_master.pvk',
ENCRYPTION BY PASSWORD = 'Abcd1234.');
Go
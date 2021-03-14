USE [master]
GO
DROP DATABASE IF EXISTS PruebaFS
GO
CREATE DATABASE PruebaFS
GO
USE PruebaFS
GO
ALTER DATABASE PruebaFS
	ADD FILEGROUP [PRIMARY_FILESTREAM]
	CONTAINS FILESTREAM
GO
/*
ALTER DATABASE PruebaFS
	ADD FILE (
			NAME = 'MyDayabase_filestream',
			FILENAME = 'C'
			...
*/
DROP TABLE IF EXISTS IMAGES
GO
CREATE TABLE images(id, imageFile)
	SELECT NEWID(), BulkColumn
	FROM OPENROWSET(BULK 'C:\Fotos_Actores\brad.jfif', SINGLE_BLOB) as f;
GO
INSERT INTO images(id, imageFile)
	SELECT NEWID(), BulkColumn
	FROM OPENROWSET
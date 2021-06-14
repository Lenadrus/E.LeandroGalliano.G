USE PanelesSolares_ELGG;
Go
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Abcd1234.';
GO
CREATE CERTIFICATE cert_encriptar_columna WITH SUBJECT = 'Para encriptación de columnas.';
GO
CREATE SYMMETRIC KEY clave_sym_1
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE cert_encriptar_columna;
GO
-- Encriptaré todas las columnas de tipo MONEY:
ALTER TABLE Placa
ADD precio_encriptado VARBINARY(MAX);
ALTER TABLE Colector
ADD precio_encriptado VARBINARY(MAX);
ALTER TABLE Bateria
ADD precio_encriptado VARBINARY(MAX);
GO
OPEN SYMMETRIC KEY clave_sym_1
DECRYPTION BY CERTIFICATE cert_encriptar_columna;
GO
CREATE PROCEDURE encriptar_precio_placa
AS SET NOCOUNT ON
BEGIN
UPDATE Placa SET precio_encriptado =
ENCRYPTBYKEY(KEY_GUID('clave_sym_1'), CAST (precio_placa AS varbinary(MAX)))
WHERE ID_placa IN (SELECT LAST_VALUE(ID_placa) OVER (ORDER BY ID_placa ASC) FROM Placa);
END
GO
CREATE PROCEDURE encriptar_precio_colector
AS SET NOCOUNT ON
BEGIN
UPDATE Colector SET precio_encriptado =
ENCRYPTBYKEY(KEY_GUID('clave_sym_1'), CAST (precio_colector AS varbinary(MAX)))
WHERE ID_colector IN (SELECT LAST_VALUE(ID_colector) OVER (ORDER BY ID_colector ASC)
FROM Colector);
END
GO
CREATE PROCEDURE encriptar_precio_bateria
AS SET NOCOUNT ON
BEGIN
UPDATE Bateria SET precio_encriptado =
ENCRYPTBYKEY(KEY_GUID('clave_sym_1'), CAST (precio_bateria AS varbinary(MAX)))
WHERE ID_bateria IN (SELECT LAST_VALUE(ID_bateria) OVER (ORDER BY ID_bateria ASC) FROM Bateria);
END
GO
--
SELECT * FROM Bateria;SELECT * FROM Placa;SELECT * FROM Colector;
--ID_bateria	tipo_bateria	precio_bateria	enchufe	precio_encriptado
--B01	litio               	30,00	A001	NULL

--ID_placa	potencia	precio_placa	precio_encriptado
--A001	700	50,00	NULL

--ID_colector	long_tuberia	precio_colector	precio_encriptado
--M001	26	90,00	NULL
--
EXEC encriptar_precio_bateria;EXEC encriptar_precio_placa;EXEC encriptar_precio_colector;
SELECT * FROM Bateria;SELECT * FROM Placa;SELECT * FROM Colector;
--ID_bateria	tipo_bateria	precio_bateria	enchufe	precio_encriptado
--B01	litio               	30,00	A001	0x0062749DB073FD4B8A273D62AB94D92E0200000094779947DDC95B210D3C1AAEFD90EC02057196F6F02FDFBC214C82A93B882A22722711046D0A2C5701E016B03ECCA4B5

--ID_placa	potencia	precio_placa	precio_encriptado
--A001	700	50,00	0x0062749DB073FD4B8A273D62AB94D92E0200000032DF8F76652CF887BEF4053F47F19A7DE349529CD7DB45A7F2BFF251FD9268C5D7B47F9F61747636ECA169BFFE6EB39F

--ID_colector	long_tuberia	precio_colector	precio_encriptado
--M001	26	90,00	0x0062749DB073FD4B8A273D62AB94D92E020000005140C220BF70E767753A70242FBBAE6533EA2E4A24717EB0AE053F416ECA1A540A9F6EADC2362F16B7B65C5ACB73CA22
--
USE PanelesSolares_ELGG;
CREATE USER Ficticius1 WITHOUT LOGIN;
GRANT SELECT ON DATABASE::PanelesSolares_ELGG TO Ficticius1
EXECUTE AS USER = 'Ficticius1';
--REVERT;
GO
PRINT USER;
GO
SELECT * FROM PanelSolar;
GO
REVERT;
GO
--
--La instalación térmica siempre debe ser completa:
ALTER TABLE Colector ALTER COLUMN abastece VARCHAR(5) NOT NULL;
ALTER TABLE Acumulador ALTER COLUMN auxilio VARCHAR(5) NOT NULL;
GO
--
-- Ahora altero las tablas que me interesan, enmascarando los datos que me interesan:
ALTER TABLE Bateria ALTER COLUMN precio_bateria MONEY MASKED
WITH (FUNCTION = 'default()');
ALTER TABLE Bateria ALTER COLUMN tipo_bateria CHAR(20) MASKED
WITH (FUNCTION = 'default()');
SELECT * FROM Bateria;
--ID_bateria	enchufe	tipo_bateria	precio_bateria
--BAT01	A001	litio               	100,00
EXECUTE AS USER = 'Ficticius1';PRINT USER;
SELECT * FROM Bateria;
GO
--ID_bateria	enchufe	tipo_bateria	precio_bateria
--BAT01	A001	litio               	0,00
REVERT;
ALTER TABLE Fotovoltaico ALTER COLUMN precio_fotovoltaico MONEY MASKED WITH(
FUNCTION = 'default()');
ALTER TABLE Fotovoltaico ALTER COLUMN ID_fotovoltaico VARCHAR(4) MASKED WITH(
FUNCTION = 'default()');
ALTER TABLE Fotovoltaico ALTER COLUMN precio_Foto_intalacion MONEY MASKED WITH(
FUNCTION='default()');
ALTER TABLE Fotovoltaico ALTER COLUMN modelo_fotovoltaico CHAR(20) MASKED WITH(
FUNCTION = 'default()');
EXECUTE AS USER = 'Ficticius1';
SELECT * FROM Fotovoltaico;
GO
REVERT;
GO
ALTER TABLE Caldera ALTER COLUMN precio_caldera MONEY MASKED WITH(
FUNCTION = 'default()');
ALTER TABLE Caldera ALTER COLUMN tipo_caldera CHAR(20) MASKED WITH(
FUNCTION = 'default()');
ALTER TABLE Caldera ALTER COLUMN modelo_caldera CHAR(20) MASKED WITH(
FUNCTION = 'default()');
GO
ALTER TABLE Acumulador ALTER COLUMN precio_acumulador MONEY MASKED WITH(
FUNCTION = 'default()');
ALTER TABLE Acumulador ALTER COLUMN modelo_acumulador CHAR(20) MASKED WITH(
FUNCTION = 'default()');
ALTER TABLE Acumulador ALTER COLUMN auxilio VARCHAR(5) MASKED WITH(
FUNCTION = 'default()');
GO
ALTER TABLE Colector ALTER COLUMN precio_Term_intalacion MONEY MASKED WITH(
FUNCTION = 'default()');
ALTER TABLE Colector ALTER COLUMN precio_colector MONEY MASKED WITH(
FUNCTION = 'default()');
ALTER TABLE Colector ALTER COLUMN modelo_colector CHAR(20) MASKED WITH(
FUNCTION = 'default()');
ALTER TABLE Colector ALTER COLUMN abastece VARCHAR(5) MASKED WITH(
FUNCTION = 'default()');
GO
EXECUTE AS USER = 'Ficticius1';
SELECT * FROM Caldera;
SELECT * FROM Acumulador;
SELECT * FROM Colector;
GO
REVERT;
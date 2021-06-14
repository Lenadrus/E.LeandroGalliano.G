USE PanelesSolares_ELGG;
GO
--
/*
Creo una nueva tabla "informacion_instalacion" que será para dos nuevos usuarios:
electricista y fontanero.
El electricista no debe de ver la información de las instalaciones térmicas.
El fontanero no debe de ver la información de las instalaciones fotovoltaicas.
*/
--
DROP TABLE IF EXISTS informacionInstalacion;
GO
CREATE TABLE informacionInstalacion (ID_instalacion VARCHAR(4) FOREIGN KEY REFERENCES PanelSolar(ID_panel),
direccion_cliente CHAR(50), tipo_instalacion CHAR(20), precio_instalacion MONEY, especialista SYSNAME);
GO
CREATE USER electricista WITHOUT LOGIN;
GO
CREATE USER fontanero WITHOUT LOGIN;
GO
--
CREATE SCHEMA seguridad
GO
DROP FUNCTION IF EXISTS seguridad.obtener_usuario;
GO
CREATE FUNCTION seguridad.obtener_usuario (@especialista AS SYSNAME)
RETURNS TABLE WITH SCHEMABINDING
AS
RETURN SELECT 1 AS AccessRight WHERE @especialista = USER_NAME() OR
USER_NAME() ='ICC_USER';
GO
--
SELECT * FROM PanelSolar;
GO
-- vacío.
INSERT INTO PanelSolar VALUES ('A001','fotovoltaico');
Go
INSERT INTO PanelSolar VALUES ('M001','termico');
GO
--
SELECT * FROM informacionInstalacion;
GO
INSERT INTO informacionInstalacion
VALUES ('A001', 'CL benito perez 62, 1º, B','fotovoltaico',900,'electricista');
GO
--
INSERT INTO informacionInstalacion
VALUES ('M001', 'AV santisima tribu 1, BJ','termico',900,'fontanero');
Go
--
SELECT * FROM informacionInstalacion;
GO
--
DROP SECURITY POLICY IF EXISTS pol_seg_especialista;
Go
--
CREATE SECURITY POLICY pol_seg_especialista
ADD FILTER PREDICATE seguridad.obtener_usuario (especialista)
ON dbo.informacionInstalacion
WITH (STATE=ON);
GO
--
DENY ALL ON Placa TO fontanero;
DENY ALL ON Bateria TO fontanero;
DENY ALL ON Colector TO electricista;
DENY ALL ON Acumulador TO electricista;
DENY ALL ON Caldera TO electricista;
GO
--The ALL permission is deprecated and maintained only for compatibility. It DOES NOT imply ALL permissions defined on the entity.
--
GRANT ALL ON informacionInstalacion TO dbo;
GRANT SELECT ON informacionInstalacion TO fontanero;
GRANT SELECT ON informacionInstalacion TO electricista;
GO
EXECUTE AS USER = 'fontanero';
GO
SELECT * FROM informacionInstalacion;
--ID_instalacion	direccion_cliente	tipo_instalacion	precio_instalacion	especialista
--M001	AV santisima tribu 1, BJ                          	termico             	900,00	fontanero
--
REVERT;
EXECUTE AS USER = 'electricista';
GO
SELECT * FROM informacionInstalacion;
Go
--ID_instalacion	direccion_cliente	tipo_instalacion	precio_instalacion	especialista
--A001	CL benito perez 62, 1º, B                         	fotovoltaico        	900,00	electricista
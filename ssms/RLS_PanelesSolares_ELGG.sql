USE PanelesSolares_ELGG;
GO
-- Antes que nada, creo un nuevo SCHEMA al que agrego todas las tablas de la BD:
DROP FUNCTION IF EXISTS SeguridadRL;
/*
La siguiente función filtra si el parámetro "@UserName" coincide con
-- el usuario presente o si coincide con el administrador. Es decir,
-- comprueba si eres el administrador.
*/
CREATE OR ALTER FUNCTION SeguridadRL (@UserName AS SYSNAME)
RETURNS TABLE WITH SCHEMABINDING
AS
RETURN SELECT 1 AS AccessRight
WHERE @UserName = USER_NAME() OR USER_NAME = 'ICC_USER';
GO
--
CREATE SECURIY POLICY soloConsultar
ADD FILTER PREDICATE usuariosPredicado(UserName)
ON PanelesSolares_ELGG;
USE [master]
GO

/****** Object:  DdlTrigger [trg_NotNewLogin]    Script Date: 09/02/2021 21:25:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   TRIGGER [trg_NotNewLogin]
ON ALL SERVER -- SERVER LEVEL
FOR CREATE_LOGIN -- Sentencia a controlar
AS
	PRINT 'No login creations without DBA involvement'
	ROLLBACK TRAN
GO

ENABLE TRIGGER [trg_NotNewLogin] ON ALL SERVER
GO

/*
DISABLE Trigger ALL ON ALL SERVER; -- Código del botón "DISABLE" en la GUI.
GO
ENABLE Trigger ALL ON ALL SERVER; -- Código del botón "DISABLE" en la GUI.
GO

DROP TRIGGER trg_NotNewLogin -- Código del botón "DELETE" en la GUI.
	ON ALL SERVER
GO
*/



/*
Controlar que nadie elimine las tablas:
*/

/*
							-- TRIGGER a nivel de BD (DML)
-- En el entorno gráfico éste tipoo de trigger aparece dentro de 'programmability' en
*/
-- Primero creamos la tabla con select into
USE pubs
GO
IF OBECT_ID('Autores', 'U') IS NOT NULL
	DROP TABLE IF EXISTS autores
GO
SELECT *
	INTO autores
	FROM authors
GO
SELECT * FROM autores
GO
-- Creamos el trigger ()
IF OBJECT_ID('trg_PrevenirBorrado','TR') IS NOT NULL
	DROP TRIGGER trg_PrevenirBorrado
GO
CREATE OR ALTER TRIGGER trg_PrevenirBorrado
ON DATABASE
FOR DROP_TABLE, ALTER_TABLE
AS
	RAISERROR('No se pueden borrar o modificar tablas', 16, 3)
	ROLLBACK TRAN
GO

-- Probamos a borrar la tabla recién creada
DROP TABLE autores
GO

-- DROP TRIGGER IF EXISTS trg_PrevenirBorrado;


/*
Creamos un trigger que nos ejecute un raiserror yu un proceedmiento almacenado.

Después de una inserción o un update en la tabla autores.
*/
CREATE OR ALTER TRIGGER trg_DarAutor
ON autores
AFTER INSERT, UPDATE -- Si ponemos 'FOR' es un 'After'
AS
	RAISERROR(50009,16,10)
	EXEC sp_helpdb pubs
GO
-- Comprobamos el contenido de la tabla:
SELECT * FROM autores
GO
--lo probamos
UPDATE autores
	SET au_lname = 'Black'
	WHERE au_fname = 'Johnson';
GO

DISABLE TRIGGER trg_DarAutor ON autores
GO

ENABLE TRIGGER trg_DarAutor ON autores
GO

DROP TRIGGER trg_DarAutor
GO

-- Creamos otro trigger de tripo after:

CREATE OR ALTER TRIGGER trg_norra
ON autores
FOR DELETE, UPDATE
AS
	RAISERROR('%d filas modificadas en la tabla Autores',16,1,@@rowcount)
GO
SELECT *
FROM autores
WHERE au_fname='Johnson'
GO
-- Try out
DELETE autores
WHERE au_fname='Johnson'
GO

CREATE OR ALTER VIEW vAutores
AS 
	SELECT *
	FROM authors WHERE au_lname LIKE '%reen%';
GO

CREATE OR ALTER TRIGGER	trg_borrarVista
ON vAutores
INSTEAD OF DELETE
AS
	PRINT 'No puedes borrar la vista.'
GO

DELETE vAutores
GO

SELECT * FROM authors
GO
UPDATE authors
SET city='A Coruña'
WHERE contract = 0
GO
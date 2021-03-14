USE master
GO
SELECT *
	INTO tempdb.dbo.copia
	FROM pubs.dbo.authors
GO
SELECT * 
	INTO tempdb.dbo.copia
	FROM tempdb.dbo.copia
	WHERE 1=2
GO
SELECT * FROM tempdb.dbo.copia
GO
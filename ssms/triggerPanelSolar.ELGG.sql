-- Por E. Leandro Galliano G.
USE PanelesSolares_ELGG;
GO
CREATE OR ALTER TRIGGER denominacionPanel ON PanelSolar
AFTER INSERT AS IF('%' NOT IN (
SELECT DISTINCT(tipo_panel)
FROM PanelSolar WHERE tipo_panel IN ('termico','fotovoltaico'))
BEGIN
ROLLBACK TRANSACTION;
PRINT 'Debe insertar un nombre de tipo de panel válido.';
END
GO

/*
Ésta Query es para hacer consultas e inserciones de prueba a la Base de Datos,
para comprobar que los triggers y las constrainst funcionan...
*/
USE PanelesSolares_ELGG;
Go
SELECT * FROM PanelSolar;
-- Limpio toda la BD:
DELETE FROM Colector;DELETE FROM Fotovoltaico;DELETE FROM PanelSolar;
DELETE FROM Cliente;DELETE FROM Tecnico; DELETE FROM Pedidos;DELETE FROM Acumulador;
DELETE FROM Caldera;DELETE FROM Bateria;
--
SELECT * FROM PanelSolar;
SELECT * FROM Fotovoltaico;
/*
 25 letras del alfabeto (sin contar la Ñ). Desde la 'A' a la 'L', se identifican códigos de
 paneles fotovoltaicos. Desde la 'M' a la 'Y', códigos de paneles térmicos (colectores).
 La Z es reservada para insertar valores alternos entre Fotovoltaicos y Colectores.
*/
INSERT INTO PanelSolar(ID_panel,tipo_panel) VALUES ('A001','fotovoltaico');
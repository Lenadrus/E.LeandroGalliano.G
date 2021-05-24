/*
Ésta Query es para hacer consultas e inserciones de prueba a la Base de Datos,
para comprobar que los triggers y las constrainst funcionan...
*/
USE PanelesSolares_ELGG;
Go
--
SELECT * FROM PanelSolar;
GO
-- Limpio toda la BD (dos veces):
DELETE FROM Colector;DELETE FROM Fotovoltaico;DELETE FROM PanelSolar;
DELETE FROM Cliente;DELETE FROM Tecnico; DELETE FROM Pedidos;DELETE FROM Acumulador;
DELETE FROM Caldera;DELETE FROM Bateria;
--
/*
 25 letras del alfabeto (sin contar la Ñ). Desde la 'A' a la 'L', se identifican códigos de
 paneles fotovoltaicos. Desde la 'M' a la 'Y', códigos de paneles térmicos (colectores).
 La Z es reservada para insertar valores alternos entre Fotovoltaicos y Colectores.
*/
INSERT INTO PanelSolar(ID_panel,tipo_panel) VALUES ('A001','fotovoltaico');
INSERT INTO PanelSolar(ID_panel,tipo_panel) VALUES ('M001','termico');
INSERT INTO PanelSolar(ID_panel,tipo_panel) VALUES ('A002','fotovoltaico');
SELECT * FROM PanelSolar;SELECT * FROM Fotovoltaico;SELECT * FROM Colector;
SELECT * FROM Tecnico;
GO
-- Me invento las marcas, los modelos y los precios para acabar antes...
-- Cualquier coincidencia con denominaciones reales es casual...
UPDATE Fotovoltaico SET marca_fotovoltaico = 'Fosoix' WHERE
ID_fotovoltaico = 'A001';
UPDATE Fotovoltaico SET modelo_fotovoltaico = 'Minum' WHERE
ID_fotovoltaico = 'A001';
UPDATE Fotovoltaico SET precio_fotovoltaico = 200.0 WHERE
ID_fotovoltaico = 'A001';
UPDATE Fotovoltaico SET potencia_fotovoltaico = 700 WHERE
ID_fotovoltaico = 'A001';
UPDATE Fotovoltaico SET marca_fotovoltaico = 'Fosoix' WHERE
ID_fotovoltaico = 'A002';
UPDATE Fotovoltaico SET modelo_fotovoltaico = 'Maxell' WHERE
ID_fotovoltaico = 'A002';
UPDATE Fotovoltaico SET precio_fotovoltaico = 800 WHERE
ID_fotovoltaico = 'A002';
UPDATE Fotovoltaico SET potencia_fotovoltaico = 1300 WHERE
ID_fotovoltaico = 'A002';
SELECT * FROM Fotovoltaico;
--ID_fotovoltaico	marca_fotovoltaico	modelo_fotovoltaico	potencia_fotovoltaico	precio_fotovoltaico
--A001	Fosoix              	Minum               	700	200,00
--A002	Fosoix              	Maxell              	1300	800,00
INSERT INTO Bateria
VALUES ('BAT01','A001','litio',100);
SELECT * FROM Bateria;
GO
INSERT INTO Caldera(ID_caldera,marca_caldera,modelo_caldera,tipo_caldera,precio_caldera) 
VALUES('CAL01','Fenix','Elektra','electrica',200);
SELECT * FROM Caldera;
GO
INSERT INTO Acumulador(ID_acumulador,marca_acumulador,modelo_acumulador,capacidad_acumulador,
auxilio,precio_acumulador)
VALUES('ACU01','Iago','Lakum',300,'CAL01',150);
SELECT * FROM Acumulador;
Go
--
UPDATE Colector SET abastece = 'ACU01'
WHERE ID_termico = 'M001';
UPDATE Colector SET marca_colector = 'Poseifen'
WHERE ID_termico = 'M001';;
UPDATE Colector SET modelo_colector = 'Simetra'
WHERE ID_termico = 'M001';
UPDATE Colector SET longitud_tuberia = 30
WHERE ID_termico = 'M001';
UPDATE Colector SET precio_colector = 120
WHERE ID_termico = 'M001';
SELECT * FROM Colector;
GO
--
INSERT INTO Cliente
VALUES('12345678A','Juan','Perez','Valdosa','LG trece bajo, Abedul',999888777,'fotovoltaico');
SELECT * FROM Cliente;
SELECT * FROM Pedidos;
GO
-- Si quiero conocer el precio del pedido:
SELECT * FROM PanelSolar WHERE ID_panel LIKE 'A002';-- Con ésto conozco el tipo de panel.
SELECT * FROM Fotovoltaico WHERE ID_fotovoltaico LIKE 'A002'; -- Con ésto conozco el precio
UPDATE Fotovoltaico SET precio_fotovoltaico = 200 WHERE ID_fotovoltaico LIKE 'A001';
SELECT * FROM Fotovoltaico;
UPDATE Fotovoltaico SET precio_fotovoltaico = 800 WHERE ID_fotovoltaico LIKE 'A002';
SELECT * FROM Fotovoltaico;
-- Si el precio de la instalación fotovoltaica (precio_Foto_instalacion) es NULL, significa
-- que no incluye batería, y su precio es igual a de la fotovoltaica + el 33% de la mano de obra.
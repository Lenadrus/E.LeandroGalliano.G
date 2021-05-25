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
SELECT * FROM Tecnico;
/*
Habrá un técnico especializado en fontanería y otro en electricidad.
Cualquier coincidencia es casual.
*/
UPDATE Tecnico SET nombre_tecnico = 'Lucas', primer_apellido_tecnico = 'Allegado', 
segundo_apellido_tecnico = 'Calvo', especialidad_tecnico = 'electricista', mobil_tecnico = 655442211
WHERE orden_servicio_tecnico IN ('A001','A002');
UPDATE Tecnico SET nombre_tecnico = 'Sebastián', primer_apellido_tecnico = 'Amigo',
segundo_apellido_tecnico = 'Gonzalez', especialidad_tecnico = 'fontanero', mobil_tecnico = 655331112
WHERE orden_servicio_tecnico = 'M001';
SELECT * FROM Tecnico;
GO
--
SELECT * FROM historialPedidos;
GO
/* Como el tipo de pedido del cliente es "fotovoltaico", sólo aparecen los paneles
cuyo código coincide en tipo "fotovoltaico". Pero aparecen dos códigos porque
se insertaron varios códigos a la vez. Es importante insertar un panel por vez, y un
cliente por vez, para evitar que el cliente compre dos o más paneles por accidente.

Así que la DDL debe de ser progresivamente gradual... :
*/
DELETE FROM Colector;DELETE FROM Fotovoltaico;DELETE FROM PanelSolar;
DELETE FROM Cliente;DELETE FROM Tecnico; DELETE FROM Pedidos;DELETE FROM Acumulador;
DELETE FROM Caldera;DELETE FROM Bateria;DELETE FROM Actividad_tecnico; -- Selecciono todo y lo ejecuto al menos 3 veces.
-- Voy insertando valores a medida que hay clientes.

/*El siguiente cliente requiere un sistema de calefaccion para su hogar.
Necesita calentar las habitaciones de su hogar, con radiadores.
Por lo que se le recomiendan tres paneles solares térmicos.*/
--
INSERT INTO PanelSolar VALUES('R001','termico');
INSERT INTO PanelSolar VALUES('R002','termico');
INSERT INTO PanelSolar VALUES('R003','termico');
SELECT * FROM Colector;
GO
INSERT INTO Caldera VALUES ('CAL01','Nubem','Megas','electrica',90);
INSERT INTO Acumulador VALUES ('ACU01','Iago','Lakum',300,'CAL01',150);
GO
UPDATE Colector SET marca_colector = 'Poseifen', modelo_colector = 'Simetra', longitud_tuberia = 10,
precio_colector = 200 WHERE ID_termico IN ('R001','R002','R003');
UPDATE Colector SET abastece = 'ACU01';
SELECT * FROM Colector;
GO
INSERT INTO Cliente VALUES ('22274521A','Benito','Suarez','Galvez','Av Puente del Camino, 8, A',
987653214,'termico');
SELECT * FROM Cliente;
GO -- Tras preparar los paneles para el cliente, podemos insertar al cliente y comprobar sus datos.
SELECT * FROM historialPedidos; -- Ahora podemos comprobar sus compras...
GO
--Sólo queda asignar al técnico que tratará la instalación:
SELECT * FROM Tecnico;
GO
UPDATE Tecnico SET nombre_tecnico = 'Luis', primer_apellido_tecnico = 'Albarez',
segundo_apellido_tecnico = 'Suarez', especialidad_tecnico = 'fontanería',
mobil_tecnico = 655223349
WHERE orden_servicio_tecnico IN ('R001','R002','R003');
SELECT * FROM Tecnico;
GO
SELECT * FROM Actividad_tecnico;
GO
--
/*
Ahora, quiero obtener el precio total real de la instalación:
*/
DECLARE @precio1 MONEY, @precio2 MONEY, @precio3 MONEY, @precio4 MONEY;
SET @precio1 = (SELECT SUM(precio_caldera) FROM Caldera);-- Aquí hago SUM() porque sé que sólo hay una fila...
SET @precio2 = (SELECT SUM(precio_acumulador) FROM Acumulador);--Aquí hago SUM() porque sé que sólo hay una fila...
SET @precio3 = (SELECT SUM(precio_colector) FROM Colector);/*Aquí hago SUM() porque sé que todas las filas están relacionadas
con la misma transacción.*/
SET @precio4 = (SELECT SUM(mano_obra) FROM Tecnico); -- Aquí no hago WHERE porque sé que sólo hay un técnico.
DECLARE @precioTotal MONEY;
SET @precioTotal = @precio1+@precio2+@precio3+@precio4;
SELECT CONCAT(@precioTotal,'€') AS 'Precio total';
--
--Precio total
--1275.60€
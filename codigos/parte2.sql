/*
Crearé la tabla temporal "Pedidos" que llevará el historial de las compras que los clientes
hacen de los paneles.
*/
USE PanelesSolares_ELGG;
Go
CREATE TABLE Pedidos (ID_pedido INT PRIMARY KEY NOT NULL, 
fk_ID_panel VARCHAR(4) FOREIGN KEY REFERENCES PanelSolar(ID_panel),
fk_DNI_cliente VARCHAR(9) FOREIGN KEY REFERENCES Cliente(DNI_cliente),
fecha_pedido DATETIME2 GENERATED ALWAYS AS ROW START,
fin_seguimiento DATETIME2 GENERATED ALWAYS AS ROW END,
PERIOD FOR SYSTEM_TIME (fecha_pedido, fin_seguimiento)
) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=dbo.historialPedidos));
GO
SELECT * FROM PanelSolar;SELECT * FROM Cliente;
GO
INSERT INTO Pedidos (ID_pedido, fk_ID_panel, fk_DNI_cliente)
VALUES (1000001, 'A001','22334455A');
GO
SELECT * FROM Pedidos;
GO
--ID_pedido	fk_ID_panel	fk_DNI_cliente	fecha_pedido	fin_seguimiento
--1000001	A001	22334455A	2021-06-10 01:26:59.1141226	9999-12-31 23:59:59.9999999
--
/*
La siguiente tabla temporal guarda un seguimiento de las actividades de los técnicos.
Primero creo la tabla "Técnico" y luego la tabla temporal "actividades".
*/
CREATE TABLE Tecnico (
DNI_tecnico VARCHAR(9) PRIMARY KEY NOT NULL,
nombre_tc CHAR(20), apellidos_tc CHAR(30), telefono_tc NUMERIC(9), especialidad_tc CHAR(20));
Go
-- Cualquier coincidencia con datos reales es casual:
INSERT INTO Tecnico VALUES ('44332288B', 'Jose', 'Bermundez López', 677223149, 'electricista');
SELECT * FROM Tecnico;
GO
--DNI_tecnico	nombre_tc	apellidos_tc	telefono_tc	especialidad_tc
--44332288B	Jose                	Bermundez López               	677223149	electricista
--
CREATE TABLE actividades (numero_actividad INT PRIMARY KEY NOT NULL, 
fk_ID_panel VARCHAR(4) FOREIGN KEY REFERENCES PanelSolar(ID_panel),
fk_DNI_tecnico VARCHAR(9) FOREIGN KEY REFERENCES Tecnico(DNI_tecnico),
comienzo_actividad DATETIME2 GENERATED ALWAYS AS ROW START,
fin_seguimiento DATETIME2 GENERATED ALWAYS AS ROW END,
PERIOD FOR SYSTEM_TIME (comienzo_actividad, fin_seguimiento)
) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=dbo.historialActividades));
GO
INSERT INTO actividades(numero_actividad, fk_ID_panel, fk_DNI_tecnico)
VALUES (2000001, 'A001','44332288B');
SELECT * FROM actividades;
GO
--numero_actividad	fk_ID_panel	fk_DNI_tecnico	comienzo_actividad	fin_seguimiento
--2000001	A001	44332288B	2021-06-10 01:46:58.6967795	9999-12-31 23:59:59.9999999
DROP DATABASE IF EXISTS PanelesSolares_ELGG;
GO
CREATE DATABASE PanelesSolares_ELGG;
GO
USE PanelesSolares_ELGG;
GO
CREATE TABLE PanelSolar (
ID_panel VARCHAR(4) PRIMARY KEY NOT NULL,
tipo_panel CHAR(20) NOT NULL);
GO
CREATE TABLE Cliente (
DNI_cliente VARCHAR(9) PRIMARY KEY NOT NULL,
nombre_cl CHAR(20), apellidos_cl CHAR(30),
telefono_cl NUMERIC(9) NOT NULL, direccion_cl CHAR(50) NOT NULL,
ID_compra_cl VARCHAR(4) FOREIGN KEY REFERENCES PanelSolar(ID_panel) NOT NULL
);
GO
-- Cualquier coincidencia con datos reales es casual:
INSERT INTO PanelSolar VALUES ('A001', 'fotovoltaico');
INSERT INTO Cliente
VALUES ('22334455A','Alejandro','Silvestro Vegas',987621122,
'CL omega diez, BJ, 1', 'A001');
GO
SELECT * FROM PanelSolar;SELECT * FROM Cliente;
GO
--ID_panel	tipo_panel
--A001	fotovoltaico        

--DNI_cliente	nombre_cl	apellidos_cl	telefono_cl	direccion_cl	ID_compra_cl
--22334455A	Alejandro           	Silvestro Vegas               	987621122	CL omega diez, BJ, 1   	A001
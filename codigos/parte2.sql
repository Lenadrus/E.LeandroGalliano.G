/*
Crearé la tabla temporal "Pedidos" que llevará el historial de las compras que los clientes
hacen de los paneles.
*/
USE PanelesSolares_ELGG;
Go
CREATE TABLE Pedidos (ID_pedido INT PRIMARY KEY NOT NULL, -- Ésta PK es un anzuelo.
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
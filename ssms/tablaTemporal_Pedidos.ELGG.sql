-- Por E. Leandro Galliano G.
USE PanelesSolares_ELGG;
GO
CREATE TABLE Pedidos (
ID_pedido INT PRIMARY KEY NOT NULL, -- Ésta clave es un anzuelo para que pueda crearse la tabla.
ID_cliente NVARCHAR(9) FOREIGN KEY REFERENCES Cliente(DNI_cliente) NOT NULL,
ID_compra VARCHAR(4) NOT NULL,
CONSTRAINT compra FOREIGN KEY (ID_compra) REFERENCES PanelSolar(ID_panel),
momentoCompra DATETIME2 GENERATED ALWAYS AS ROW START,
caduca DATETIME2 GENERATED ALWAYS AS ROW END,
PERIOD FOR SYSTEM_TIME (momentoCompra, caduca)
) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.historialPedidos));

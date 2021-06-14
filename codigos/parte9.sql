USE PanelesSolares_ELGG;
GO
--
-- Enmascararé los precios de dos nuevas tablas; Acumulador y Caldera.
CREATE TABLE Acumulador ( ID_acumulador VARCHAR(2) PRIMARY KEY,
capacidad_en_volumen NUMERIC(3), precio_acumulador MONEY MASKED WITH (FUNCTION = 'random(1,50)'),
abastece VARCHAR(4) FOREIGN KEY REFERENCES PanelSolar(ID_panel) 
);
GO
--
SELECT * FROM Acumulador;
GO
--ID_acumulador	capacidad_en_volumen	precio_acumulador	abastece
CREATE TABLE Caldera (ID_caldera VARCHAR(5) PRIMARY KEY,
tipo_caldera CHAR(20), precio_caldera MONEY MASKED WITH (FUNCTION = 'default()'),
auxilia VARCHAR(2) FOREIGN KEY REFERENCES Acumulador(ID_acumulador)
);
SELECT * FROM Caldera;
Go
SELECT * FROM Acumulador;SELECT * FROM Caldera;
GO
--ID_caldera	tipo_caldera	precio_caldera	auxilia
INSERT INTO Acumulador VALUES ('A',300,120,'M001');
GO
INSERT INTO Caldera VALUES ('CAL01', 'gas',50,'A');
GO
-- Creo un usuario de pruebas "Ficticius" para comprobar el enmascaramiento:
CREATE USER Ficticius WITHOUT LOGIN;
GO
--
GRANT SELECT ON DATABASE::PanelesSolares_ELGG TO Ficticius;
EXECUTE AS USER = 'Ficticius';
GO
SELECT * FROM Acumulador;-- El precio debería ser "120".
GO
--ID_acumulador	capacidad_en_volumen	precio_acumulador	abastece
--A	300	8,4686	M001
SELECT * FROM Caldera;-- El precio debería ser "50".
GO
--ID_caldera	tipo_caldera	precio_caldera	auxilia
--CAL01	gas                 	0,00	A
/*
Ahora voy a utiliar las funciones restantes de DDM: email(), y partial().
*/
PRINT USER;-- Ficticius
REVERT;
ALTER TABLE Cliente ALTER COLUMN DNI_cliente ADD MASKED WITH (
FUNCTION = 'email()');
GO
ALTER TABLE tecnico ALTER COLUMN DNI_tecnico ADD MASKED WITH (
FUNCTION = 'partial(0,"XXXXXXX",8)');
GO
EXECUTE AS USER = 'Ficticius';
GO
SELECT * FROM Tecnico;
--DNI_tecnico	nombre_tc	apellidos_tc	telefono_tc	especialidad_tc
--XXXXXXX43	Jose                	Bermundez López               	677223149	electricista             
SELECT * FROM Cliente;
GO
--DNI_cliente	nombre_cl	apellidos_cl	telefono_cl	direccion_cl	ID_compra_cl
--2XXX@XXXX	Alejandro           	Silvestro Vegas               	987621122	CL omega diez, BJ, 1    	A001 
--
SELECT * FROM Cliente;SELECT * FROM Tecnico;
REVERT;
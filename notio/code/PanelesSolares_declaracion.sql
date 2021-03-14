CREATE DATABASE PanelesSolares;

USE PanelesSolares;

CREATE TABLE Cliente(DNI_cl VARCHAR(9) PRIMARY KEY NOT NULL, nomCompleto_cl CHAR(50) NOT NULL, num_orden INT(10) NOT NULL,
dir_cliente VARCHAR(50) NOT NULL, telf_cl INT (10));

CREATE TABLE Tecnico(DNI_tec VARCHAR(9) PRIMARY KEY NOT NULL, nomCompleto_tec CHAR(50) NOT NULL, especialidad_tec CHAR(20), 
telf_tec INT(10) NOT NULL);

CREATE TABLE PanelSolar(ID_panel VARCHAR(7) PRIMARY KEY NOT NULL);

CREATE TABLE PanelTermico(ID_panel VARCHAR(7) NOT NULL, marca_colector CHAR(12), modelo_colector CHAR(12), longitud_tuberia INT(10) NOT NULL, 
FOREIGN KEY (ID_panel) REFERENCES PanelSolar(ID_panel));

CREATE TABLE Acumulador(ID_acumu VARCHAR(8) NOT NULL PRIMARY KEY, marca_acumulador CHAR(12), modelo_acumulador CHAR(12), capacidad_acumulador INT(10));

CREATE TABLE Caldera(ID_cald VARCHAR(5) PRIMARY KEY NOT NULL, marca_caldera CHAR(12), modelo_caldera CHAR(12), 
tipo_caldera CHAR(12) NOT NULL);

CREATE TABLE PanelFotovoltaico(ID_panel VARCHAR(7) NOT NULL, marca_fotovoltaico CHAR(12), modelo_fotovoltaico CHAR(12), potencia_fotovoltaico INT(10) NOT NULL, 
FOREIGN KEY (ID_panel) REFERENCES PanelSolar(ID_panel));

CREATE TABLE Bateria(ID_bateria VARCHAR(4) PRIMARY KEY NOT NULL, tipo_bateria CHAR(12) NOT NULL);

ALTER TABLE Cliente ADD CONSTRAINT `compra` FOREIGN KEY (num_orden) REFERENCES PanelSolar(ID_panel);

ALTER TABLE Tecnico ADD CONSTRAINT `instala` FOREIGN KEY (orden_servicio) REFERENCES PanelSolar(ID_panel);

ALTER TABLE IF EXISTS Termico RENAME PanelTermico; -- Creí recordar que lo había creado como "Térmico"

ALTER TABLE PanelTermico ADD COLUMN acumulador VARCHAR(8);

ALTER TABLE PanelTermico ADD CONSTRAINT `abastece` FOREIGN KEY (acumulador) REFERENCES Acumulador(ID_acumu);

ALTER TABLE Acumulador ADD COLUMN caldera VARCHAR(5);

ALTER TABLE Acumulador ADD CONSTRAINT `sistema_auxiliar` FOREIGN KEY (caldera) REFERENCES Caldera(ID_cald);

ALTER TABLE PanelFotovoltaico ADD COLUMN bateria VARCHAR(4);

ALTER TABLE PanelFotovoltaico ADD CONSTRAINT `almacena` FOREIGN KEY (bateria) REFERENCES Bateria(ID_bateria);

INSERT INTO PanelSolar(ID_panel) VALUES('1000001');

INSERT INTO PanelSolar(ID_panel) VALUES('1000002');

INSERT INTO PanelSolar(ID_panel) VALUES('1000003');

INSERT INTO PanelSolar(ID_panel) VALUES('1000004');


INSERT INTO Cliente(DNI_cl, nomCompleto_cl, num_orden, dir_cliente, telf_cl) 
	VALUES('31754296G','Carmen Abedul Gracia','1000002','CM del Bosque 7, bajo',686224461);

INSERT INTO Cliente(DNI_cl, nomCompleto_cl, num_orden, dir_cliente, telf_cl) 
	VALUES('34567812F','Cristian Dual Fe','1000003','PZ Nieto 1, bajo',657224332);

INSERT INTO Cliente(DNI_cl, nomCompleto_cl, num_orden, dir_cliente, telf_cl) 
	VALUES('24682468B','Beatriz Diaspora','1000004','CL Exilio 21, bajo',622389911);

INSERT INTO Tecnico(DNI_tec, nomCompleto_tec, especialidad_tec, telf_tec, orden_servicio)
	VALUES('54678231S','Lucas Vela','electricista',692542671,'1000002');

INSERT INTO Tecnico(DNI_tec, nomCompleto_tec, especialidad_tec, telf_tec, orden_servicio) 
	VALUES('43278543U','Domingo Quilo','fontanero',643547982,'1000004');

INSERT INTO Acumulador(ID_acumu,marca_acumulador,modelo_acumulador,capacidad_acumulador)
	VALUES('10001-AA','Aqumas', 'AA-01', 100);

INSERT INTO Acumulador(ID_acumu,marca_acumulador,modelo_acumulador,capacidad_acumulador) 
	VALUES('10002-AA','Aqumas','AA-02',300);

INSERT INTO Caldera(ID_cald,marca_caldera,modelo_caldera,tipo_caldera) 
	VALUES('10-CH','Hetas','CH-01','electrica');

INSERT INTO Caldera(ID_cald,marca_caldera,modelo_caldera,tipo_caldera) 
	VALUES('11-CH','Hetas','CH-02','gasn');

INSERT INTO PanelTermico(ID_panel, marca_colector,modelo_colector,longitud_tuberia,acumulador) 
	VALUES('1000002','Fermas','CSF-01',30,'10001-AA');

INSERT INTO PanelTermico(ID_panel, marca_colector,modelo_colector,longitud_tuberia,acumulador) 
	VALUES('1000004','Fermas','CSF-01',35,'10002-AA');

INSERT INTO Bateria(ID_Bateria, tipo_bateria) 
	VALUES('B401','ion-litio');

INSERT INTO Bateria(ID_Bateria, tipo_bateria) 
	VALUES('B201','plomo-acido');

INSERT INTO PanelFotovoltaico(ID_panel,marca_fotovoltaico,modelo_fotovoltaico,potencia_fotovoltaico,bateria) 
    VALUES(1000001,'Fermas','PF-01',50,'B201');

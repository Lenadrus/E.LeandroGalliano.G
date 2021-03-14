USE master
GO
DROP DATABASE IF EXISTS CAR
GO
CREATE DATABASE CAR
GO
USE CAR
GO
-----------------
DROP TABLE IF EXISTS CarInventory
GO
DROP TABLE IF EXISTS CarInventoryHistory
GO

-----------------
CREATE TABLE CarInventory
(
	CarId INT IDENTITY PRIMARY KEY,
		Year INT,
		Make VARCHAR(40),
		Model VARCHAR(40),
		Color VARCHAR(10),
		Mileage INT, -- "Mileage" = "kilometraje"
		InLot BIT NOT NULL DEFAULT 1,
		SysStartTime datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
		SysEndTime datetime2 GENERATED ALWAYS AS ROW END NOT NULL,
		PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime)
)
WITH
(
	SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.CarInventoryHistory)
);
GO

INSERT INTO dbo.CarInventory (Year,Make,Model,Color,Mileage)
	VALUES(2017,'Chevy','Malibu','Black',0)
INSERT INTO dbo.CarInventory (Year,Make,Model,Color,Mileage)
VALUES(2017,'Chevy','Malibu','Black',0)
GO
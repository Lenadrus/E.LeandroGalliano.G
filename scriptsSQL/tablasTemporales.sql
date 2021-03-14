

--Temporal Tables (version Sistema)
use master
go
DROP DATABASE IF EXISTS CAR
GO
CREATE DATABASE CAR
GO
USE CAR
GO
---------- 
DROP TABLE IF EXISTS CarInventory
GO
DROP TABLE IF EXISTS CarInventoryHistory
GO
----------
IF OBJECT_ID('dbo.CarInventory', 'U') IS NOT NULL 
BEGIN
    -- When deleting a temporal table, we need to first turn versioning off
    ALTER TABLE [dbo].[CarInventory] SET ( SYSTEM_VERSIONING = OFF  ) 
    DROP TABLE dbo.CarInventory
    DROP TABLE dbo.CarInventoryHistory
END
--------------
CREATE TABLE CarInventory   
(    
    CarId INT IDENTITY PRIMARY KEY,
    Year INT,
    Make VARCHAR(40),
    Model VARCHAR(40),
    Color varchar(10),
    Mileage INT,
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
SELECT * FROM CarInventory
GO
SELECT * FROM [CarInventoryHistory]
GO


INSERT INTO dbo.CarInventory (Year,Make,Model,Color,Mileage)
 VALUES(2017,'Chevy','Malibu','Black',0)
INSERT INTO dbo.CarInventory (Year,Make,Model,Color,Mileage) 
VALUES(2017,'Chevy','Malibu','Silver',0)
GO

SELECT * FROM CarInventory
GO
--CarId	Year	Make	Model	Color	Mileage	InLot	SysStartTime					SysEndTime
--1		2017	Chevy	Malibu	Black	0			1	2021-01-17 18:50:34.3437580	9999-12-31 23:59:59.9999999
--2		2017	Chevy	Malibu	Silver	0			1	2021-01-17 18:50:34.3437580	9999-12-31 23:59:59.9999999
SELECT * FROM [CarInventoryHistory]
GO

-- CarId	Year	Make	Model	Color	Mileage	InLot	SysStartTime	SysEndTime

-- You'll notice that since we've only inserted one row for each our cars, there's no row history yet and therefore our historical table is empty.

-- Let's change that by getting some customers and renting out our cars!

UPDATE dbo.CarInventory SET InLot = 0 WHERE CarId = 1
UPDATE dbo.CarInventory SET InLot = 0 WHERE CarId = 2
GO
SELECT * FROM CarInventory
GO
SELECT * FROM [CarInventoryHistory]
GO
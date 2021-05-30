USE PanelesSolares_ELGG;
GO
-- Creo una master key de mi BD para poder realizar tareas de encriptación:
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Abcd1234.';
--
CREATE CERTIFICATE certificarPlaca 
   WITH SUBJECT = 'Certificar cada placa.';  
GO  

CREATE SYMMETRIC KEY clavePlaca
    WITH ALGORITHM = AES_256  
    ENCRYPTION BY CERTIFICATE certificarPlaca;  
GO  

-- Creo una columna en la que guardar el dato encriptado. 
ALTER TABLE placaSolar
    ADD COLUMN precioPlaca MONEY;   
GO  

-- Abro la clave simétrica con la que encriptar el dato:
OPEN SYMMETRIC KEY clavePlaca1 
   DECRYPTION BY CERTIFICATE certificarPlaca;  
--
-- Encripto el valor en la columna usando el certificado, y
-- Guardo el resultado en la columna.  
--  
UPDATE placaSolar
SET precioPlaca = EncryptByKey(ID_placa('clavePlaca'));
GO  
--
-- Verifico la encriptación :
OPEN SYMMETRIC KEY clavePlaca 
   DECRYPTION BY CERTIFICATE certificarPlaca;  
GO 
INSERT INTO placaSolar(ID_placa, tipo_placa, precioPlaca)
VALUES (1001, 'silicio', 150);
GO
SELECT * FROM placaSolar;
Go
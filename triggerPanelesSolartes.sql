CREATE TRIGGER asignacion_panel
AFTER INSERT ON PanelesSolares.PanelSolar FOR EACH ROW
BEGIN 
    DECLARE colector CHAR(12) 
    DECLARE placa CHAR(12)
    DECLARE tipopanel CHAR(12)
    DECLARE idpanel INT
    SET colector = 'termico'
    SET placa = 'fotovoltaico'
    SET tipoPanel = (SELECT tipo_panel FROM PanelSolar)
    SET IDpanel = (SELECT ID_panel FROM PanelSolar)
    IF (tipo_panel = colector) {INSERT INTO PanelTermico(ID_panel) VALUES(IDpanel)}
    ELSE IF (tipo_panel = placa) {INSERT INTO PanelFotovoltaico(ID_panel) VALUES(ID_panel)}
END 
AS 
    SELECT 'Es obligatorio asignar un tipo en PanelSolar, de manera que el ID del panel se asigne automáticamente al subtipo de entidad que le corresponde, para distinguir qué ID corresponde a un panel termico y cuál a un fotovoltaico.';

USE [master]
GO
--
CREATE SERVER AUDIT auditar_usuario_test
TO FILE 
( FILEPATH = 'C:\audit'
 ,MAXSIZE = 100 MB
 ,MAX_ROLLOVER_FILES = 2147483647
 ,RESERVE_DISK_SPACE = OFF
)
WITH
( QUEUE_DELAY = 1000
 ,ON_FAILURE = CONTINUE
)
GO
--
ALTER SERVER AUDIT auditar_usuario_test with(State=ON)
GO
--
Use PanelesSolares_ELGG;
GO
--
CREATE DATABASE AUDIT SPECIFICATION probar_auditoria_BD
FOR SERVER AUDIT auditar_usuario_test
ADD (USER_DEFINED_AUDIT_GROUP)
With(State=ON)
GO
--
SELECT * FROM PanelSolar;
GO
INSERT INTO PanelSolar VALUES ('M002','termico');
GO
SELECT * FROM sys.fn_get_audit_file('C:\audit\*', NULL, NULL);
GO
--event_time	sequence_number	action_id	succeeded	permission_bitmask	is_column_permission	session_id	server_principal_id	database_principal_id	target_server_principal_id	target_database_principal_id	object_id	class_type	session_server_principal_name	server_principal_name	server_principal_sid	database_principal_name	target_server_principal_name	target_server_principal_sid	target_database_principal_name	server_instance_name	database_name	schema_name	object_name	statement	additional_information	file_name	audit_file_offset	user_defined_event_id	user_defined_information	audit_schema_version	sequence_group_id	transaction_id	client_ip	application_name	duration_milliseconds	response_rows	affected_rows
--2021-06-14 05:21:44.5878656	1	AUSC	1	0x00000000000000000000000000000000	0	56	1	0	0	0	0	A 	sa	sa	0x01			NULL		CLIENTEELGG					<action_info xmlns="http://schemas.microsoft.com/sqlserver/2008/sqlaudit_data"><session><![CDATA[auditar_usuario_test$A]]></session><action>event enabled</action><startup_type>manual</startup_type><object><![CDATA[audit_event]]></object></action_info>	C:\audit\auditar_usuario_test_CA2C3FB5-94FF-4059-BC66-5F87DBDE21FB_0_132681217040230000.sqlaudit	5632	0		1	0x00000000000000000000000000000000	0	local machine		0	0	0
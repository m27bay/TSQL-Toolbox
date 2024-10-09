-- ==============================================================
-- Author:      Mickael LE DENMAT
-- Create date: 09/10/2024
-- Description: Script InsertSysMessage
-- ==============================================================
begin tran
	select 'before'
	select * from sys.messages where message_id > 50000;

	declare @MsgNum int = 1;

	/*
	 EN : "It is mandatory to add a message in English before 
	 	other languages if the server language is English."
	 FR : Il est impératif d'ajouter un message en anglais avant 
	 	d'autres langues si la langue du serveur est l'anglais.
	 */
	exec sp_addmessage
		@msgnum = @MsgNum,
		@severity = 11,
		@msgtext = 'toto',
		@lang = 'us_english';

	exec sp_addmessage
		@msgnum = @MsgNum,
		@severity = 11,
		@msgtext = 'toto',
		@lang = 'French';

	select 'after'
	select * from sys.messages where message_id > 50000;
rollback
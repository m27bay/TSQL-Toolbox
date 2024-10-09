-- ==============================================================
-- Author:      Mickael LE DENMAT
-- Create date: 09/10/2024
-- Description: Stored procedure fc_DBCTRL_RemovingAccentFromString
-- ==============================================================
/*
 EN : Change the COLLATE to one that ignores accents.
 FR : Modifier la COLLATE pour en utiliser une qui ignore les accents.
 */
create function fc_DBCTRL_RemovingAccentFromString
(
	@String varchar(max)
)
returns varchar(max)
as
begin
	 RETURN CAST(@String AS VARCHAR(MAX)) COLLATE SQL_Latin1_General_CP1251_CS_AS;
end;
   
/*
 EN : Replace accents one by one.
 FR : Remplacer les accents un par un.
 */
-- create function fc_DBCTRL_RemovingAccentFromString
-- (
-- 	@String varchar(max)
-- )
-- returns varchar(max)
-- as
-- begin
-- 	declare @StringOutput varchar(max);
-- 
-- 	set @StringOutput = @String;
-- 	set @StringOutput = replace(@StringOutput, 'é', 'e');
-- 	set @StringOutput = replace(@StringOutput, 'è', 'e');
-- 	set @StringOutput = replace(@StringOutput, 'ç', 'c');
-- 	set @StringOutput = replace(@StringOutput, 'à', 'a');
-- 
-- 	return @StringOutput;
-- end;
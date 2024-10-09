-- ==============================================================
-- Author:      Mickael LE DENMAT
-- Create date: 09/10/2024
-- Description: Function fc_SYSCTRL_CheckRegex
-- ==============================================================
create function dbo.fc_SYSCTRL_CheckRegex
(
	@InputString VARCHAR(MAX),
	@Regex VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @OutputString VARCHAR(MAX) = '';

	DECLARE 
		@IndexChar INT = 0,
		@InputChar CHAR,
		@OutputChar CHAR;

	WHILE @IndexChar <= LEN(@InputString)
	BEGIN
		SET @InputChar = SUBSTRING(@InputString, @IndexChar, 1);

		-- Check if @InputChar exists in the @Regex list
		IF CHARINDEX(@InputChar, @Regex) > 0
			OR @InputChar = ' '

			SET @OutputString += @InputChar;
		ELSE
			SET @OutputString += ' ';

		SET @IndexChar += 1;
	END;

	RETURN @OutputString;
END;
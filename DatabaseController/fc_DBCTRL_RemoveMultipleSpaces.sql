-- ==============================================================
-- Author:      Mickael LE DENMAT
-- Create date: 09/10/2024
-- Description: Function fc_DBCTRL_RemoveMultipleSpaces
-- ==============================================================
create function dbo.fc_DBCTRL_RemoveMultipleSpaces
(
	@inputString VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @cleanedString VARCHAR(MAX)

	SET @cleanedString = @inputString;

	-- Remove multiple spaces
	WHILE PATINDEX('%  %', @cleanedString) > 0
	BEGIN
		SET @cleanedString = REPLACE(@cleanedString, '  ', ' ');
	END

	RETURN LTRIM(RTRIM(@cleanedString));
END;
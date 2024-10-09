-- ==============================================================
-- Author:      Mickael LE DENMAT
-- Create date: 09/10/2024
-- Description: Function ps_DBCTRL_RandomVarchar
-- ==============================================================
create function dbo.ps_DBCTRL_RandomVarchar
	@minLen		INT = 1
    ,@maxLen	INT = 8000
    ,@string	VARCHAR(max) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @length AS INT;
    DECLARE @alpha AS VARCHAR(max), 
			@digit AS VARCHAR(max), 
			@specials AS VARCHAR(max), 
			@first AS VARCHAR(max)
    DECLARE @step AS BIGINT = RAND() * 2147483647;

    SELECT	@alpha = 'qwertyuiopASdfghjklzxcvbnm', 
			@digit = '1234567890', 
			@specials = '_@# '
    SELECT	@first = @alpha + '_@';

    SELECT	@length = @minLen + RAND() * (@maxLen-@minLen)

    DECLARE	@dice AS INT;
    SELECT	@dice = RAND() * len(@first)
    SELECT	@string = substring(@first, @dice, 1);

    WHILE	0 < @length 
    BEGIN
        SELECT	@dice = RAND() * 100

        IF		(@dice < 10) -- 10% special chars
        BEGIN
            SELECT	@dice = RAND() * len(@specials)+1
            SELECT	@string = @string + substring(@specials, @dice, 1);
        END
        ELSE IF		(@dice < 10+10) -- 10% digits
        BEGIN
            SELECT	@dice = RAND() * len(@digit)+1
            SELECT	@string = @string + substring(@digit, @dice, 1);
        END
        ELSE -- rest 80% alpha
        BEGIN
            SELECT	@dice = RAND() * len(@alpha)+1;

            SELECT	@string = @string + substring(@alpha, @dice, 1);
        END

        SELECT	@length = @length - 1;   
    END
END
GO
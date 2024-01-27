
-- не используется
-- USE [AXJW12_DEV2_model]
-- GO

IF OBJECT_ID (N'dbo.aMRC_posByCount2') IS NOT NULL
   DROP FUNCTION dbo.aMRC_posByCount2
GO

CREATE FUNCTION dbo.aMRC_posByCount2 (@bytesStr nvarchar(max), @_occurence int)
RETURNS int
WITH EXECUTE AS CALLER
AS
BEGIN
    declare	@ret int;
    declare	@counter int;
	declare	@propsLen int;
	declare	@step int;
    declare	@value nvarchar(4);
    declare	@j int;
	declare	@_str2Find nvarchar(4);
    ;

	set @ret = 0;
	set @counter = 0;
	set @propsLen = len(@bytesStr);
	set @step = 2 * 2;
	set @value = N'';
	set @_str2Find = N'0000';

	set @j = 1 + 2;
	while @j <= @propsLen and @counter < @_occurence
	begin
		set @value = SUBSTRING(@bytesStr, @j, 4);

		if (@value = @_str2Find)
        begin
            set @ret = @j;
            set @counter = @counter + 1;

            if (@counter >= @_occurence)
            begin
                break;
            end
        end
		set @j = @j + @step;
    end

    if (not (@counter >= @_occurence) or @_occurence <= 0)
    begin
        set @ret = 0;
    end

    return @ret;
END
GO

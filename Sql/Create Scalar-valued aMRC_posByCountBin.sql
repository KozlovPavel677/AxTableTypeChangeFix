-- JEV007444 "Tech_Сделать защиту от изменения типа таблицы в аксапте", PKoz 23.01.2024
-- https://axforum.info/forums/showthread.php?p=426156#post426156

-- USE [AXJW12_DEV2_model]
-- GO

IF OBJECT_ID (N'dbo.aMRC_posByCountBin') IS NOT NULL
   DROP FUNCTION dbo.aMRC_posByCountBin
GO

CREATE FUNCTION dbo.aMRC_posByCountBin (@bytes varbinary(max), @_occurence int)
RETURNS int
WITH EXECUTE AS CALLER
AS
BEGIN
    declare	@ret int;
    declare	@counter int;
	declare	@propsLen int;
	declare	@step int;
    declare	@value varbinary(4);
    declare	@j int;
	declare	@_str2Find varbinary(4);
    ;

	set @ret = 0;
	set @counter = 0;
	set @propsLen = DATALENGTH(@bytes);
	set @step = 2;
	set @value = 0x00;
	set @_str2Find = 0x0000;

	set @j = 2;
	while @j <= @propsLen and @counter < @_occurence
	begin
		set @value = SUBSTRING(@bytes, @j, 2);

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

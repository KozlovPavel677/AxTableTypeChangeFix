-- JEV007444 "Tech_Сделать защиту от изменения типа таблицы в аксапте", PKoz 23.01.2024
-- https://axforum.info/forums/showthread.php?p=426156#post426156

-- USE [AXJW12_DEV2_model]
-- GO

IF OBJECT_ID (N'dbo.aMRC_axTableType') IS NOT NULL
   DROP FUNCTION dbo.aMRC_axTableType
GO

CREATE FUNCTION dbo.aMRC_axTableType (@bytes varbinary(max))
RETURNS int 
/*
	0 - Unknown
	1 - Table
	2 - View
	3 - Map
*/
WITH EXECUTE AS CALLER
AS
BEGIN
	declare	@byte1 tinyint = 0;
	declare	@byte2 tinyint = 0;
	declare	@byte3 tinyint = 0;
	declare	@byte4 tinyint = 0;

	declare	@occurence0 int = 0;
	declare	@j0 int = 0;
	declare	@j  int = 0;
	declare	@internalOffset int = 0;
	declare	@tableTypeOffset int = 0;

	declare	@tableType tinyint = 0;

	set @byte1 = SUBSTRING(@bytes, 3, 1);
	set @occurence0 = @byte1 - 1;

    if (@occurence0 >= 1)
    begin
        select @j0 = [dbo].[aMRC_posByCountBin](@bytes, @occurence0); -- смещение для группы настроек №2 (4 байта)
    end
    else
    begin
        set @j0 = 2;
    end

    -- теперь определяем смещение для группы настроек №3 (оттуда возьмем байт, определяющий тип табличного буфера Table / View / Map)
    set @internalOffset = 0;
    set @byte1 = SUBSTRING(@bytes, @j0 + 2, 1); -- 1-й байт из настроек №2
    set @byte2 = SUBSTRING(@bytes, @j0 + 3, 1); -- 2-й байт из настроек №2
    set @byte3 = SUBSTRING(@bytes, @j0 + 4, 1); -- 3-й байт из настроек №2
    set @byte4 = SUBSTRING(@bytes, @j0 + 5, 1); -- 4-й байт из настроек №2

    if ((@byte1 & 0x4) != 0) -- 0b00000100 -- заполнено TitleField1
    begin
        set @internalOffset = @internalOffset + 1;
    end
    if ((@byte1 & 0x8) != 0) -- 0b00001000 -- заполнено TitleField2
    begin
        set @internalOffset = @internalOffset + 1;
    end
    if ((@byte4 & 0x8) != 0) -- 0b00001000 -- заполнено Extends
    begin
        set @internalOffset = @internalOffset + 1;
    end

    if (@internalOffset != 0)
    begin
        select @j = [dbo].[aMRC_posByCountBin](@bytes, @occurence0 + @internalOffset);
    end
    else
    begin
        set @j = @j0 + 4; -- это начало "0000" для случая когда не заполнено ни одно из значение Title1, Title2, Extends
    end

    set @tableTypeOffset = 2;
    if ((@byte1 & 0x10) != 0) -- b00010000 -- заполнено Visible
    begin
        set @tableTypeOffset = @tableTypeOffset + 1;
    end
    if ((@byte1 & 0x20) != 0) -- 0b00100000 -- заполнено CacheLookup
    begin
        set @tableTypeOffset = @tableTypeOffset + 1;
    end

    if ((@byte1 & 0x02) != 0    -- 0b00000010 -- есть дочерние DeleteActions
        AND
        (@byte1 & 0x04) = 0 AND -- b00000100 -- и пустое поле TitleField1
        (@byte1 & 0x08) = 0     -- b00001000 -- и пустое поле TitleField2
        )
    begin
        set @tableTypeOffset = @tableTypeOffset + 2; -- добавили смещение в 2 байта (в нем хранится число DeleteActions)
    end

	set @tableType = SUBSTRING(@bytes, @j + @tableTypeOffset, 1);

	if (@tableType = 0x80 OR -- Regular table
	    @tableType = 0x40 OR -- TempDb table
	    @tableType = 0x02    -- InMemory table
		)
	begin
		return 1; -- table
	end

	if (@tableType = 0x04) -- View
	begin
		return 2; -- View
	end

	if (@tableType = 0x01) -- Map
	begin
		return 3; -- Map
	end

	return 0; -- Unknown
END
GO

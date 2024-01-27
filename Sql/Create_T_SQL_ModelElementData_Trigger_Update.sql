-- JEV007444 "Tech_������� ������ �� ��������� ���� ������� � �������", PKoz 23.01.2024
-- https://axforum.info/forums/showthread.php?p=426156#post426156

-- USE [AXJW12_DEV2_model]
-- GO

IF OBJECT_ID ('dbo.ModelElementData_Trigger_Update_MRC','TR') IS NOT NULL
   DROP TRIGGER dbo.ModelElementData_Trigger_Update_MRC
GO

CREATE TRIGGER dbo.ModelElementData_Trigger_Update_MRC
   ON  dbo.ModelElementData
   AFTER UPDATE
AS 

-- https://learn.microsoft.com/ru-ru/sql/t-sql/statements/create-trigger-transact-sql?view=sql-server-ver16
if (ROWCOUNT_BIG() = 0) -- ������ ���� �� ������ ����� ���� �� SET NOCOUNT ON; ����� ������ ������ 0 � ������� �� ������������
begin
	return
end

-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

If (NOT UPDATE(Properties))
begin
	return
end

IF NOT EXISTS (SELECT 1  -- ���� ������ ������ ���������� ������, ���� �� ���-�� ������, �� �������� ��� ������� ����
           FROM inserted AS i, deleted AS d   
           WHERE	i.ElementHandle =  d.ElementHandle
				AND	i.LayerId		=  d.LayerId
				AND i.Properties	!= d.Properties
				-- AND i.ElementHandle in (1388458, 1388460, 1388462) -- ���������� ����������� ������
				AND EXISTS (
					SELECT 1 
					FROM ModelElement AS me
					WHERE	me.ElementHandle = i.ElementHandle
						AND me.ElementType   = 44
				)
          )
begin
	return
end

declare @axTableTypeI as int;
declare @axTableTypeD as int;
declare @tableName as nvarchar(510); -- ModelElement.Name
declare @errorMsg as nvarchar(440);

SELECT 
@axTableTypeI = [dbo].[aMRC_axTableType](i.Properties),
@axTableTypeD = [dbo].[aMRC_axTableType](d.Properties),
@tableName    = me.Name
FROM inserted AS i, deleted AS d, ModelElement AS me
WHERE	i.ElementHandle =  d.ElementHandle
	AND	i.LayerId		=  d.LayerId
	AND i.Properties	!= d.Properties
	AND [dbo].[aMRC_axTableType](i.Properties) != [dbo].[aMRC_axTableType](d.Properties)
	AND me.ElementHandle = i.ElementHandle
	AND me.ElementType   = 44
	-- AND i.ElementHandle in (1388458, 1388460, 1388462) -- ���������� ����������� ������
	;

if (@axTableTypeI is null)
begin
	return -- ok
end

if (@axTableTypeI != @axTableTypeD)
begin
	set @errorMsg = N'Axapta kernel has gone crazy. It tries to change the table type from ' + 
		CAST(@axTableTypeD as nvarchar(max)) + N' to ' + CAST(@axTableTypeI as nvarchar(max)) + N' for axtable ' + @tableName;

	-- RAISERROR (@errorMsg, 16, 1) -- � ���� ��������� ��� ������� ����� ������� ������ - �� ��� ������� ������ �� �� ����� ������� � ������ �������� �� ���, � ����� �����
	/*
	���������� ��� ��� (� ��� ������������ �� ������ �������� � ����)
	Object Server 01: The database reported (session 17 (PKoz)): [Microsoft][SQL Server Native Client 11.0][SQL Server]Invalid object name 'SYSINFOLOGHISTORY_MRC'.. The SQL statement was: "INSERT INTO SYSINFOLOGHISTORY_MRC (INFO,USERID,COMPANYID,COMPUTERNAME,EXCEPTIONTYPE,CREATEDDATETIME,DEL_CREATEDTIME,RECVERSION,PARTITION,RECID) VALUES (?,?,?,?,?,?,?,?,?,?)"

	����� ������������ ����� ������ � �������� ����
	Object Server 01: The database reported (session 1 (-AOS-)): [Microsoft][SQL Server Native Client 11.0][SQL Server]Invalid object name 'SYSLASTVALUE'.. The SQL statement was: "SELECT T1.USERID,T1.RECORDTYPE,T1.ELEMENTNAME,T1.DESIGNNAME,T1.ISKERNEL,T1.COMPANY,T1.RECVERSION,T1.PARTITION,T1.RECID,T1.VALUE FROM SYSLASTVALUE T1 WHERE ((PARTITION=5637144576) AND ((((RECORDTYPE=?) AND (ELEMENTNAME=?)) AND (DESIGNNAME=?)) AND (COMPANY=?)))"
	Object Server 01: The database reported (session 2 (-AOS-)): [Microsoft][SQL Server Native Client 11.0][SQL Server]Invalid object name 'SYSSERVERCONFIG'.. The SQL statement was: "SELECT TOP 1 T1.ENABLEBATCH,T1.SERVERID,T1.LOADBALANCINGENABLED,T1.CLUSTERREFRECID,101090,T2.MAXBATCHSESSIONS,T2.RECID FROM SYSSERVERCONFIG T1 CROSS JOIN BATCHSERVERCONFIG T2 WHERE (T1.SERVERID=?) AND ((T2.SERVERID=T1.SERVERID) AND ((((T2.ENDTIME>=T2.STARTTIME) AND (?>=T2.STARTTIME)) AND (?<=T2.ENDTIME)) OR ((T2.ENDTIME<T2.STARTTIME) AND ((?>=T2.STARTTIME) OR (?<=T2.ENDTIME)))))"
	� ����� ��������� ��� ����� :
	Object Server 01: The database reported (session 2 (-AOS-)): [Microsoft][SQL Server Native Client 11.0][SQL Server]Invalid object name 'SYSCLIENTSESSIONS'.. The SQL statement was: "SELECT T1.SESSIONID,T1.SERVERID,T1.VERSION,T1.LOGINDATETIME,T1.LOGINDATETIMETZID,T1.STATUS,T1.USERID,T1.SID,T1.USERLANGUAGE,T1.HELPLANGUAGE,T1.CLIENTTYPE,T1.SESSIONTYPE,T1.CLIENTCOMPUTER,T1.DATAPARTITION,T1.RECVERSION,T1.RECID FROM SYSCLIENTSESSIONS T1 WHERE (SESSIONID=?)"
	Object Server 01: The database reported (session 17 (PKoz)): [Microsoft][SQL Server Native Client 11.0][SQL Server]Invalid object name 'SYSCACHEFLUSH'.. The SQL statement was: "SELECT T1.SCOPE,T1.FLUSHVERSION,T1.MODIFIEDDATETIME,T1.RECVERSION,T1.RECID,T1.CLEARDATA,T1.FLUSHDATA FROM SYSCACHEFLUSH T1 WHERE (SCOPE=?)"
	Object Server 01: The database reported (session 1 (-AOS-)): [Microsoft][SQL Server Native Client 11.0][SQL Server]Invalid object name 'SYSCLIENTSESSIONS'.. The SQL statement was: "SELECT T1.SESSIONID,T1.SERVERID,T1.VERSION,T1.LOGINDATETIME,T1.LOGINDATETIMETZID,T1.STATUS,T1.USERID,T1.SID,T1.USERLANGUAGE,T1.HELPLANGUAGE,T1.CLIENTTYPE,T1.SESSIONTYPE,T1.CLIENTCOMPUTER,T1.DATAPARTITION,T1.RECVERSION,T1.RECID FROM SYSCLIENTSESSIONS T1 WHERE ((STATUS=?) AND (SERVERID=?))"
	����� ������� ��� ����� ��� ��� ����������� ������������.
	*/

	RAISERROR (@errorMsg, 20, 1) WITH LOG -- � ��� ��-�� severity >= 20 ������ ������ ��������� ����������, �� ����� �� ���. 
	-- ��� ����� �������� ������ � ���������. � ��� ����� ������ ��������� ���� ���.
	-- ������������ ��������, ������� ���������, ����� ����� ������ �������� ������, ��������� ������ ������� ������ 
	-- � ���� ������ ����� 
	-- Object Server 01: The database reported (session 17 (PKoz)): [Microsoft][SQL Server Native Client 11.0]������ �����. The SQL statement was: "SELECT @@ROWCOUNT"
	-- (��� ������ ��� ��� ������������ ����� ����� ������� ������������� ���������� �������� �� ������ ���� �������, ������ ��� ������ "SELECT @@ROWCOUNT" )
	-- ������ ������� �� ����� ��������, ��� ���������� � �� ��� ������� (�� ���������� SQL Server) � �������� ��������� ������ ������� � ��� �� �� ��� �������...
	-- ��, ��� ������, � ���� ������ ��� ������ ����������� ���������� � �������� ������� ���. 
	-- ��� �� �� ������� ����.
	-- https://learn.microsoft.com/en-us/sql/t-sql/language-elements/raiserror-transact-sql?view=sql-server-ver16
	-- https://learn.microsoft.com/en-us/sql/relational-databases/errors-events/database-engine-error-severities?view=sql-server-ver16
	-- Severity levels from 0 through 18 can be specified by any user. Severity levels from 19 through 25 can only be specified by members of the sysadmin fixed server role or users with ALTER TRACE permissions.
	-- ��� ������������� Severity levels = 20 ��� � ����� ������, �� ������ ��������� ����� �� SQL ��� ������ ���� !
	-- https://learn.microsoft.com/en-us/sql/t-sql/language-elements/raiserror-transact-sql?view=sql-server-ver16&redirectedfrom=MSDN#permissions

	ROLLBACK TRANSACTION; 
end
GO

ALTER TABLE [dbo].[ModelElementData] ENABLE TRIGGER [ModelElementData_Trigger_Update_MRC]
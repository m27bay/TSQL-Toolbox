create PROCEDURE ps_SYSCTRL_DropAllForeignKey
(
	@TableName	VARCHAR(MAX),
	@DropMode	BIT
)
AS -- https://www.mssqltips.com/sqlservertip/3347/drop-and-recreate-all-foreign-key-constraints-in-sql-server/
BEGIN
	declare @ErrorMsg nvarchar(250);

-- 	if not exists (
-- 		select
-- 			*
-- 		from 
-- 				sys.database_role_members rm
-- 			join sys.database_principals r 
-- 				on rm.role_principal_id = r.principal_id
-- 			join sys.database_principals u 
-- 				on rm.member_principal_id = u.principal_id
-- 		where 
-- 				u.name = USER_NAME()
-- 			and r.name = 'arc_fk_manager'
-- 	)
-- 	begin
-- 		set @ErrorMsg = quotename(USER_NAME())+' have''t permission to execute this stored procedure';
-- 		raiserror(@ErrorMsg, 11, 1);
-- 		return;
-- 	end;

	IF OBJECT_ID(@TableName, 'U') IS NULL
	BEGIN
		SET @ErrorMsg = QUOTENAME(@TableName)+' isn''t in the database';
		RAISERROR(@ErrorMsg, 11, 1);
	END;

	IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'CST_CONSTRAINT_TABLE' AND TABLE_SCHEMA = 'dbo')
	BEGIN
		CREATE TABLE CST_CONSTRAINT_TABLE -- feel free to use a permanent table
		(
			SCRIPT_ID int identity,
			DROP_SCRIPT NVARCHAR(MAX),
			CREATE_SCRIPT NVARCHAR(MAX),
			IS_DROP bit
		);
	END
  
	DECLARE @drop   NVARCHAR(MAX) = N'',
			@create NVARCHAR(MAX) = N'';

	-- drop is easy, just build a simple concatenated list from sys.foreign_keys:
	select @drop += convert(nvarchar(max), N'') + N'
	ALTER TABLE ' + QUOTENAME([schema_name]) + '.' + QUOTENAME(source_table) 
		+ ' DROP CONSTRAINT ' + QUOTENAME(fk_name) + ';'
	from 
		vw_SYSCTRL_GetAllForeignKeys
	where 
		target_table = @TableName

	create table #ID (ID int);

	if @DropMode = 1
	begin
		INSERT into CST_CONSTRAINT_TABLE(DROP_SCRIPT, IS_DROP) 
		output inserted.SCRIPT_ID 
		into #ID(ID) 
		select @drop, @DropMode;
	end

	-- create is a little more complex. We need to generate the list of 
	-- columns on both sides of the constraint, even though in most cases
	-- there is only one column.
	select @create += convert(nvarchar(max), N'') + N'
	ALTER TABLE ' 
		+ QUOTENAME(sch.name) + '.' + QUOTENAME(source_table.name) 
		+ ' ADD CONSTRAINT ' + QUOTENAME(fk.name) 
		+ ' FOREIGN KEY (' + STUFF(
			(
				-- get all the columns in the constraint table
				select ',' + QUOTENAME(source_column.name)
				from 
					sys.columns source_column
				where
						source_column.column_id = parent_column_id 
					and source_column.object_id = source_table.object_id
				order by
					fkc.constraint_column_id 
				FOR XML PATH(N''), TYPE
			).value(N'.[1]', N'nvarchar(max)'), 1, 1, N''
		)
		+ ') REFERENCES ' + QUOTENAME(sch.name) + '.' + QUOTENAME(target_table.name)
		+ '(' + STUFF(
			(
			   -- get all the referenced columns
				select ',' + QUOTENAME(target_column.name)
				from 
					sys.columns target_column 
				where
						target_column.column_id = referenced_column_id 
					and target_column.object_id = target_table.object_id
				order by	
					fkc.referenced_column_id 
				FOR XML PATH(N''), TYPE
			).value(N'.[1]', N'nvarchar(max)'), 1, 1, N''
		) + ');'
	from 
		sys.foreign_key_columns fkc
		join sys.foreign_keys fk
			on fk.object_id = fkc.constraint_object_id
		join sys.objects obj
			on obj.object_id = fkc.constraint_object_id

		-- source table
		join sys.tables	source_table	
			on source_table.object_id = fkc.parent_object_id
		join sys.schemas sch	
			on source_table.[schema_id] = sch.[schema_id]

		-- target table
		join sys.tables	target_table
			on target_table.object_id = fkc.referenced_object_id
	where 
			target_table.is_ms_shipped = 0 and source_table.is_ms_shipped = 0
		and	target_table.name = @TableName;

	UPDATE 
		cst
	set
		create_script = iif(@create = '', null, @create)
	from
		CST_CONSTRAINT_TABLE cst
		join #ID id
			on id.ID = cst.SCRIPT_ID
	
	print	@drop;
	print	@create;
	
	IF @DropMode = 1
	BEGIN
		EXEC sp_executesql @drop
	END
	ELSE
	BEGIN
		select top 1 @create = CREATE_SCRIPT from CST_CONSTRAINT_TABLE order by SCRIPT_ID desc 
		EXEC sp_executesql @create
	END;

	drop table #ID;
END;
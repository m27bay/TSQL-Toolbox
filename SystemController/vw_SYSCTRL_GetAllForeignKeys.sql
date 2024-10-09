create view vw_SYSCTRL_GetAllForeignKeys
as
	select 
		fk.name				as fk_name,
		sch.name			as [schema_name],
		source_table.name	as source_table,
		source_column.name	as source_column,
		target_table.name	as target_table,
		target_column.name	as target_column
	from 
					sys.foreign_key_columns fkc
		inner join 	sys.foreign_keys fk
						on fk.object_id = fkc.constraint_object_id
		inner join	sys.objects obj
						on obj.object_id = fkc.constraint_object_id
		--
		inner join sys.tables source_table
						on source_table.object_id = fkc.parent_object_id
		inner join sys.schemas sch
						on source_table.schema_id = sch.schema_id
		inner join sys.columns source_column
						on	source_column.column_id = parent_column_id 
						and source_column.object_id = source_table.object_id
		--
		inner join sys.tables target_table
						on target_table.object_id = fkc.referenced_object_id
		inner join sys.columns target_column
						on	target_column.column_id = referenced_column_id 
						and target_column.object_id = target_table.object_id
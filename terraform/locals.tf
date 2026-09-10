locals {
  tables_config = yamldecode(file("${path.module}/config/tables.yml"))

  stages_config = yamldecode(file("${path.module}/config/stages.yml"))

  file_formats_config = yamldecode(file("${path.module}/config/file-formats.yml"))

  pipes_config = yamldecode(file("${path.module}/config/pipes.yml"))

  tables = flatten([
    for source_name, source_config in local.tables_config : [
      for table_config in source_config.tables : {
        key          = "${source_name}.${table_config.name}"
        source       = source_name
        database     = source_config.database
        table_name   = table_config.name
        landing_type = table_config.landing_type
      }
    ]
  ])

  stages = flatten([
    for source_name, source_config in local.stages_config : [
      for stage_name, stage_config in source_config : {
        key        = "${source_name}.${stage_name}"
        source     = source_name
        stage_name = stage_name
        gcs_path   = stage_config.gcs_path
      }
    ]
  ])

  file_formats = flatten([
    for source_name, source_config in local.file_formats_config : [
      for format_name, format_config in source_config : {
        key         = "${source_name}.${format_name}"
        source      = source_name
        format_name = format_name
        type        = format_config.type
      }
    ]
  ])

  pipes = flatten([
    for source_name, source_config in local.pipes_config : [
      for pipe_name, pipe_config in source_config : {
        key          = "${source_name}.${pipe_name}"
        source       = source_name
        pipe_name    = pipe_name
        stage        = pipe_config.stage
        stage_subdir = pipe_config.stage_subdir
        file_format  = pipe_config.file_format
        table        = pipe_config.table
      }
    ]
  ])

  tables_map       = { for table in local.tables : table.key => table }
  stages_map       = { for stage in local.stages : stage.key => stage }
  file_formats_map = { for format in local.file_formats : format.key => format }
  pipes_map        = { for pipe in local.pipes : pipe.key => pipe }
}
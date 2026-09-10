resource "snowflake_pipe" "landing" {
  for_each = local.pipes_map

  database = var.snowflake_database
  schema   = snowflake_schema.landing.name
  name     = upper(each.value.pipe_name)

  auto_ingest = true

  integration = snowflake_notification_integration.gcp.name

  copy_statement = <<-SQL
    COPY INTO ${var.snowflake_database}.${snowflake_schema.landing.name}.${each.value.table}
    (
      RAW_DATA,
      SOURCE_FILE
    )
    FROM (
      SELECT
        $1,
        METADATA$FILENAME
      FROM @${var.snowflake_database}.${snowflake_schema.landing.name}.${upper(each.value.stage)}
    )
    FILE_FORMAT = (
      FORMAT_NAME = '${var.snowflake_database}.${snowflake_schema.landing.name}.${upper("FF_${each.value.source}_${each.value.file_format}")}'
    )
    ON_ERROR = 'CONTINUE'
  SQL

  depends_on = [
    snowflake_table.landing_variant
  ]
}
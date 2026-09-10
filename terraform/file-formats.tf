resource "snowflake_file_format_json" "json" {
  for_each = local.file_formats_map

  database = var.snowflake_database
  schema   = snowflake_schema.landing.name
  name     = upper("FF_${each.value.source}_${each.value.format_name}")
}
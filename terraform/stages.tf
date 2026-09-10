resource "snowflake_stage_external_gcs" "gcs" {
  for_each = local.stages_map

  database = var.snowflake_database
  schema   = snowflake_schema.landing.name
  name     = upper(each.value.stage_name)

  url                 = each.value.gcs_path
  storage_integration = "ADVWORKS_GCS_INT"
}
resource "snowflake_table" "landing_variant" {
  for_each = {
    for table in local.tables_map : table.key => table
    if table.landing_type == "variant"
  }

  database = var.snowflake_database
  schema   = snowflake_schema.landing.name
  name     = each.value.table_name

  column {
    name = "RAW_DATA"
    type = "VARIANT"
  }

  column {
    name = "SOURCE_FILE"
    type = "VARCHAR"
  }

  column {
    name = "LOAD_TIMESTAMP"
    type = "TIMESTAMP_NTZ"

    default {
      expression = "CURRENT_TIMESTAMP()"
    }
  }
}
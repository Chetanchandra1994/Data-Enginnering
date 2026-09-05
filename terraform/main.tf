provider "snowflake" {
  organization_name      = var.snowflake_organization_name
  account_name           = var.snowflake_account_name
  user                   = var.snowflake_user
  authenticator          = "SNOWFLAKE_JWT"
  private_key            = file(var.snowflake_private_key_path)
  private_key_passphrase = var.snowflake_private_key_passphrase
  role                   = var.snowflake_role
}


resource "snowflake_database" "advworks" {
  name = var.snowflake_database
}

resource "snowflake_warehouse" "etl" {
  name           = var.snowflake_warehouse
  warehouse_size = "XSMALL"
  warehouse_type = "STANDARD"

  auto_suspend = 60
  auto_resume  = true

  min_cluster_count = 1
  max_cluster_count = 1
  scaling_policy    = "STANDARD"

  enable_query_acceleration = false
}

resource "snowflake_schema" "landing" {
  database            = var.snowflake_database
  name                = "LANDING"
  is_transient        = "false"
  with_managed_access = "false"
}

resource "snowflake_schema" "prepare" {
  database            = var.snowflake_database
  name                = "PREPARE"
  is_transient        = "false"
  with_managed_access = "false"
}

resource "snowflake_schema" "normalize" {
  database            = var.snowflake_database
  name                = "NORMALIZE"
  is_transient        = "false"
  with_managed_access = "false"
}

resource "snowflake_schema" "schematize" {
  database            = var.snowflake_database
  name                = "SCHEMATIZE"
  is_transient        = "false"
  with_managed_access = "false"
}

resource "snowflake_schema" "marketplace" {
  database            = var.snowflake_database
  name                = "MARKETPLACE"
  is_transient        = "false"
  with_managed_access = "false"
}
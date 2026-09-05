variable "snowflake_organization_name" {
  description = "Snowflake organization name"
  type        = string
}

variable "snowflake_account_name" {
  description = "Snowflake account name"
  type        = string
}

variable "snowflake_user" {
  description = "Snowflake username"
  type        = string
}

variable "snowflake_private_key_path" {
  description = "Path to the Snowflake private key file"
  type        = string
}

variable "snowflake_private_key_passphrase" {
  description = "Passphrase for the encrypted Snowflake private key"
  type        = string
  sensitive   = true
}

variable "snowflake_role" {
  description = "Snowflake role"
  type        = string
  default     = "ACCOUNTADMIN"
}

variable "snowflake_warehouse" {
  description = "Snowflake warehouse"
  type        = string
}

variable "snowflake_database" {
  description = "Snowflake database"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}
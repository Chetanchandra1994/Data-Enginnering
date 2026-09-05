terraform {
  required_version = ">= 1.5.0"

  backend "gcs" {
    bucket = "electric-tesla-507710-k2-tfstate"
    prefix = "terraform/state/dev"
  }

  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 2.0"
    }
  }
}
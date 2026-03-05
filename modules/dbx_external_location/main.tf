terraform {
  required_providers {
    databricks = {
      source                = "databricks/databricks"
      configuration_aliases = [databricks.workspace]
    }
  }
}

resource "databricks_external_location" "this" {
  provider        = databricks.workspace
  name            = var.name
  url             = var.url
  credential_name = var.credential_name
  isolation_mode  = var.isolation_mode
  skip_validation = var.skip_validation
  force_destroy   = var.force_destroy
}

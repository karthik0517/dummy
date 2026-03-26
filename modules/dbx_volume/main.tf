terraform {
  required_providers {
    databricks = {
      source                = "databricks/databricks"
      configuration_aliases = [databricks.workspace]
    }
  }
}

resource "databricks_volume" "this" {
  provider         = databricks.workspace
  catalog_name     = var.catalog_name
  schema_name      = var.schema_name
  name             = var.name
  volume_type      = var.volume_type
  storage_location = var.storage_location
  comment          = var.comment
}

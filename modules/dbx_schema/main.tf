terraform {
  required_providers {
    databricks = {
      source                = "databricks/databricks"
      configuration_aliases = [databricks.workspace]
    }
  }
}

resource "databricks_schema" "this" {
  provider      = databricks.workspace
  catalog_name  = var.catalog_name
  name          = var.name
  storage_root  = var.storage_root
  comment       = var.comment
  force_destroy = var.force_destroy
}

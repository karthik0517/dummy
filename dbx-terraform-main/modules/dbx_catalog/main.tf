terraform {
  required_providers {
    databricks = {
      source                = "databricks/databricks"
      configuration_aliases = [databricks.workspace]
    }
  }
}

resource "databricks_catalog" "this" {
  provider       = databricks.workspace
  name           = var.name
  comment        = var.comment
  storage_root   = var.storage_root
  isolation_mode = var.isolation_mode
  force_destroy  = var.force_destroy
}

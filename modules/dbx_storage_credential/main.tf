terraform {
  required_providers {
    databricks = {
      source                = "databricks/databricks"
      configuration_aliases = [databricks.workspace]
    }
  }
}

resource "databricks_storage_credential" "this" {
  provider = databricks.workspace
  name     = var.name
  azure_managed_identity {
    access_connector_id = var.access_connector_id
  }
  force_destroy = var.force_destroy
  force_update  = var.force_update
}

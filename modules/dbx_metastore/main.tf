terraform {
  required_providers {
    databricks = {
      source                = "databricks/databricks"
      configuration_aliases = [databricks.account]
    }
  }
}

resource "databricks_metastore" "this" {
  provider      = databricks.account
  name          = var.name
  storage_root  = var.storage_root
  region        = var.location
  force_destroy = var.force_destroy
}

resource "databricks_metastore_data_access" "this" {
  provider     = databricks.account
  metastore_id = databricks_metastore.this.id
  name         = var.data_access_name
  azure_managed_identity {
    access_connector_id = var.access_connector_id
  }
  is_default = var.is_default
}

terraform {
  required_providers {
    databricks = {
      source                = "databricks/databricks"
      configuration_aliases = [databricks.account]
    }
  }
}

resource "databricks_group" "this" {
  provider                   = databricks.account
  display_name               = var.display_name
  external_id                = var.external_id
  workspace_access           = var.workspace_access
  databricks_sql_access      = var.databricks_sql_access
  allow_cluster_create       = var.allow_cluster_create
  allow_instance_pool_create = var.allow_instance_pool_create
}

resource "databricks_mws_permission_assignment" "this" {
  provider     = databricks.account
  workspace_id = var.workspace_id
  principal_id = databricks_group.this.id
  permissions  = [var.permission_level]
}

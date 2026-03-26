terraform {
  required_providers {
    databricks = {
      source                = "databricks/databricks"
      configuration_aliases = [databricks.account, databricks.workspace]
    }
  }
}

resource "databricks_service_principal" "this" {
  provider                   = databricks.account
  display_name               = var.display_name
  active                     = true
  allow_cluster_create       = var.allow_cluster_create
  allow_instance_pool_create = var.allow_instance_pool_create
  databricks_sql_access      = var.databricks_sql_access
  workspace_access           = var.workspace_access
}

resource "databricks_mws_permission_assignment" "this" {
  provider     = databricks.account
  workspace_id = var.workspace_id
  principal_id = databricks_service_principal.this.id
  permissions  = [var.permission_level]
}

resource "databricks_entitlements" "this" {
  provider                   = databricks.workspace
  service_principal_id       = databricks_service_principal.this.id
  depends_on                 = [databricks_mws_permission_assignment.this]
  workspace_access           = var.workspace_access
  databricks_sql_access      = var.databricks_sql_access
  allow_cluster_create       = var.allow_cluster_create
  allow_instance_pool_create = var.allow_instance_pool_create
}

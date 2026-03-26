terraform {
  required_providers {
    databricks = {
      source                = "databricks/databricks"
      configuration_aliases = [databricks.account, databricks.workspace]
    }
    azuread = {
      source = "hashicorp/azuread"
    }
  }
}

module "entra_group" {
  source       = "../entra_id_group"
  display_name = var.display_name
}

module "dbx_group" {
  source                     = "../dbx_group"
  display_name               = module.entra_group.display_name
  external_id                = module.entra_group.object_id
  workspace_id               = var.workspace_id
  allow_cluster_create       = var.allow_cluster_create
  allow_instance_pool_create = var.allow_instance_pool_create
  workspace_access           = var.workspace_access
  databricks_sql_access      = var.databricks_sql_access
  permission_level           = var.permission_level
  providers = {
    databricks.account   = databricks.account
    databricks.workspace = databricks.workspace
  }
}

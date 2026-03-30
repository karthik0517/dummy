locals {
  groups = {
    admins         = { display_name = "Admins", allow_cluster_create = false, workspace_access = true, databricks_sql_access = true, permission = "ADMIN" }
    dataarchitects = { display_name = "Data Architects", allow_cluster_create = false, workspace_access = false, databricks_sql_access = false, permission = "USER" }
    dataengineers  = { display_name = "Data Engineers", allow_cluster_create = false, workspace_access = false, databricks_sql_access = false, permission = "USER" }
    dataanalysts   = { display_name = "Data Analysts", allow_cluster_create = false, workspace_access = true, databricks_sql_access = true, permission = "USER" }
    qa             = { display_name = "QA", allow_cluster_create = false, workspace_access = false, databricks_sql_access = false, permission = "USER" }
    svc            = { display_name = "SVC", allow_cluster_create = false, workspace_access = true, databricks_sql_access = false, permission = "USER" }
  }
}

module "role_group" {
  for_each                   = local.groups
  source                     = "../modules/dbx_role_group"
  display_name               = "App Access - Databricks ACCO ${each.value.display_name} ${title(local.environment)}"
  workspace_id               = local.workspace_id
  allow_cluster_create       = each.value.allow_cluster_create
  allow_instance_pool_create = each.value.allow_cluster_create
  workspace_access           = each.value.workspace_access
  databricks_sql_access      = each.value.databricks_sql_access
  permission_level           = each.value.permission
  providers = {
    databricks.account   = databricks.account
    databricks.workspace = databricks.workspace
    azuread              = azuread
  }
}

locals {
  schema_group_entitlements = {}
}

module "schema_group" {
  for_each              = local.all_schemas
  source                = "../modules/dbx_role_group"
  display_name          = "App Access - Databricks ACCO ${upper(substr(replace(each.key, "_", " "), 0, 1))}${substr(replace(each.key, "_", " "), 1, -1)} ${title(local.environment)}"
  workspace_id          = local.workspace_id
  workspace_access      = try(local.schema_group_entitlements[each.key].workspace_access, false)
  databricks_sql_access = try(local.schema_group_entitlements[each.key].databricks_sql_access, false)
  providers = {
    databricks.account   = databricks.account
    databricks.workspace = databricks.workspace
    azuread              = azuread
  }
}

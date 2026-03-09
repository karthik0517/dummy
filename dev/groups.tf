locals {
  groups = {
    # allow_cluster_create: only admins and architects can provision clusters.
    # Engineers, analysts, QA, and service accounts use shared compute or
    # cluster policies instead.
    # display_name values match existing Entra ID groups exactly.
    admins         = { display_name = "Admins", allow_cluster_create = true, permission = "ADMIN" }
    dataarchitects = { display_name = "Data Architects", allow_cluster_create = true, permission = "USER" }
    dataengineers  = { display_name = "Data Engineers", allow_cluster_create = false, permission = "USER" }
    dataanalysts   = { display_name = "Data Analysts", allow_cluster_create = false, permission = "USER" }
    qa             = { display_name = "QA", allow_cluster_create = false, permission = "USER" }
    svc            = { display_name = "SVC", allow_cluster_create = false, permission = "USER" }
  }
}

module "role_group" {
  for_each                   = local.groups
  source                     = "../modules/dbx_role_group"
  display_name               = "App Access - Databricks ACCO ${each.value.display_name} ${title(local.environment)}"
  workspace_id               = local.workspace_id
  allow_cluster_create       = each.value.allow_cluster_create
  allow_instance_pool_create = each.value.allow_cluster_create
  permission_level           = each.value.permission
  providers = {
    databricks.account   = databricks.account
    databricks.workspace = databricks.workspace
    azuread              = azuread
  }
}

# Per-schema groups
module "schema_group" {
  for_each = local.all_schemas
  source   = "../modules/dbx_role_group"
  # Capitalize only the first letter to match existing Entra ID group names
  # (e.g. "Bronze bidtracer" not "Bronze Bidtracer")
  display_name = "App Access - Databricks ACCO ${upper(substr(replace(each.key, "_", " "), 0, 1))}${substr(replace(each.key, "_", " "), 1, -1)} ${title(local.environment)}"
  workspace_id = local.workspace_id
  providers = {
    databricks.account   = databricks.account
    databricks.workspace = databricks.workspace
    azuread              = azuread
  }
}

module "service_principal" {
  for_each     = var.service_principals
  source       = "../modules/dbx_service_principal"
  display_name = "sp_acco_dbx_${each.key}_${local.environment}"
  workspace_id = local.workspace_id
  providers = {
    databricks.account   = databricks.account
    databricks.workspace = databricks.workspace
  }
}

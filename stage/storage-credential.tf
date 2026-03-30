module "storage_credential" {
  source              = "../modules/dbx_storage_credential"
  name                = "${module.storage_account_databricks.name}_acco-${local.environment}-dbx-${local.location}_credential"
  access_connector_id = module.access_connector_databricks.id
  force_update        = true
  providers = {
    databricks.workspace = databricks.workspace
  }
}

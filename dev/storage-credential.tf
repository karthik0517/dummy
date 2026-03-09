module "storage_credential" {
  source              = "../modules/dbx_storage_credential"
  name                = "${module.storage_account_databricks.name}_credential"
  access_connector_id = module.access_connector_databricks.id
  providers = {
    databricks.workspace = databricks.workspace
  }
}

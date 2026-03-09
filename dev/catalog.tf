resource "azurerm_storage_container" "catalog" {
  name               = "catalog"
  storage_account_id = module.storage_account_databricks.id
}

resource "databricks_external_location" "catalog" {
  provider        = databricks.workspace
  name            = "${local.environment}-v2-catalog"
  url             = "abfss://catalog@${module.storage_account_databricks.name}.dfs.core.windows.net/"
  credential_name = module.storage_credential.name
}

module "catalog" {
  source       = "../modules/dbx_catalog"
  name         = "${local.environment}_v2_catalog"
  comment      = "Main catalog"
  storage_root = "abfss://catalog@${module.storage_account_databricks.name}.dfs.core.windows.net/"
  providers = {
    databricks.workspace = databricks.workspace
  }
  depends_on = [databricks_external_location.catalog]
}

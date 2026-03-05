locals {
  subscription_id = "c4069cfe-7b19-453b-aa0a-f9905397b3a8"
  tenant_id       = "1ad64935-9037-4021-aedc-bc275ed4481c"
  location        = "westus2"
  location_short  = "wus2"
}

resource "azurerm_resource_group" "this" {
  location   = local.location
  managed_by = null
  name       = "rg-acco-dev-dbx-${local.location}"
  tags = {
    CreatedBy = "Alex V."
    CreatedOn = "09/22/2025"
  }
}

module "storage_account_databricks" {
  source              = "../modules/azure_storage_account"
  name                = "staccodbxdev${local.location_short}"
  resource_group_name = azurerm_resource_group.this.name
  location            = local.location
  tags = {
    author    = "jonmoss@consultant.accoes.com"
    project   = "dbx"
    env       = "dev"
    date      = "2026/02/23"
    terraform = "true"
  }
}

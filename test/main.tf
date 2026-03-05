locals {
  subscription_id = "c4069cfe-7b19-453b-aa0a-f9905397b3a8"
  tenant_id       = "1ad64935-9037-4021-aedc-bc275ed4481c"
  location        = "westus2"
}

resource "azurerm_resource_group" "this" {
  location   = local.location
  managed_by = null
  name       = "rg-acco-test-dbx-westus2"
  tags = {
    CreatedBy = "Alex V."
    CreatedOn = "10/06/2025"
  }
}

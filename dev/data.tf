data "terraform_remote_state" "shared" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-acco-shared-dbx-westus2"
    storage_account_name = "staccotfstatewestus2"
    container_name       = "tfstate"
    key                  = "dbx-terraform-shared.tfstate"
  }
}

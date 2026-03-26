terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.64.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "= 3.8.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "1.112.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-acco-shared-dbx-westus2"
    storage_account_name = "staccotfstatewestus2"
    container_name       = "tfstate"
    key                  = "dbx-terraform-test.tfstate"
  }
}

provider "azurerm" {
  subscription_id                 = local.subscription_id
  tenant_id                       = local.tenant_id
  resource_provider_registrations = "none"
  features {}
}

provider "azuread" {
  tenant_id = local.tenant_id
}

provider "databricks" {
  alias      = "account"
  host       = "https://accounts.azuredatabricks.net"
  account_id = data.terraform_remote_state.shared.outputs.databricks_account_id
}

provider "databricks" {
  alias                       = "workspace"
  host                        = module.test_databricks_workspace.workspace_url
  azure_workspace_resource_id = module.test_databricks_workspace.workspace_resource_id
}

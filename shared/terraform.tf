terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 4.61.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "= 3.8.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "= 1.109.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-acco-shared-dbx-westus2"
    storage_account_name = "staccotfstatewestus2"
    container_name       = "tfstate"
    key                  = "dbx-terraform-shared.tfstate"
  }
}

provider "azurerm" {
  subscription_id                 = local.subscription_id
  tenant_id                       = local.tenant_id
  resource_provider_registrations = "none"
  features {}
}

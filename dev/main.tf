locals {
  subscription_id = "c4069cfe-7b19-453b-aa0a-f9905397b3a8"
  tenant_id       = "1ad64935-9037-4021-aedc-bc275ed4481c"
  location        = "westus2"
  location_short  = "wus2"
  # JDE Oracle GoldenGate service principal — needs blob + queue access for OGG replication
  jde_sp_principal_id = "648611b5-b455-4e55-b37c-c58c86dbeffe"
  tags = {
    author    = "jonmoss@consultant.accoes.com"
    project   = "dbx"
    env       = "dev"
    terraform = "true"
    date      = "2026/02/23"
  }

  # Databricks platform
  environment  = "dev"
  workspace_id = module.dev_databricks_workspace.id
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

module "access_connector_databricks" {
  source              = "../modules/azure_access_connector"
  name                = "ac-acco-dev-dbx-${local.location_short}"
  resource_group_name = azurerm_resource_group.this.name
  location            = local.location
  tags                = local.tags
}

module "dev_databricks_workspace" {
  source                      = "../modules/azure_databricks_workspace"
  name                        = "acco-dev-dbx-${local.location_short}"
  resource_group_name         = azurerm_resource_group.this.name
  location                    = local.location
  managed_resource_group_name = "rg-acco-dev-dbx-managed-${local.location_short}"
  # true for dev to allow console access; set false in prod behind Private Link
  public_network_access_enabled = true
  access_connector_id           = module.access_connector_databricks.id
  vnet_id                       = data.terraform_remote_state.shared.outputs.vnet_non_prod_id
  private_subnet_name           = data.terraform_remote_state.shared.outputs.subnet_private_dev_new_name
  public_subnet_name            = data.terraform_remote_state.shared.outputs.subnet_public_dev_new_name
  private_nsg_association_id    = data.terraform_remote_state.shared.outputs.subnet_private_dev_new_nsg_association_id
  public_nsg_association_id     = data.terraform_remote_state.shared.outputs.subnet_public_dev_new_nsg_association_id
  enhanced_security_compliance = {
    automatic_cluster_update_enabled = true
  }
  tags = local.tags
}

resource "databricks_automatic_cluster_update_workspace_setting" "this" {
  provider = databricks.workspace

  automatic_cluster_update_workspace {
    enabled    = true
    can_toggle = true
    maintenance_window {
      week_day_based_schedule {
        day_of_week = "SATURDAY"
        frequency   = "FIRST_OF_MONTH"
        window_start_time {
          hours   = 8
          minutes = 0
        }
      }
    }
  }
}

resource "azurerm_role_assignment" "access_connector_blob_contributor" {
  scope                = module.storage_account_databricks.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.access_connector_databricks.principal_id
}

# JDE OGG service principal needs blob read/write for replication data
# and queue access for change event notifications
resource "azurerm_role_assignment" "jde_sp_blob_contributor" {
  scope                = module.storage_account_databricks.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = local.jde_sp_principal_id
}

resource "azurerm_role_assignment" "jde_sp_queue_contributor" {
  scope                = module.storage_account_databricks.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = local.jde_sp_principal_id
}


module "storage_account_databricks" {
  source              = "../modules/azure_storage_account"
  name                = "staccodbxdev${local.location_short}"
  resource_group_name = azurerm_resource_group.this.name
  location            = local.location
  tags                = local.tags
}

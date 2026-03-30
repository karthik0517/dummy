locals {
  subscription_id = "c4069cfe-7b19-453b-aa0a-f9905397b3a8"
  tenant_id       = "1ad64935-9037-4021-aedc-bc275ed4481c"
  location        = "westus2"
  # JDE Oracle GoldenGate service principal — needs blob + queue access for OGG replication
  jde_sp_principal_id = "4957c3b4-cd71-4921-a082-0c3d2bde5c10"
  tags = {
    author    = "jonmoss@consultant.accoes.com"
    project   = "dbx"
    env       = "stage"
    terraform = "true"
    date      = "2026/03/26"
  }

  environment  = "stage"
  workspace_id = module.stage_databricks_workspace.id
}

resource "azurerm_resource_group" "this" {
  location   = local.location
  managed_by = null
  name       = "rg-acco-stage-dbx-${local.location}"
  tags = {
    CreatedBy = "Alex V."
    CreatedOn = "10/06/2025"
  }
}

module "access_connector_databricks" {
  source              = "../modules/azure_access_connector"
  name                = "ac-acco-stage-dbx-${local.location}"
  resource_group_name = azurerm_resource_group.this.name
  location            = local.location
  tags                = local.tags
}

module "stage_databricks_workspace" {
  source                        = "../modules/azure_databricks_workspace"
  name                          = "acco-stage-dbx-${local.location}"
  resource_group_name           = azurerm_resource_group.this.name
  location                      = local.location
  managed_resource_group_name   = "rg-acco-stage-dbx-managed-${local.location}"
  public_network_access_enabled = true
  access_connector_id           = module.access_connector_databricks.id
  vnet_id                       = data.terraform_remote_state.shared.outputs.vnet_prod_id
  private_subnet_name           = data.terraform_remote_state.shared.outputs.subnet_private_stage_name
  public_subnet_name            = data.terraform_remote_state.shared.outputs.subnet_public_stage_name
  private_nsg_association_id    = data.terraform_remote_state.shared.outputs.subnet_private_stage_nsg_association_id
  public_nsg_association_id     = data.terraform_remote_state.shared.outputs.subnet_public_stage_nsg_association_id
  tags                          = local.tags
  enhanced_security_compliance = {
    automatic_cluster_update_enabled = true
  }
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

resource "azurerm_role_assignment" "jde_sp_queue_contributor" {
  scope                = module.storage_account_databricks.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = local.jde_sp_principal_id
}

module "storage_account_databricks" {
  source              = "../modules/azure_storage_account"
  name                = "staccodbxstage${local.location}"
  resource_group_name = azurerm_resource_group.this.name
  location            = local.location
  tags                = local.tags
}

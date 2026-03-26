locals {
  subscription_id = "c4069cfe-7b19-453b-aa0a-f9905397b3a8"
  tenant_id       = "1ad64935-9037-4021-aedc-bc275ed4481c"
  location        = "westus2"
  location_short  = "wus2"
  # Org-wide Databricks account ID — shared by all workspaces/environments
  databricks_account_id = "b06bfa55-d0cc-4390-a85c-55dbc77d421e"
  # Regional Unity Catalog metastore (westus2) — one per region, shared by
  # all workspaces. Hardcoded because the account-level data source requires
  # account admin permissions.
  databricks_metastore_id  = "b935d630-fe91-4f2a-935d-5225ed56e52a"
  dev_resource_group_name  = data.terraform_remote_state.dev.outputs.dev_resource_group_name
  test_resource_group_name = data.terraform_remote_state.test.outputs.test_resource_group_name
}

# TODO: After decommissioning dbx_terraform, move metastore grants here.
# Requires adding a workspace provider to shared/terraform.tf (any workspace).
# See README.md "Migration from dbx_terraform" section.
#
# resource "databricks_grants" "metastore" {
#   provider  = databricks.workspace
#   metastore = local.databricks_metastore_id
#
#   grant {
#     principal  = "App Access - Databricks ACCO Admins Dev"
#     privileges = [
#       "CREATE_CATALOG",
#       "CREATE_CONNECTION",
#       "CREATE_EXTERNAL_LOCATION",
#       "CREATE_STORAGE_CREDENTIAL",
#       "CREATE_SHARE",
#       "CREATE_RECIPIENT",
#       "CREATE_PROVIDER",
#       "SET_SHARE_PERMISSION",
#     ]
#   }
#   grant {
#     principal  = "App Access - Databricks ACCO Data Architects Dev"
#     privileges = [
#       "CREATE_CATALOG",
#       "CREATE_EXTERNAL_LOCATION",
#     ]
#   }
# }

module "nsg_non_prod" {
  source              = "../modules/azure_nsg"
  name                = "databricksnsgdev"
  location            = local.location
  resource_group_name = local.dev_resource_group_name
}

module "nsg_non_prod_test" {
  source              = "../modules/azure_nsg"
  name                = "databricksnsgtest"
  location            = local.location
  resource_group_name = local.test_resource_group_name
}

module "vnet_non_prod" {
  source              = "../modules/azure_vnet"
  name                = "vnet-acco-dev-dbx-westus2"
  location            = local.location
  resource_group_name = local.dev_resource_group_name
  address_space       = ["10.50.0.0/16"]
}

# Original dev subnets — kept for backward compatibility with existing resources.
# New workspaces use the _new subnets below.
module "subnet_private_dev" {
  source              = "../modules/azure_subnet"
  name                = "snet-private-acco-dev-dbx-westus2"
  resource_group_name = local.dev_resource_group_name
  vnet_name           = module.vnet_non_prod.name
  address_prefixes    = ["10.50.4.0/24"]
  nsg_id              = module.nsg_non_prod.id
}

module "subnet_public_dev" {
  source              = "../modules/azure_subnet"
  name                = "snet-public-acco-dev-dbx-westus2"
  resource_group_name = local.dev_resource_group_name
  vnet_name           = module.vnet_non_prod.name
  address_prefixes    = ["10.50.5.0/24"]
  nsg_id              = module.nsg_non_prod.id
}

module "subnet_private_test" {
  source              = "../modules/azure_subnet"
  name                = "snet-private-acco-test-dbx-westus2"
  resource_group_name = local.dev_resource_group_name
  vnet_name           = module.vnet_non_prod.name
  address_prefixes    = ["10.50.6.0/24"]
  nsg_id              = module.nsg_non_prod_test.id
}

module "subnet_public_test" {
  source              = "../modules/azure_subnet"
  name                = "snet-public-acco-test-dbx-westus2"
  resource_group_name = local.dev_resource_group_name
  vnet_name           = module.vnet_non_prod.name
  address_prefixes    = ["10.50.7.0/24"]
  nsg_id              = module.nsg_non_prod_test.id
}

# Current dev subnets used by the active workspace (referenced in dev/main.tf)
module "subnet_private_dev_new" {
  source              = "../modules/azure_subnet"
  name                = "snet-private-acco-dev-dbx-${local.location_short}"
  resource_group_name = local.dev_resource_group_name
  vnet_name           = module.vnet_non_prod.name
  address_prefixes    = ["10.50.8.0/24"]
  nsg_id              = module.nsg_non_prod.id
}

module "subnet_public_dev_new" {
  source              = "../modules/azure_subnet"
  name                = "snet-public-acco-dev-dbx-${local.location_short}"
  resource_group_name = local.dev_resource_group_name
  vnet_name           = module.vnet_non_prod.name
  address_prefixes    = ["10.50.9.0/24"]
  nsg_id              = module.nsg_non_prod.id
}

module "pip_non_prod" {
  source              = "../modules/azure_public_ip"
  name                = "pip-acco-dbx-dev-${local.location}"
  location            = local.location
  resource_group_name = local.dev_resource_group_name
}

module "nat_gateway_non_prod" {
  source              = "../modules/azure_nat_gateway"
  name                = "vnat-acco-dbx-dev-${local.location}"
  location            = local.location
  resource_group_name = local.dev_resource_group_name
}

resource "azurerm_nat_gateway_public_ip_association" "non_prod" {
  nat_gateway_id       = module.nat_gateway_non_prod.id
  public_ip_address_id = module.pip_non_prod.id
}

resource "azurerm_subnet_nat_gateway_association" "private_dev" {
  subnet_id      = module.subnet_private_dev.id
  nat_gateway_id = module.nat_gateway_non_prod.id
}

resource "azurerm_subnet_nat_gateway_association" "public_dev" {
  subnet_id      = module.subnet_public_dev.id
  nat_gateway_id = module.nat_gateway_non_prod.id
}

resource "azurerm_subnet_nat_gateway_association" "private_dev_new" {
  subnet_id      = module.subnet_private_dev_new.id
  nat_gateway_id = module.nat_gateway_non_prod.id
}

resource "azurerm_subnet_nat_gateway_association" "public_dev_new" {
  subnet_id      = module.subnet_public_dev_new.id
  nat_gateway_id = module.nat_gateway_non_prod.id
}

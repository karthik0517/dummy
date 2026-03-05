locals {
  subscription_id          = "c4069cfe-7b19-453b-aa0a-f9905397b3a8"
  tenant_id                = "1ad64935-9037-4021-aedc-bc275ed4481c"
  location                 = "westus2"
  dev_resource_group_name  = data.terraform_remote_state.dev.outputs.dev_resource_group_name
  test_resource_group_name = data.terraform_remote_state.test.outputs.test_resource_group_name
}

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

module "pip_non_prod" {
  source              = "../modules/azure_public_ip"
  name                = "pip-acco-dbx-dev-westus2"
  location            = local.location
  resource_group_name = local.dev_resource_group_name
}

module "nat_gateway_non_prod" {
  source              = "../modules/azure_nat_gateway"
  name                = "vnat-acco-dbx-dev-westus2"
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

import {
  to = module.vnet_prod.azurerm_virtual_network.this
  id = "/subscriptions/c4069cfe-7b19-453b-aa0a-f9905397b3a8/resourceGroups/rg-acco-prod-dbx-westus2/providers/Microsoft.Network/virtualNetworks/vnet-acco-prod-dbx-westus2"
}

import {
  to = module.nsg_prod.azurerm_network_security_group.this
  id = "/subscriptions/c4069cfe-7b19-453b-aa0a-f9905397b3a8/resourceGroups/rg-acco-prod-dbx-westus2/providers/Microsoft.Network/networkSecurityGroups/databricksnsgprod"
}

import {
  to = module.subnet_private_prod.azurerm_subnet.this
  id = "/subscriptions/c4069cfe-7b19-453b-aa0a-f9905397b3a8/resourceGroups/rg-acco-prod-dbx-westus2/providers/Microsoft.Network/virtualNetworks/vnet-acco-prod-dbx-westus2/subnets/snet-private-acco-prod-dbx-westus2"
}

import {
  to = module.subnet_public_prod.azurerm_subnet.this
  id = "/subscriptions/c4069cfe-7b19-453b-aa0a-f9905397b3a8/resourceGroups/rg-acco-prod-dbx-westus2/providers/Microsoft.Network/virtualNetworks/vnet-acco-prod-dbx-westus2/subnets/snet-public-acco-prod-dbx-westus2"
}

import {
  to = module.subnet_private_prod.azurerm_subnet_network_security_group_association.this
  id = "/subscriptions/c4069cfe-7b19-453b-aa0a-f9905397b3a8/resourceGroups/rg-acco-prod-dbx-westus2/providers/Microsoft.Network/virtualNetworks/vnet-acco-prod-dbx-westus2/subnets/snet-private-acco-prod-dbx-westus2"
}

import {
  to = module.subnet_public_prod.azurerm_subnet_network_security_group_association.this
  id = "/subscriptions/c4069cfe-7b19-453b-aa0a-f9905397b3a8/resourceGroups/rg-acco-prod-dbx-westus2/providers/Microsoft.Network/virtualNetworks/vnet-acco-prod-dbx-westus2/subnets/snet-public-acco-prod-dbx-westus2"
}

import {
  to = module.nsg_stage.azurerm_network_security_group.this
  id = "/subscriptions/c4069cfe-7b19-453b-aa0a-f9905397b3a8/resourceGroups/rg-acco-stage-dbx-westus2/providers/Microsoft.Network/networkSecurityGroups/databricksnsgstage"
}

import {
  to = module.subnet_private_stage.azurerm_subnet.this
  id = "/subscriptions/c4069cfe-7b19-453b-aa0a-f9905397b3a8/resourceGroups/rg-acco-prod-dbx-westus2/providers/Microsoft.Network/virtualNetworks/vnet-acco-prod-dbx-westus2/subnets/snet-private-acco-stage-dbx-westus2"
}

import {
  to = module.subnet_public_stage.azurerm_subnet.this
  id = "/subscriptions/c4069cfe-7b19-453b-aa0a-f9905397b3a8/resourceGroups/rg-acco-prod-dbx-westus2/providers/Microsoft.Network/virtualNetworks/vnet-acco-prod-dbx-westus2/subnets/snet-public-acco-stage-dbx-westus2"
}

import {
  to = module.subnet_private_stage.azurerm_subnet_network_security_group_association.this
  id = "/subscriptions/c4069cfe-7b19-453b-aa0a-f9905397b3a8/resourceGroups/rg-acco-prod-dbx-westus2/providers/Microsoft.Network/virtualNetworks/vnet-acco-prod-dbx-westus2/subnets/snet-private-acco-stage-dbx-westus2"
}

import {
  to = module.subnet_public_stage.azurerm_subnet_network_security_group_association.this
  id = "/subscriptions/c4069cfe-7b19-453b-aa0a-f9905397b3a8/resourceGroups/rg-acco-prod-dbx-westus2/providers/Microsoft.Network/virtualNetworks/vnet-acco-prod-dbx-westus2/subnets/snet-public-acco-stage-dbx-westus2"
}

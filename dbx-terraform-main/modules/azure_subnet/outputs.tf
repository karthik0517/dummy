output "id" {
  value = azurerm_subnet.this.id
}

output "name" {
  value = azurerm_subnet.this.name
}

output "resource_group_name" {
  value = azurerm_subnet.this.resource_group_name
}

output "virtual_network_name" {
  value = azurerm_subnet.this.virtual_network_name
}

output "address_prefixes" {
  value = azurerm_subnet.this.address_prefixes
}

output "nsg_association_id" {
  value = azurerm_subnet_network_security_group_association.this.id
}

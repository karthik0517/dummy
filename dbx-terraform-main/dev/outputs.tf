output "dev_resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "dev_resource_group_name_id" {
  value = azurerm_resource_group.this.id
}

output "dev_storage_account_databricks_id" {
  value = module.storage_account_databricks.id
}
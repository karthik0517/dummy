output "id" {
  value = azurerm_databricks_workspace.this.workspace_id
}

output "url" {
  value = azurerm_databricks_workspace.this.workspace_url
}

output "workspace_url" {
  value = azurerm_databricks_workspace.this.workspace_url
}

output "resource_id" {
  value = azurerm_databricks_workspace.this.id
}

output "workspace_resource_id" {
  value = azurerm_databricks_workspace.this.id
}

output "storage_account_identity" {
  value = azurerm_databricks_workspace.this.storage_account_identity
}

output "managed_resource_group_name" {
  value = azurerm_databricks_workspace.this.managed_resource_group_name
}

output "managed_resource_group_id" {
  value = azurerm_databricks_workspace.this.managed_resource_group_id
}

output "disk_encryption_set_id" {
  value = azurerm_databricks_workspace.this.disk_encryption_set_id
}

output "managed_disk_identity" {
  value = azurerm_databricks_workspace.this.managed_disk_identity
}

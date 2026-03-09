output "dev_resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "dev_workspace_url" {
  value = module.dev_databricks_workspace.workspace_url
}

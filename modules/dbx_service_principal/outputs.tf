output "id" {
  value = databricks_service_principal.this.id
}

output "application_id" {
  value = databricks_service_principal.this.application_id
}

output "display_name" {
  value = databricks_service_principal.this.display_name
}

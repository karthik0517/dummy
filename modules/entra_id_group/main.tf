resource "azuread_group" "this" {
  display_name     = var.display_name
  security_enabled = var.security_enabled
}

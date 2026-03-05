resource "azurerm_public_ip" "this" {
  name                    = var.name
  location                = var.location
  resource_group_name     = var.resource_group_name
  allocation_method       = var.allocation_method
  sku                     = var.sku
  sku_tier                = var.sku_tier
  ip_version              = var.ip_version
  idle_timeout_in_minutes = var.idle_timeout_in_minutes

  zones                   = var.zones
  ddos_protection_mode    = var.ddos_protection_mode
  ddos_protection_plan_id = var.ddos_protection_plan_id
  domain_name_label       = var.domain_name_label
  domain_name_label_scope = var.domain_name_label_scope
  edge_zone               = var.edge_zone
  ip_tags                 = var.ip_tags
  public_ip_prefix_id     = var.public_ip_prefix_id
  reverse_fqdn            = var.reverse_fqdn
  tags                    = var.tags
}

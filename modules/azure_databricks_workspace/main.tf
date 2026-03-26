resource "azurerm_databricks_workspace" "this" {
  name                        = var.name
  resource_group_name         = var.resource_group_name
  location                    = var.location
  sku                         = var.sku
  managed_resource_group_name = var.managed_resource_group_name

  public_network_access_enabled         = var.public_network_access_enabled
  network_security_group_rules_required = var.network_security_group_rules_required
  customer_managed_key_enabled          = var.customer_managed_key_enabled
  infrastructure_encryption_enabled     = var.infrastructure_encryption_enabled
  default_storage_firewall_enabled      = var.default_storage_firewall_enabled
  access_connector_id                   = var.access_connector_id

  load_balancer_backend_address_pool_id               = var.load_balancer_backend_address_pool_id
  managed_services_cmk_key_vault_id                   = var.managed_services_cmk_key_vault_id
  managed_services_cmk_key_vault_key_id               = var.managed_services_cmk_key_vault_key_id
  managed_disk_cmk_key_vault_id                       = var.managed_disk_cmk_key_vault_id
  managed_disk_cmk_key_vault_key_id                   = var.managed_disk_cmk_key_vault_key_id
  managed_disk_cmk_rotation_to_latest_version_enabled = var.managed_disk_cmk_rotation_to_latest_version_enabled

  custom_parameters {
    no_public_ip                                         = var.no_public_ip
    virtual_network_id                                   = var.vnet_id
    private_subnet_name                                  = var.private_subnet_name
    public_subnet_name                                   = var.public_subnet_name
    public_subnet_network_security_group_association_id  = var.public_nsg_association_id
    private_subnet_network_security_group_association_id = var.private_nsg_association_id
    storage_account_name                                 = var.storage_account_name
    storage_account_sku_name                             = var.storage_account_sku_name
    nat_gateway_name                                     = var.nat_gateway_name
    public_ip_name                                       = var.public_ip_name
    machine_learning_workspace_id                        = var.machine_learning_workspace_id
    vnet_address_prefix                                  = var.vnet_address_prefix
  }

  dynamic "enhanced_security_compliance" {
    for_each = var.enhanced_security_compliance != null ? [var.enhanced_security_compliance] : []
    content {
      automatic_cluster_update_enabled      = enhanced_security_compliance.value.automatic_cluster_update_enabled
      compliance_security_profile_enabled   = enhanced_security_compliance.value.compliance_security_profile_enabled
      compliance_security_profile_standards = enhanced_security_compliance.value.compliance_security_profile_standards
      enhanced_security_monitoring_enabled  = enhanced_security_compliance.value.enhanced_security_monitoring_enabled
    }
  }

  tags = var.tags
}

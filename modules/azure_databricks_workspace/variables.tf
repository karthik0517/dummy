variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "sku" {
  type    = string
  default = "premium"
}

variable "managed_resource_group_name" {
  type    = string
  default = null
}

variable "public_network_access_enabled" {
  type    = bool
  default = true
}

variable "network_security_group_rules_required" {
  type    = string
  default = "AllRules"
}

variable "customer_managed_key_enabled" {
  type    = bool
  default = false
}

variable "infrastructure_encryption_enabled" {
  type    = bool
  default = false
}

variable "default_storage_firewall_enabled" {
  type    = bool
  default = false
}

variable "access_connector_id" {
  type    = string
  default = null
}

variable "load_balancer_backend_address_pool_id" {
  type    = string
  default = null
}

variable "managed_services_cmk_key_vault_id" {
  type    = string
  default = null
}

variable "managed_services_cmk_key_vault_key_id" {
  type    = string
  default = null
}

variable "managed_disk_cmk_key_vault_id" {
  type    = string
  default = null
}

variable "managed_disk_cmk_key_vault_key_id" {
  type    = string
  default = null
}

variable "managed_disk_cmk_rotation_to_latest_version_enabled" {
  type    = bool
  default = null
}

variable "no_public_ip" {
  type    = bool
  default = true
}

variable "vnet_id" {
  type    = string
  default = null
}

variable "private_subnet_name" {
  type    = string
  default = null
}

variable "public_subnet_name" {
  type    = string
  default = null
}

variable "private_nsg_association_id" {
  type    = string
  default = null
}

variable "public_nsg_association_id" {
  type    = string
  default = null
}

variable "storage_account_name" {
  type    = string
  default = null
}

variable "storage_account_sku_name" {
  type    = string
  default = null
}

variable "nat_gateway_name" {
  type    = string
  default = null
}

variable "public_ip_name" {
  type    = string
  default = null
}

variable "machine_learning_workspace_id" {
  type    = string
  default = null
}

variable "vnet_address_prefix" {
  type    = string
  default = null
}

variable "enhanced_security_compliance" {
  type = object({
    automatic_cluster_update_enabled      = optional(bool, false)
    compliance_security_profile_enabled   = optional(bool, false)
    compliance_security_profile_standards = optional(list(string), [])
    enhanced_security_monitoring_enabled  = optional(bool, false)
  })
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

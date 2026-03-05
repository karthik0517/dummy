variable "name" {
  type = string
}

variable "managed_resource_group_name" {
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

variable "public_network_access_enabled" {
  type    = bool
  default = true
}

variable "network_security_group_rules_required" {
  type    = string
  default = "AllRules"
}

variable "no_public_ip" {
  type    = bool
  default = true
}

variable "vnet_id" {
  type = string
}

variable "private_subnet_name" {
  type = string
}

variable "public_subnet_name" {
  type = string
}

variable "private_nsg_association_id" {
  type = string
}

variable "public_nsg_association_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

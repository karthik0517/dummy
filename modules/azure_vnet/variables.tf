variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "address_space" {
  type = list(string)
}

variable "bgp_community" {
  type    = string
  default = null
}

variable "ddos_protection_plan" {
  type = object({
    id     = string
    enable = bool
  })
  default = null
}

variable "dns_servers" {
  type    = list(string)
  default = []
}

variable "edge_zone" {
  type    = string
  default = null
}

variable "encryption_enforcement" {
  type    = string
  default = null
}

variable "flow_timeout_in_minutes" {
  type    = number
  default = null
}

variable "private_endpoint_vnet_policies" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

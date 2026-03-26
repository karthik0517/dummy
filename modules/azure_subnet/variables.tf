variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "address_prefixes" {
  type = list(string)
}

variable "nsg_id" {
  type = string
}

variable "default_outbound_access_enabled" {
  type    = bool
  default = true
}

variable "private_endpoint_network_policies" {
  type    = string
  default = "Disabled"
}

variable "private_link_service_network_policies_enabled" {
  type    = bool
  default = true
}

variable "service_endpoints" {
  type    = list(string)
  default = []
}

variable "service_endpoint_policy_ids" {
  type    = list(string)
  default = []
}

variable "delegations" {
  type = list(object({
    name = string
    service_delegation = object({
      name    = string
      actions = list(string)
    })
  }))
  default = [
    {
      name = "databricks-delegation"
      service_delegation = {
        name = "Microsoft.Databricks/workspaces"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action",
          "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
          "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
        ]
      }
    }
  ]
}

variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "security_rules" {
  type = list(object({
    name                         = string
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_range            = optional(string)
    source_port_ranges           = optional(list(string))
    destination_port_range       = optional(string)
    destination_port_ranges      = optional(list(string))
    source_address_prefix        = optional(string)
    source_address_prefixes      = optional(list(string))
    destination_address_prefix   = optional(string)
    destination_address_prefixes = optional(list(string))
  }))
  default = [
    {
      name                       = "Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-worker-inbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
    },
    {
      name                       = "Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-worker-outbound"
      priority                   = 100
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
    },
    {
      name                       = "Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-databricks-webapp"
      priority                   = 101
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_ranges    = ["443", "3306", "8443-8451"]
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "AzureDatabricks"
    },
    {
      name                       = "Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-sql"
      priority                   = 102
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3306"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "Sql"
    },
    {
      name                       = "Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-storage"
      priority                   = 103
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "Storage"
    },
    {
      name                       = "Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-eventhub"
      priority                   = 104
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "9093"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "EventHub"
    },
  ]
}

variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "account_tier" {
  type    = string
  default = "Standard"
}

variable "account_replication_type" {
  type    = string
  default = "LRS"
}

variable "account_kind" {
  type    = string
  default = "StorageV2"
}

variable "is_hns_enabled" {
  type    = bool
  default = true
}

variable "min_tls_version" {
  type    = string
  default = "TLS1_2"
}

variable "allow_nested_items_to_be_public" {
  type    = bool
  default = false
}

variable "large_file_share_enabled" {
  type    = bool
  default = true
}

variable "blob_retention_days" {
  type    = number
  default = 7
}

variable "container_retention_days" {
  type    = number
  default = 7
}

variable "share_retention_days" {
  type    = number
  default = 7
}

variable "tags" {
  type    = map(string)
  default = {}
}

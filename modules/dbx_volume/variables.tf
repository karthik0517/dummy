variable "catalog_name" {
  type = string
}

variable "schema_name" {
  type = string
}

variable "name" {
  type = string
}

variable "volume_type" {
  type    = string
  default = "MANAGED"
}

variable "storage_location" {
  type    = string
  default = null
}

variable "comment" {
  type    = string
  default = null
}

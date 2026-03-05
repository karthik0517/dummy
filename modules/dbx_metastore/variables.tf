variable "name" {
  type = string
}

variable "data_access_name" {
  type = string
}

variable "location" {
  type = string
}

variable "storage_root" {
  type = string
}

variable "access_connector_id" {
  type = string
}

variable "force_destroy" {
  type    = bool
  default = false
}

variable "is_default" {
  type    = bool
  default = true
}

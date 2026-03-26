variable "name" {
  type = string
}

variable "access_connector_id" {
  type = string
}

variable "force_destroy" {
  type    = bool
  default = true
}

variable "force_update" {
  type    = bool
  default = false
}

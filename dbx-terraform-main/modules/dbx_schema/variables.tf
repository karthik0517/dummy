variable "name" {
  type = string
}

variable "catalog_name" {
  type = string
}

variable "storage_root" {
  type = string
}

variable "comment" {
  type    = string
  default = ""
}

variable "force_destroy" {
  type    = bool
  default = true
}

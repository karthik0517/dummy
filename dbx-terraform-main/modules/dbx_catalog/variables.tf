variable "name" {
  type = string
}

variable "comment" {
  type    = string
  default = ""
}

variable "storage_root" {
  type = string
}

variable "isolation_mode" {
  type    = string
  default = "OPEN"
}

variable "force_destroy" {
  type    = bool
  default = true
}

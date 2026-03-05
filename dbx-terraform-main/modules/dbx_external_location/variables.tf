variable "name" {
  type = string
}

variable "url" {
  type = string
}

variable "credential_name" {
  type = string
}

variable "isolation_mode" {
  type    = string
  default = "ISOLATION_MODE_ISOLATED"
}

variable "skip_validation" {
  type    = bool
  default = false
}

variable "force_destroy" {
  type    = bool
  default = true
}

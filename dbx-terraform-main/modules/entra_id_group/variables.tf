variable "display_name" {
  type = string
}

variable "security_enabled" {
  type    = bool
  default = true
}

variable "members" {
  type    = list(string)
  default = []
}

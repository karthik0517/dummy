variable "display_name" {
  type = string
}

variable "external_id" {
  type = string
}

variable "workspace_id" {
  type = string
}

variable "workspace_access" {
  type    = bool
  default = true
}

variable "databricks_sql_access" {
  type    = bool
  default = true
}

variable "allow_cluster_create" {
  type    = bool
  default = false
}

variable "allow_instance_pool_create" {
  type    = bool
  default = false
}

variable "permission_level" {
  type    = string
  default = "USER"
}

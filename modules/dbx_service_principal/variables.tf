variable "display_name" {
  type = string
}

variable "workspace_id" {
  type = string
}

variable "permission_level" {
  type    = string
  default = "USER"
}

variable "workspace_access" {
  type    = bool
  default = false
}

variable "databricks_sql_access" {
  type    = bool
  default = false
}

variable "allow_cluster_create" {
  type    = bool
  default = false
}

variable "allow_instance_pool_create" {
  type    = bool
  default = false
}

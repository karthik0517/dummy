variable "cluster_name" {
  type = string
}

variable "spark_version" {
  type = string
}

variable "node_type_id" {
  type = string
}

variable "driver_node_type_id" {
  type = string
}

variable "autotermination_minutes" {
  type    = number
  default = 10
}

variable "policy_id" {
  type = string
}

variable "min_workers" {
  type    = number
  default = 1
}

variable "max_workers" {
  type    = number
  default = 2
}

variable "custom_tags" {
  type    = map(string)
  default = {}
}

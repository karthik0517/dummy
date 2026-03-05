terraform {
  required_providers {
    databricks = {
      source                = "databricks/databricks"
      configuration_aliases = [databricks.workspace]
    }
  }
}

resource "databricks_cluster" "this" {
  provider                = databricks.workspace
  cluster_name            = var.cluster_name
  spark_version           = var.spark_version
  node_type_id            = var.node_type_id
  driver_node_type_id     = var.driver_node_type_id
  autotermination_minutes = var.autotermination_minutes
  policy_id               = var.policy_id

  autoscale {
    min_workers = var.min_workers
    max_workers = var.max_workers
  }

  custom_tags = var.custom_tags
}

terraform {
  required_providers {
    databricks = {
      source                = "databricks/databricks"
      configuration_aliases = [databricks.workspace]
    }
  }
}

resource "databricks_cluster_policy" "data_analyst_no_compute" {
  provider              = databricks.workspace
  name                  = "Data Analyst Policy - No Compute Creation"
  max_clusters_per_user = 0

  definition = jsonencode({
    "driver_node_type_id" = {
      "hidden" = true
      "type"   = "forbidden"
    }
    "node_type_id" = {
      "hidden" = true
      "type"   = "forbidden"
    }
    "spark_version" = {
      "hidden" = true
      "type"   = "forbidden"
    }
  })
}

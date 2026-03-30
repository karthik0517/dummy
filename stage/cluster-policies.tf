module "cluster_policies" {
  source = "../modules/dbx_cluster_policies"
  providers = {
    databricks.workspace = databricks.workspace
  }
}

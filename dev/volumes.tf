module "volume" {
  for_each     = var.volumes
  source       = "../modules/dbx_volume"
  catalog_name = module.catalog.name
  schema_name  = each.value.schema
  name         = replace(each.key, "${each.value.schema}_", "")
  volume_type  = each.value.type
  # For EXTERNAL volumes, build the full ADLS URL from the schema's container + storage_path.
  # MANAGED volumes don't need a storage_location — UC handles it.
  storage_location = each.value.storage_path != null ? "${local.container_url[each.value.schema]}${each.value.storage_path}" : null
  comment          = each.value.comment
  providers = {
    databricks.workspace = databricks.workspace
  }
  depends_on = [databricks_schema.this]
}

locals {
  schemas          = toset(var.schemas)
  all_schemas      = setunion(local.schemas, var.managed_schemas)
  standard_schemas = toset([for s in local.schemas : s if s != "bronze_jde"])
  container_name   = { for s in local.schemas : s => replace(s, "_", "-") }
  container_url    = { for s in local.schemas : s => "abfss://${local.container_name[s]}@${module.storage_account_databricks.name}.dfs.core.windows.net/" }
}

resource "azurerm_storage_container" "schema" {
  for_each           = local.schemas
  name               = local.container_name[each.key]
  storage_account_id = module.storage_account_databricks.id
}

resource "databricks_external_location" "this" {
  for_each        = local.standard_schemas
  provider        = databricks.workspace
  name            = "${local.container_name[each.key]}-${module.storage_account_databricks.name}"
  url             = local.container_url[each.key]
  credential_name = module.storage_credential.name
  force_destroy   = true
}

resource "databricks_external_location" "bronze_jde_ogg" {
  provider        = databricks.workspace
  name            = "${module.storage_account_databricks.name}-bronze-jde-ogg"
  url             = "${local.container_url["bronze_jde"]}ogg_external_data/"
  credential_name = module.storage_credential.name
}

resource "databricks_external_location" "bronze_jde_managed" {
  provider        = databricks.workspace
  name            = "${module.storage_account_databricks.name}-bronze-jde-managed"
  url             = "${local.container_url["bronze_jde"]}dbx_managed_tables/"
  credential_name = module.storage_credential.name
}

resource "databricks_schema" "this" {
  for_each      = local.all_schemas
  provider      = databricks.workspace
  catalog_name  = module.catalog.name
  name          = each.key
  comment       = "Managed via Terraform"
  owner         = module.role_group["admins"].display_name
  force_destroy = true
  storage_root = contains(var.managed_schemas, each.key) ? null : (
    each.key == "bronze_jde" ? "${local.container_url["bronze_jde"]}dbx_managed_tables/" : local.container_url[each.key]
  )

  properties = {
    "managed_by"  = "terraform"
    "environment" = local.environment
  }

  depends_on = [
    databricks_external_location.this,
    databricks_external_location.bronze_jde_managed,
  ]
}

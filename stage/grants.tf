locals {
  ogg_service_principal_app_id = "2ebe44c7-d6c0-437f-aba1-2d665cda2327"

  # --- Catalog grants: one entry per principal ---
  catalog_role_grants = {
    admins         = { principal = module.role_group["admins"].display_name, privileges = ["USE_CATALOG", "CREATE_SCHEMA", "MANAGE", "CREATE_VOLUME"] }
    dataarchitects = { principal = module.role_group["dataarchitects"].display_name, privileges = ["USE_CATALOG"] }
    dataengineers  = { principal = module.role_group["dataengineers"].display_name, privileges = ["USE_CATALOG"] }
    dataanalysts   = { principal = module.role_group["dataanalysts"].display_name, privileges = ["USE_CATALOG"] }
    qa             = { principal = module.role_group["qa"].display_name, privileges = ["USE_CATALOG"] }
    svc            = { principal = module.role_group["svc"].display_name, privileges = ["USE_CATALOG"] }
  }

  catalog_sp_grants = {
    for sp_key, schemas in var.service_principals : "sp_${sp_key}" => {
      principal  = module.service_principal[sp_key].application_id
      privileges = ["USE_CATALOG"]
    }
    if length(schemas) > 0
  }

  catalog_grants = merge(local.catalog_role_grants, local.catalog_sp_grants)

  # --- Schema grants: one entry per schema/principal pair ---
  schema_base_roles = {
    admins         = ["MANAGE", "USE_SCHEMA"]
    dataarchitects = ["SELECT", "USE_SCHEMA"]
    dataengineers  = ["SELECT", "USE_SCHEMA"]
    dataanalysts   = ["SELECT", "USE_SCHEMA"]
    qa             = ["MANAGE", "USE_SCHEMA"]
  }

  schema_role_grants = merge([
    for schema in local.all_schemas : {
      for role, privileges in local.schema_base_roles :
      "${schema}/${role}" => {
        schema     = schema
        principal  = module.role_group[role].display_name
        privileges = privileges
      }
      if role != "dataanalysts" || startswith(schema, "silver_") || startswith(schema, "gold_")
    }
  ]...)

  schema_group_grants = {
    for schema in local.all_schemas :
    "${schema}/schema_group" => {
      schema     = schema
      principal  = module.schema_group[schema].display_name
      privileges = ["USE_SCHEMA", "SELECT", "EXECUTE"]
    }
  }

  schema_sp_grants = merge([
    for schema in local.all_schemas : {
      for sp_key, schemas in var.service_principals :
      "${schema}/sp_${sp_key}" => {
        schema     = schema
        principal  = module.service_principal[sp_key].application_id
        privileges = schemas[schema]
      }
      if contains(keys(schemas), schema)
    }
  ]...)

  schema_bronze_jde_extra_grants = {
    "bronze_jde/svc" = {
      schema     = "bronze_jde"
      principal  = module.role_group["svc"].display_name
      privileges = ["ALL_PRIVILEGES"]
    }
    "bronze_jde/ogg" = {
      schema     = "bronze_jde"
      principal  = local.ogg_service_principal_app_id
      privileges = ["USE_SCHEMA", "SELECT", "MODIFY", "CREATE_TABLE", "CREATE_FUNCTION", "CREATE_VOLUME", "READ_VOLUME", "WRITE_VOLUME", "EXECUTE"]
    }
  }

  schema_bidtracer_overrides = {
    "bronze_bidtracer/admins" = {
      schema     = "bronze_bidtracer"
      principal  = module.role_group["admins"].display_name
      privileges = ["CREATE_TABLE", "MANAGE", "SELECT", "USE_SCHEMA"]
    }
    "copper_bidtracer/admins" = {
      schema     = "copper_bidtracer"
      principal  = module.role_group["admins"].display_name
      privileges = ["CREATE_TABLE", "MANAGE", "USE_SCHEMA"]
    }
    "silver_bidtracer/admins" = {
      schema     = "silver_bidtracer"
      principal  = module.role_group["admins"].display_name
      privileges = ["CREATE_TABLE", "MANAGE", "SELECT", "USE_SCHEMA"]
    }
    "silver_bidtracer/schema_group" = {
      schema     = "silver_bidtracer"
      principal  = module.schema_group["silver_bidtracer"].display_name
      privileges = ["EXECUTE", "READ_VOLUME", "SELECT", "USE_SCHEMA"]
    }
  }

  schema_grants = merge(
    local.schema_role_grants,
    local.schema_group_grants,
    local.schema_sp_grants,
    local.schema_bronze_jde_extra_grants,
    local.schema_bidtracer_overrides,
  )
}

# --- Catalog (per-principal) ---
resource "databricks_grant" "catalog" {
  for_each   = local.catalog_grants
  provider   = databricks.workspace
  catalog    = module.catalog.name
  principal  = each.value.principal
  privileges = each.value.privileges
}

# --- Schemas (per schema/principal pair) ---
resource "databricks_grant" "schema" {
  for_each   = local.schema_grants
  provider   = databricks.workspace
  schema     = "${module.catalog.name}.${each.value.schema}"
  principal  = each.value.principal
  privileges = each.value.privileges

  depends_on = [databricks_schema.this]
}

# --- External locations ---
resource "databricks_grants" "external_location" {
  for_each          = local.standard_schemas
  provider          = databricks.workspace
  external_location = databricks_external_location.this[each.key].name

  grant {
    principal = module.role_group["admins"].display_name
    privileges = [
      "ALL_PRIVILEGES",
      "MANAGE",
    ]
  }
  grant {
    principal  = "account users"
    privileges = ["READ_FILES"]
  }
}

resource "databricks_grants" "external_location_bronze_jde_managed" {
  provider          = databricks.workspace
  external_location = databricks_external_location.bronze_jde_managed.name

  grant {
    principal = module.role_group["admins"].display_name
    privileges = [
      "ALL_PRIVILEGES",
      "MANAGE",
    ]
  }
  grant {
    principal  = "account users"
    privileges = ["READ_FILES"]
  }
  grant {
    principal = module.role_group["svc"].display_name
    privileges = [
      "CREATE_EXTERNAL_TABLE",
    ]
  }
}

resource "databricks_grants" "external_location_bronze_jde_ogg" {
  provider          = databricks.workspace
  external_location = databricks_external_location.bronze_jde_ogg.name

  grant {
    principal = module.role_group["admins"].display_name
    privileges = [
      "ALL_PRIVILEGES",
      "MANAGE",
    ]
  }
  grant {
    principal  = "account users"
    privileges = ["READ_FILES"]
  }
  grant {
    principal = module.role_group["svc"].display_name
    privileges = [
      "CREATE_EXTERNAL_TABLE",
    ]
  }
  grant {
    principal = local.ogg_service_principal_app_id
    privileges = [
      "READ_FILES",
      "WRITE_FILES",
    ]
  }
}

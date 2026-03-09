locals {
  # OGG service principal for JDE replication — gets elevated privileges on
  # bronze_jde schema and its external locations only.
  # databricks_grants requires application_id, not display name.
  ogg_service_principal_app_id = "c99ea0e4-b29a-46fe-b327-e5a41403b4ed"
}

# --- Catalog ---
resource "databricks_grants" "catalog" {
  provider = databricks.workspace
  catalog  = module.catalog.name

  grant {
    principal = module.role_group["admins"].display_name
    privileges = [
      "USE_CATALOG",
      "CREATE_SCHEMA",
      "MANAGE",
      "CREATE_VOLUME",
    ]
  }
  grant {
    principal = module.role_group["dataarchitects"].display_name
    privileges = [
      "USE_CATALOG",
      "CREATE_SCHEMA",
      "CREATE_VOLUME",
      "MANAGE",
    ]
  }
  grant {
    principal = module.role_group["dataengineers"].display_name
    privileges = [
      "USE_CATALOG"
    ]
  }
  grant {
    principal = module.role_group["dataanalysts"].display_name
    privileges = [
      "USE_CATALOG"
    ]
  }
  grant {
    principal = module.role_group["qa"].display_name
    privileges = [
      "USE_CATALOG"
    ]
  }
  grant {
    principal = module.role_group["svc"].display_name
    privileges = [
      "USE_CATALOG"
    ]
  }

}

# --- Standard schemas ---
resource "databricks_grants" "schema" {
  for_each = toset([for s in local.all_schemas : s if s != "bronze_jde"])
  provider = databricks.workspace
  schema   = "${module.catalog.name}.${each.key}"

  grant {
    principal = module.role_group["admins"].display_name
    privileges = [
      "ALL_PRIVILEGES",
      "MANAGE",
    ]
  }
  grant {
    principal = module.role_group["dataarchitects"].display_name
    privileges = [
      "MODIFY",
      "CREATE_TABLE",
      "CREATE_VOLUME",
      "USE_SCHEMA",
      "SELECT",
    ]
  }
  grant {
    principal = module.role_group["dataengineers"].display_name
    privileges = [
      "MODIFY",
      "CREATE_TABLE",
      "CREATE_FUNCTION",
      "USE_SCHEMA",
      "SELECT",
    ]
  }
  grant {
    principal = module.role_group["dataanalysts"].display_name
    privileges = [
      "USE_SCHEMA",
      "SELECT",
    ]
  }
  grant {
    principal = module.role_group["qa"].display_name
    privileges = [
      "USE_SCHEMA",
      "MANAGE",
    ]
  }
  grant {
    principal = module.schema_group[each.key].display_name
    privileges = [
      "USE_SCHEMA",
      "SELECT",
      "EXECUTE",
    ]
  }

  depends_on = [databricks_schema.this]
}

# bronze_jde is managed separately from standard schemas because the OGG service
# principal needs elevated write/create privileges for JDE replication
resource "databricks_grants" "schema_bronze_jde" {
  provider = databricks.workspace
  schema   = "${module.catalog.name}.bronze_jde"

  grant {
    principal = module.role_group["admins"].display_name
    privileges = [
      "ALL_PRIVILEGES",
      "MANAGE",
    ]
  }
  grant {
    principal = module.role_group["dataarchitects"].display_name
    privileges = [
      "MODIFY",
      "CREATE_TABLE",
      "CREATE_VOLUME",
      "USE_SCHEMA",
      "SELECT",
    ]
  }
  grant {
    principal = module.role_group["dataengineers"].display_name
    privileges = [
      "MODIFY",
      "CREATE_TABLE",
      "CREATE_FUNCTION",
      "USE_SCHEMA",
      "SELECT",
    ]
  }
  grant {
    principal = module.role_group["dataanalysts"].display_name
    privileges = [
      "USE_SCHEMA",
      "SELECT",
    ]
  }
  grant {
    principal = module.role_group["qa"].display_name
    privileges = [
      "USE_SCHEMA",
      "MANAGE",
    ]
  }
  grant {
    principal = module.schema_group["bronze_jde"].display_name
    privileges = [
      "USE_SCHEMA",
      "SELECT",
      "EXECUTE",
    ]
  }
  grant {
    principal = local.ogg_service_principal_app_id
    privileges = [
      "USE_SCHEMA",
      "SELECT",
      "MODIFY",
      "CREATE_TABLE",
      "CREATE_FUNCTION",
      "CREATE_VOLUME",
      "READ_VOLUME",
      "WRITE_VOLUME",
      "EXECUTE",
    ]
  }

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
    principal = module.role_group["dataarchitects"].display_name
    privileges = [
      "READ_FILES"
    ]
  }
  grant {
    principal = module.role_group["dataengineers"].display_name
    privileges = [
      "READ_FILES"
    ]
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
    principal = module.role_group["dataarchitects"].display_name
    privileges = [
      "READ_FILES"
    ]
  }
  grant {
    principal = module.role_group["dataengineers"].display_name
    privileges = [
      "READ_FILES"
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
    principal = module.role_group["dataarchitects"].display_name
    privileges = [
      "READ_FILES"
    ]
  }
  grant {
    principal = module.role_group["dataengineers"].display_name
    privileges = [
      "READ_FILES"
    ]
  }
  # OGG service principal needs write access for JDE replication data
  grant {
    principal = local.ogg_service_principal_app_id
    privileges = [
      "READ_FILES",
      "WRITE_FILES",
    ]
  }

}

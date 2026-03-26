# dbx-terraform

Terraform for Acco's Databricks platform on Azure. Manages the workspace, networking, Unity Catalog, identity, and governance.

## Repository structure

```
dbx-terraform/
  dev/              Dev environment
  test/             Test environment
  shared/           Shared networking (virtual network, subnets, network security groups, network address translation)
  modules/          Reusable Terraform modules
```

## Common tasks

Most pull requests touch `terraform.tfvars` in an environment directory.

### Add schemas (with dedicated storage)

Add entries to the `schemas` list in `<env>/terraform.tfvars`:

```hcl
schemas = [
  # ... existing schemas ...
  "bronze_newdata",
  "copper_newdata",
  "silver_newdata",
  "gold_newdata",
]
```

Schema names must be `lowercase_with_underscores` with at least one underscore (e.g. `bronze_jde`). Only add the layers you need.

This creates:

- An Azure Data Lake Storage container (underscores become dashes, e.g. `bronze-newdata`)
- A `databricks_schema` in the environment's catalog
- A `databricks_external_location` pointing to the container
- Per-schema Entra ID and Databricks groups and grants

### Add schemas (without dedicated storage)

For schemas that don't need their own storage container (sandboxes, staging areas, view-only schemas), use `managed_schemas`:

```hcl
managed_schemas = [
  "sandbox_analytics",
]
```

This creates the schema, groups, and grants but no storage container or external location. Unity Catalog stores data in the catalog's default storage root.

### Create a service principal

Add an entry to the `service_principals` map in `<env>/terraform.tfvars`:

```hcl
service_principals = {
  bidtracer = {
    bronze_bidtracer          = ["CREATE_MATERIALIZED_VIEW", "CREATE_TABLE", "READ_VOLUME", "SELECT", "USE_SCHEMA"]
    silver_bidtracer          = ["CREATE_MATERIALIZED_VIEW", "CREATE_TABLE", "MODIFY", "READ_VOLUME", "SELECT", "USE_SCHEMA"]
    copper_bidtracer          = ["CREATE_TABLE", "READ_VOLUME", "SELECT", "USE_SCHEMA"]
    copper_inspection_service = ["CREATE_TABLE", "MODIFY", "READ_VOLUME", "SELECT", "USE_SCHEMA"]
  }
  project_assistant = {}
}
```

The key becomes the display name: `sp_acco_dbx_{key}_{environment}` (e.g. `sp_acco_dbx_bidtracer_dev`). Each entry maps a schema name to a list of privileges. An empty map (like `project_assistant`) creates the service principal with no schema grants.

This creates:

- A Databricks service principal at the account level
- A workspace assignment with USER permissions
- A `USE_CATALOG` grant on the environment catalog
- The specified privileges on each listed schema

The schemas must already exist in `schemas` or `managed_schemas`. You can add new schemas and a new service principal in the same pull request.

### Delete a schema

Remove the entry from `schemas` or `managed_schemas` in `<env>/terraform.tfvars` and apply. Terraform drops the schema, its storage container (if it had one), external location, groups, and grants.

The `force_destroy` flag is set on schemas, so Terraform can drop them even if they still contain tables. Verify the schema is no longer needed before removing it — there is no undo once the storage container is deleted.

### Rename a schema

If the schema is empty, change the name in `schemas` or `managed_schemas` and apply. Terraform destroys the old one and creates the new one.

If the schema has data, rename in Databricks first, then sync state:

1. `ALTER SCHEMA <catalog>.old_name RENAME TO new_name`
2. Change the name in `terraform.tfvars`
3. Run `terraform state mv` for each affected resource:

```bash
terraform state mv 'databricks_schema.this["old_name"]' 'databricks_schema.this["new_name"]'
terraform state mv 'azurerm_storage_container.schema["old_name"]' 'azurerm_storage_container.schema["new_name"]'
terraform state mv 'databricks_external_location.this["old_name"]' 'databricks_external_location.this["new_name"]'
terraform state mv 'module.schema_group["old_name"]' 'module.schema_group["new_name"]'
terraform state mv 'databricks_grants.schema["old_name"]' 'databricks_grants.schema["new_name"]'
terraform state mv 'databricks_grants.external_location["old_name"]' 'databricks_grants.external_location["new_name"]'
```

4. Run `terraform plan` to verify no destroy/create.

For managed schemas, skip the `azurerm_storage_container`, `databricks_external_location`, and `databricks_grants.external_location` state moves.

### Add a role group

Edit `<env>/groups.tf` and add an entry to the `groups` map:

```hcl
locals {
  groups = {
    newrole = { allow_cluster_create = false, permission = "USER" }
  }
}
```

This creates an Entra ID group, a Databricks account-level group, and a workspace permission assignment. The display name follows `App Access - Databricks ACCO <Role> <Env>`.

After adding the group, add grant blocks in `<env>/grants.tf` for catalog and schema access. Use the existing `dataanalysts` blocks as a template for read-only access, or `dataengineers` for read-write.

### Add a cluster policy

Edit `<env>/cluster-policies.tf`:

```hcl
resource "databricks_cluster_policy" "example_policy" {
  provider              = databricks.workspace
  name                  = "Example Policy"
  max_clusters_per_user = 1

  definition = jsonencode({
    "autotermination_minutes" = {
      "type"         = "fixed"
      "value"        = 30
      "hidden"       = true
    }
    "node_type_id" = {
      "type"         = "allowlist"
      "values"       = ["Standard_DS3_v2", "Standard_DS4_v2"]
    }
  })
}
```

Policy field types: `fixed` (locked value), `allowlist` (user picks from list), `forbidden` (field hidden and blocked).

## Notable exceptions

### bronze_jde

`bronze_jde` has a custom setup because its storage container is shared between Databricks-managed tables (`/dbx_managed_tables/`) and JDE Oracle GoldenGate replication (`/ogg_external_data/`). It gets a custom `storage_root` plus two extra external locations (`bronze_jde_ogg` and `bronze_jde_managed`).

# dbx-terraform

Terraform for Acco's Databricks platform on Azure. Manages the workspace, networking, Unity Catalog, identity, and governance layers.

## Repository structure

```
dbx-terraform/
  dev/              Dev environment (workspace, catalog, schemas, grants, groups)
  shared/           Shared non-prod networking (VNet, subnets, NSGs, NAT)
  test/             Test environment (resource group only, workspace not yet configured)
  prod/             Production (empty, future use)
  stage/            Staging (empty, future use)
  modules/          Reusable Terraform modules
```

## What this repo manages

| Layer | Resources | Directory |
|---|---|---|
| Azure networking | VNet, subnets (private/public per env), NSGs, NAT gateway, public IP | `shared/` |
| Azure compute | Databricks workspace, access connector, storage account (ADLS Gen2) | `dev/` |
| Azure IAM | Role assignments for access connector and JDE service principal | `dev/` |
| Identity | Entra ID groups, Databricks account-level groups, per-schema groups | `dev/` |
| Unity Catalog | Catalog, schemas (medallion layers), external locations, storage credential, volumes | `dev/` |
| Governance | Grants on metastore, catalog, schemas, external locations | `dev/` |
| Compute policies | Cluster policies that restrict what users can provision | `dev/` |

## Common tasks for data engineers

Most PRs from data engineers will touch one of these files. Each section shows exactly what to edit and what happens automatically. Examples use `dev/` but the same patterns apply to `test/`, `stage/`, and `prod/` once those environments are built out.

### Onboard a new data source

When a new data source needs bronze/copper/silver/gold schemas:

1. **Edit `<env>/terraform.tfvars`** -- add entries to the `schemas` list:

```hcl
schemas = [
  # ... existing schemas ...
  "bronze_newdata",
  "copper_newdata",
  "silver_newdata",
  "gold_newdata",
]
```

This automatically creates for each schema:

- An Azure storage container (name is the schema with underscores replaced by dashes, e.g. `bronze-newdata`)
- A `databricks_schema` in the environment's catalog
- A `databricks_external_location` pointing to the container

It also automatically creates per-schema Entra ID + Databricks groups (via `groups.tf`) and grants (via `grants.tf`) using the standard privilege sets.

1. If the new source only needs some layers (e.g. bronze and silver but no gold), only add those entries. There's no requirement for all four.

### Add a schema without dedicated storage

If you need a schema that doesn't require its own ADLS storage container (e.g. a sandbox, staging area, or schema that only contains views), add it to the `managed_schemas` list instead:

**Edit `<env>/terraform.tfvars`**:

```hcl
managed_schemas = [
  "sandbox_analytics",
]
```

This creates:

- A `databricks_schema` in the catalog (UC stores data in the catalog's default storage root)
- Per-schema Entra ID + Databricks groups (via `groups.tf`)
- Standard grants (via `grants.tf`)

It does **not** create a storage container or external location. Unity Catalog manages the underlying storage automatically using the catalog's default storage root.

Use `managed_schemas` when the schema only needs a namespace in the catalog and doesn't need its own dedicated ADLS container.

### Rename a schema

**If the schema is empty or has no data you need to keep**, just change the name in the `schemas` or `managed_schemas` list and apply. Terraform destroys the old schema and creates the new one.

**If the schema has data you need to preserve**, rename in Databricks first, then sync Terraform:

1. Rename in Databricks via SQL: `ALTER SCHEMA <catalog>.old_name RENAME TO new_name`
2. Change the name in `<env>/terraform.tfvars`
3. Run `terraform state mv` for each affected resource to update the state keys:

```bash
terraform state mv 'databricks_schema.this["old_name"]' 'databricks_schema.this["new_name"]'
terraform state mv 'azurerm_storage_container.schema["old_name"]' 'azurerm_storage_container.schema["new_name"]'
terraform state mv 'databricks_external_location.this["old_name"]' 'databricks_external_location.this["new_name"]'
terraform state mv 'module.schema_group["old_name"]' 'module.schema_group["new_name"]'
terraform state mv 'databricks_grants.schema["old_name"]' 'databricks_grants.schema["new_name"]'
terraform state mv 'databricks_grants.external_location["old_name"]' 'databricks_grants.external_location["new_name"]'
```

4. Run `terraform plan` to verify no destroy/create. The storage container keeps its original name (Azure containers can't be renamed) and the schema's `storage_root` still points to it.

For managed schemas, skip the `azurerm_storage_container`, `databricks_external_location`, and `databricks_grants.external_location` state moves since those resources don't exist.

### Add a volume

**Edit `<env>/terraform.tfvars`** -- add an entry to the `volumes` map.

For a managed volume (UC handles storage):

```hcl
volumes = {
  # ... existing volumes ...
  copper_newdata_raw_files = { schema = "copper_newdata", type = "MANAGED" }
}
```

For an external volume (points to a path within the schema's ADLS container):

```hcl
volumes = {
  # ... existing volumes ...
  bronze_newdata_landing = {
    schema       = "bronze_newdata"
    type         = "EXTERNAL"
    storage_path = "landing"
    comment      = "Landing zone for newdata ingestion"
  }
}
```

The volume name in Databricks is derived by stripping the schema prefix from the map key. So `copper_newdata_raw_files` in the `copper_newdata` schema becomes a volume named `raw_files`.

For external volumes, `storage_path` is the path within the schema's ADLS container. The full URL is computed automatically (e.g. `storage_path = "landing"` becomes `abfss://bronze-newdata@<storage_account>.dfs.core.windows.net/landing`).

### Add a role group

**Edit `<env>/groups.tf`** -- add an entry to the `groups` map:

```hcl
locals {
  groups = {
    # ... existing groups ...
    newrole = { allow_cluster_create = false, permission = "USER" }
  }
}
```

This creates an Entra ID group, a Databricks account-level group, and a workspace permission assignment. The display name follows the convention `App Access - Databricks ACCO <Role> <Env>`.

After adding the group, you'll also need to add grant blocks in `<env>/grants.tf` for catalog and schema access. Look at the existing `dataanalysts` grant blocks as a template for read-only access, or `dataengineers` for read-write.

### Grant a service principal access to a schema

If a service principal needs access to a specific schema (like the JDE OGG replication scenario):

1. Add a local for the SP name in `<env>/grants.tf`
2. Add a `grant` block inside the relevant `databricks_grants` resource

Look at `schema_bronze_jde` in `dev/grants.tf` for an example of a schema with an extra service principal grant.

### Add a cluster policy

**Edit `<env>/cluster-policies.tf`**. Each policy is a standalone resource:

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

The `definition` field must be a JSON string. Use `jsonencode()` so you can write it in HCL syntax. Common policy field types: `fixed` (locked value), `allowlist` (user picks from list), `forbidden` (field hidden and blocked).

### Add a new environment

To stand up test, stage, or prod:

1. Copy `dev/` to `<env>/`
2. Update `locals` in `main.tf`: change `environment`, subscription IDs, tags, and SP IDs as needed
3. Update `terraform.tf`: change the backend `key` to `dbx-terraform-<env>.tfstate` and point the workspace provider to the new workspace
4. Update `shared/` if the new environment needs its own subnets and NSG (test already has subnets provisioned)
5. Review `force_destroy`, `public_network_access_enabled`, and other dev-specific flags before applying to prod

## Environments

Each environment has its own directory and state file in Azure Blob Storage (`staccotfstatewestus2/tfstate/dbx-terraform-ENV`).

- The Databricks account ID lives in `shared/` because it's org-wide, not per-workspace

## Notable exceptions and overrides

Documented with inline comments in the relevant files.

### bronze_jde (schemas.tf, grants.tf)

`bronze_jde` is handled separately from standard schemas. Its ADLS container is shared between two consumers:

- Databricks-managed tables write to `/dbx_managed_tables/`
- JDE Oracle GoldenGate replication writes to `/ogg_external_data/`

This means `bronze_jde` gets a custom `storage_root` pointing to the subfolder, plus two extra external locations (`bronze_jde_ogg` and `bronze_jde_managed`). It also has an extra grant block giving the OGG service principal (`sp_acco_dbx_jde_dev`) elevated write privileges.

### public_network_access_enabled (main.tf)

Set to `true` in dev so engineers can access the workspace console from their browsers. Set `false` in prod behind Private Link.

### force_destroy on schemas (schemas.tf)

Set to `true` so `terraform destroy` can drop schemas even if they contain tables. Without this, destroy fails on non-empty schemas. Acceptable in dev; review before applying to prod.

### allow_cluster_create (groups.tf)

Only `admins` and `dataarchitects` can create clusters (`true`). Everyone else (`false`) uses shared compute or cluster policies. This prevents uncontrolled compute spend.

### Data analyst cluster policy (cluster-policies.tf)

Sets `max_clusters_per_user = 0` and marks all cluster config fields as hidden/forbidden. Blocks the "Create Cluster" UI entirely for users assigned to this policy.

### External volumes (volumes.tf)

Most volumes are `MANAGED` (UC-managed storage). `bronze_test_landing` is `EXTERNAL`, pointing to a specific ADLS path used as a landing zone where external systems drop files before ingestion.

### Old vs new subnets (shared/main.tf)

The shared directory has two sets of dev subnets. The original pair (`snet-private-acco-dev-dbx-westus2`, `snet-public-acco-dev-dbx-westus2`) are kept for backward compatibility. The active workspace uses the `_new` pair with the `-wus2` suffix.

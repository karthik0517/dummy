# Temporary nightly sync — deep clones managed tables from dev_catalog (old workspace
# storage) into dev_v2_catalog (this workspace). Both catalogs share the same Unity
# Catalog metastore, so cross-catalog reads work without cross-workspace API calls.
#
# Delete this file (and the role assignment) after migration cutover.

# DEEP CLONE reads data files from the old storage account (staccodbxdevwestus2).
# The new workspace's access connector only has access to the new storage account
# by default, so it needs read access on the old one for the clone to copy files.
data "azurerm_storage_account" "old_workspace" {
  name                = "staccodbxdevwestus2"
  resource_group_name = "rg-acco-dev-dbx-westus2"
}

resource "azurerm_role_assignment" "sync_old_storage_reader" {
  scope                = data.azurerm_storage_account.old_workspace.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = module.access_connector_databricks.principal_id
}

data "databricks_spark_version" "lts" {
  provider          = databricks.workspace
  long_term_support = true
}

resource "databricks_notebook" "nightly_sync" {
  provider       = databricks.workspace
  path           = "/Shared/migration/nightly_deep_clone_sync"
  language       = "PYTHON"
  content_base64 = base64encode(local.sync_notebook_content)
}

resource "databricks_job" "nightly_sync" {
  provider = databricks.workspace
  name     = "Migration: Nightly Deep Clone Sync"

  task {
    task_key = "deep_clone_sync"

    notebook_task {
      notebook_path = databricks_notebook.nightly_sync.path
    }

    new_cluster {
      spark_version      = data.databricks_spark_version.lts.id
      num_workers        = 0
      node_type_id       = "Standard_DS3_v2"
      data_security_mode = "SINGLE_USER"

      spark_conf = {
        "spark.master"                     = "local[*]"
        "spark.databricks.cluster.profile" = "singleNode"
      }

      custom_tags = {
        "ResourceClass" = "SingleNode"
      }
    }

    # Initial bootstrap clones all managed tables and may take longer than
    # subsequent incremental runs. 4 hours accommodates the first full copy.
    timeout_seconds = 14400
  }

  # Job runs as whoever applies Terraform (typically sp_acco_dbx_tf).
  # That identity needs USE_CATALOG + SELECT on dev_catalog (old) and
  # USE_CATALOG + CREATE_TABLE + MODIFY on dev_v2_catalog (new).

  schedule {
    quartz_cron_expression = "0 0 2 * * ?"
    timezone_id            = "America/Los_Angeles"
  }

  email_notifications {
    on_failure = ["jonmoss@consultant.accoes.com"]
  }

  tags = {
    purpose   = "migration"
    temporary = "true"
  }
}

locals {
  sync_notebook_content = file("${path.module}/scripts/nightly_deep_clone_sync.py")
}

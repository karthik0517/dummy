resource "azurerm_storage_account" "this" {
  name                            = var.name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = var.account_tier
  account_replication_type        = var.account_replication_type
  account_kind                    = var.account_kind
  is_hns_enabled                  = var.is_hns_enabled
  min_tls_version                 = var.min_tls_version
  allow_nested_items_to_be_public = var.allow_nested_items_to_be_public
  large_file_share_enabled        = var.large_file_share_enabled

  blob_properties {
    delete_retention_policy {
      days = var.blob_retention_days
    }
    container_delete_retention_policy {
      days = var.container_retention_days
    }
  }

  share_properties {
    retention_policy {
      days = var.share_retention_days
    }
  }

  tags = var.tags
}

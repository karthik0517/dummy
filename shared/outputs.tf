output "vnet_non_prod_id" {
  value = module.vnet_non_prod.id
}

output "subnet_private_dev_name" {
  value = module.subnet_private_dev.name
}

output "subnet_public_dev_name" {
  value = module.subnet_public_dev.name
}

output "subnet_private_dev_nsg_association_id" {
  value = module.subnet_private_dev.nsg_association_id
}

output "subnet_public_dev_nsg_association_id" {
  value = module.subnet_public_dev.nsg_association_id
}

output "subnet_private_dev_new_name" {
  value = module.subnet_private_dev_new.name
}

output "subnet_public_dev_new_name" {
  value = module.subnet_public_dev_new.name
}

output "subnet_private_dev_new_nsg_association_id" {
  value = module.subnet_private_dev_new.nsg_association_id
}

output "subnet_public_dev_new_nsg_association_id" {
  value = module.subnet_public_dev_new.nsg_association_id
}

output "databricks_account_id" {
  value = local.databricks_account_id
}

output "databricks_metastore_id" {
  value = local.databricks_metastore_id
}

output "subnet_private_test_name" {
  value = module.subnet_private_test.name
}

output "subnet_public_test_name" {
  value = module.subnet_public_test.name
}

output "subnet_private_test_nsg_association_id" {
  value = module.subnet_private_test.nsg_association_id
}

output "subnet_public_test_nsg_association_id" {
  value = module.subnet_public_test.nsg_association_id
}

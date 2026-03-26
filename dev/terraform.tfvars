schemas = [
  "ops_observability",
  "ops_governance",
  "ops_recovery",
  "bronze_bidtracer",
  "bronze_boomi_process_reporting",
  "bronze_fabpro",
  "bronze_inspection_service",
  "bronze_jde",
  "bronze_profitool",
  "bronze_salesforce",
  "bronze_sbc_ops_report",
  "bronze_shared",
  "bronze_test",
  "copper_bidtracer",
  "copper_boomi_process_reporting",
  "copper_fabpro",
  "copper_inspection_service",
  "copper_jde",
  "copper_profitool",
  "copper_salesforce",
  "copper_sbc_ops_report",
  "gold_fabpro",
  "gold_inspection_service",
  "gold_jde",
  "gold_project_data",
  "gold_salesforce",
  "gold_shared",
  "gold_test",
  "silver_bidtracer",
  "silver_boomi_process_reporting",
  "silver_fabpro",
  "silver_inspection_service",
  "silver_jde",
  "silver_jobdata_tm1",
  "silver_profitool",
  "silver_salesforce",
  "silver_shared",
  "silver_test",
]

managed_schemas = []

service_principals = {
  bidtracer = {
    bronze_bidtracer          = ["CREATE_MATERIALIZED_VIEW", "CREATE_TABLE", "READ_VOLUME", "SELECT", "USE_SCHEMA"]
    silver_bidtracer          = ["CREATE_MATERIALIZED_VIEW", "CREATE_TABLE", "MODIFY", "READ_VOLUME", "SELECT", "USE_SCHEMA"]
    copper_bidtracer          = ["CREATE_TABLE", "READ_VOLUME", "SELECT", "USE_SCHEMA"]
    copper_inspection_service = ["CREATE_TABLE", "MODIFY", "READ_VOLUME", "SELECT", "USE_SCHEMA"]
  }
  inspection_service = {
    bronze_inspection_service = ["CREATE_MATERIALIZED_VIEW", "CREATE_TABLE", "CREATE_VOLUME", "READ_VOLUME", "SELECT", "USE_SCHEMA", "WRITE_VOLUME"]
    copper_inspection_service = ["CREATE_TABLE", "CREATE_VOLUME", "READ_VOLUME", "SELECT", "USE_SCHEMA", "WRITE_VOLUME"]
    gold_inspection_service   = ["CREATE_TABLE", "CREATE_VOLUME", "READ_VOLUME", "SELECT", "USE_SCHEMA", "WRITE_VOLUME"]
    silver_inspection_service = ["CREATE_TABLE", "CREATE_VOLUME", "READ_VOLUME", "SELECT", "USE_SCHEMA", "WRITE_VOLUME"]
  }
}

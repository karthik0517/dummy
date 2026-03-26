schemas = [
  "audit_common",
  "bronze_bidtracer",
  "bronze_inspection_service",
  "bronze_jde",
  "bronze_profitool",
  "bronze_salesforce",
  "bronze_shared",
  "bronze_test",
  "copper_bidtracer",
  "copper_inspection_service",
  "copper_jde",
  "copper_profitool",
  "copper_salesforce",
  "gold_inspection_service",
  "gold_shared",
  "gold_test",
  "silver_bidtracer",
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
  inspection_service = {
    bronze_inspection_service = ["CREATE_MATERIALIZED_VIEW", "CREATE_TABLE", "READ_VOLUME", "SELECT", "USE_SCHEMA", "WRITE_VOLUME"]
    copper_inspection_service = ["USE_SCHEMA"]
    gold_inspection_service   = ["CREATE_MATERIALIZED_VIEW", "CREATE_TABLE", "CREATE_VOLUME", "MODIFY", "READ_VOLUME", "SELECT", "USE_SCHEMA", "WRITE_VOLUME"]
    silver_inspection_service = ["CREATE_MATERIALIZED_VIEW", "CREATE_TABLE", "MODIFY", "READ_VOLUME", "SELECT", "USE_SCHEMA", "WRITE_VOLUME"]
  }
  project_assistant = {
    copper_inspection_service = ["CREATE_MATERIALIZED_VIEW", "CREATE_TABLE", "MODIFY", "READ_VOLUME", "SELECT", "USE_SCHEMA", "WRITE_VOLUME"]
    gold_inspection_service   = ["CREATE_TABLE", "CREATE_VOLUME", "MODIFY", "READ_VOLUME", "SELECT", "USE_SCHEMA", "WRITE_VOLUME"]
  }
  plumbing_inspection = {
    bronze_inspection_service = ["READ_VOLUME", "SELECT", "USE_SCHEMA"]
    copper_inspection_service = ["READ_VOLUME", "SELECT", "USE_SCHEMA", "WRITE_VOLUME"]
    gold_inspection_service   = ["CREATE_MATERIALIZED_VIEW", "CREATE_TABLE", "CREATE_VOLUME", "MODIFY", "READ_VOLUME", "SELECT", "USE_SCHEMA", "WRITE_VOLUME"]
    silver_inspection_service = ["READ_VOLUME", "SELECT", "USE_SCHEMA"]
  }
  profittool = {}
  jde_shared = {
    bronze_jde    = ["MODIFY", "SELECT", "USE_SCHEMA"]
    bronze_shared = ["CREATE_TABLE", "CREATE_VOLUME", "MODIFY", "READ_VOLUME", "SELECT", "USE_SCHEMA", "WRITE_VOLUME"]
    silver_jde    = ["CREATE_TABLE", "MODIFY", "SELECT", "USE_SCHEMA"]
    silver_shared = ["CREATE_TABLE", "CREATE_VOLUME", "MODIFY", "READ_VOLUME", "SELECT", "USE_SCHEMA", "WRITE_VOLUME"]
  }
}

schemas = [
  "bronze_bidtracer",
  "bronze_jde",
  "bronze_profitool",
  "bronze_salesforce",
  "bronze_shared",
  "bronze_test",
  "copper_bidtracer",
  "copper_jde",
  "copper_profitool",
  "copper_salesforce",
  "gold_test",
  "silver_bidtracer",
  "silver_jde",
  "silver_profitool",
  "silver_salesforce",
  "silver_test",
]

managed_schemas = []

service_principals = {
  bidtracer = {
    bronze_bidtracer = ["CREATE_FUNCTION", "CREATE_MATERIALIZED_VIEW", "CREATE_TABLE", "CREATE_VOLUME", "MODIFY", "READ_SECRET", "READ_VOLUME", "SELECT", "USE_SCHEMA", "WRITE_VOLUME"]
    copper_bidtracer = ["CREATE_FUNCTION", "CREATE_MATERIALIZED_VIEW", "CREATE_TABLE", "CREATE_VOLUME", "MODIFY", "READ_SECRET", "READ_VOLUME", "SELECT", "USE_SCHEMA", "WRITE_VOLUME"]
    silver_bidtracer = ["CREATE_MATERIALIZED_VIEW", "CREATE_TABLE", "MODIFY", "READ_SECRET", "READ_VOLUME", "REFERENCE_SECRET", "REFRESH", "SELECT", "USE_SCHEMA", "WRITE_VOLUME"]
  }
  profitool = {
    bronze_profitool = ["CREATE_TABLE", "SELECT", "USE_SCHEMA"]
    copper_profitool = ["CREATE_TABLE", "CREATE_VOLUME", "MODIFY", "READ_VOLUME", "SELECT", "USE_SCHEMA", "WRITE_VOLUME"]
    silver_profitool = ["CREATE_TABLE", "SELECT", "USE_SCHEMA"]
  }
}

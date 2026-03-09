schemas = [
  "audit_common",
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

volumes = {
  copper_profitool_accountpayable_files       = { schema = "copper_profitool", type = "MANAGED" }
  copper_profitool_vendor_client_files        = { schema = "copper_profitool", type = "MANAGED" }
  copper_profitool_accountreceivable_files    = { schema = "copper_profitool", type = "MANAGED" }
  copper_inspection_service_raw_videos        = { schema = "copper_inspection_service", type = "MANAGED" }
  copper_inspection_service_training          = { schema = "copper_inspection_service", type = "MANAGED" }
  copper_inspection_service_raw_audio         = { schema = "copper_inspection_service", type = "MANAGED" }
  copper_bidtracer_dist                       = { schema = "copper_bidtracer", type = "MANAGED" }
  gold_inspection_service_reports             = { schema = "gold_inspection_service", type = "MANAGED" }
  silver_inspection_service_issue_screenshots = { schema = "silver_inspection_service", type = "MANAGED" }
  silver_inspection_service_extracted_frames  = { schema = "silver_inspection_service", type = "MANAGED" }
  bronze_shared_dist                          = { schema = "bronze_shared", type = "MANAGED" }
  bronze_test_landing = {
    schema       = "bronze_test"
    type         = "EXTERNAL"
    storage_path = "landing"
    comment      = "Landing volume for bronze layer data ingestion - dev"
  }
}

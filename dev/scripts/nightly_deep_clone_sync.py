# Nightly Deep Clone Sync
# Clones all MANAGED tables from dev_catalog -> dev_v2_catalog.
# DEEP CLONE is incremental — only new data files are copied on subsequent runs.

SOURCE_CATALOG = "dev_catalog"
TARGET_CATALOG = "dev_v2_catalog"

SKIP_SCHEMAS = {
    "information_schema",
    "bronze_boomi_process_reporting_old",
    "copper_boomi_process_repo",
}

SKIP_TABLE_PREFIXES = ("event_log_", "__materialization_")

rows = spark.sql(f"""
    SELECT table_schema, table_name
    FROM {SOURCE_CATALOG}.information_schema.tables
    WHERE table_type = 'MANAGED'
""").collect()

tables = [
    (r.table_schema, r.table_name)
    for r in rows
    if r.table_schema not in SKIP_SCHEMAS
    and not r.table_name.startswith(SKIP_TABLE_PREFIXES)
]

print(f"Found {len(tables)} managed tables to sync")

SKIPPABLE_ERRORS = ("DELTA_CLONE_UNSUPPORTED_SOURCE", "EXTERNAL_LOCATION_DOES_NOT_EXIST")

ok, skip, fail = 0, 0, 0
for schema, table in tables:
    src = f"{SOURCE_CATALOG}.{schema}.{table}"
    dst = f"{TARGET_CATALOG}.{schema}.{table}"
    try:
        spark.sql(f"CREATE OR REPLACE TABLE {dst} DEEP CLONE {src}")
        print(f"OK    {dst}")
        ok += 1
    except Exception as e:
        err = str(e)
        if any(code in err for code in SKIPPABLE_ERRORS):
            print(f"SKIP  {dst}: {err.split(']')[0]}]")
            skip += 1
        else:
            print(f"FAIL  {dst}: {e}")
            fail += 1

print(f"\nDone: {ok} succeeded, {skip} skipped, {fail} failed out of {ok + skip + fail} tables")

if fail > 0:
    raise Exception(f"{fail} tables failed to sync — check logs above")

from airflow import DAG
from datetime import datetime
from operators.extraction import ExtractionOperator
from connectors.cloud.source.snowflake_source_connector import SnowflakeSourceConnector
from connectors.base_connector import TargetConnector

# Simple Target for testing/logging
class LogTargetConnector(TargetConnector):
    def __enter__(self): return self
    def save(self, log, data, context):
        log.info(f"--- TEST RESULT RECEIVED ---")
        log.info(data)
        return data
    def __exit__(self, *args): pass

with DAG(
    dag_id='snowflake_query_test',
    start_date=datetime(2025, 1, 1),
    schedule=None,
    catchup=False,
    tags=['snowflake']
) as dag:

    # 1. Source: Snowflake Query
    snowflake_src = SnowflakeSourceConnector(
        conn_id='snowflake',
        sql="SELECT CURRENT_VERSION() AS VERSION;"
    )

    # 2. Target: Log it (or use GCSTargetConnector to save it)
    log_tgt = LogTargetConnector(conn_id="logger")

    # 3. Orchestrate
    test_connection = ExtractionOperator(
        task_id='query_snowflake_version',
        source=snowflake_src,
        targets=[log_tgt]
    )
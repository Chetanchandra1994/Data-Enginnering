from __future__ import annotations
from airflow import DAG
from datetime import datetime

from operators.extraction import ExtractionOperator
from connectors.cloud.source.gcs_source_connector import GCSSourceConnector
from connectors.base_connector import TargetConnector

# Simple Target for logging/verification (same as the Snowflake test)
class LogTargetConnector(TargetConnector):
    def __enter__(self): return self
    def save(self, log, data, context):
        log.info(f"--- GCS OBJECTS FOUND ---")
        for obj in data:
            log.info(f"- {obj['name']}")
        return data
    def __exit__(self, *args): pass

with DAG(
    dag_id='test_conn_gcs',
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=['gcs', 'authentication'],
) as dag:

    # 1. Define the Source (GCS)
    # This connector handles the storage.Client and ADC authentication logic
    gcs_source = GCSSourceConnector(
        conn_id='google_cloud_default', # Or your specific connection ID
        bucket_name='bigquery-255612',
        project_id='bigquery-255612'
    )

    # 2. Define the Target (Log)
    # Used here to print the list of discovered blobs to the Airflow logs
    log_target = LogTargetConnector(conn_id="logger")

    # 3. Use the Orchestrator (ExtractionOperator)
    # Manages the extraction lifecycle and verifies connectivity
    test_gcs_access = ExtractionOperator(
        task_id='test_gcs_access_task',
        source=gcs_source,
        targets=[log_target]
    )
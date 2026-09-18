from airflow import DAG
from datetime import datetime

from operators.extraction import ExtractionOperator
from connectors.jdbc.source.firebird_source_connector import FirebirdSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector

with DAG(
    dag_id='jdbc_firebird_example_dag',
    start_date=datetime(2023, 1, 1),
    schedule_interval=None,
    catchup=False,
    tags=['jdbc', 'firebird']
) as dag:

    # 1. Define the Source (MSSQL)
    # This encapsulates JDBC connection and Delta/XCom logic
    mssql_source = FirebirdSourceConnector(
        conn_id='kinetic',
        database='C:\PC4\PRIMECUT4.FDB',
        sql="SELECT CNTRLDEFAULT, CNTRLID, CONTEXT, DELETED, ID, NAME, SITEID FROM TBLCONTROLLER",
        query_mode='default'
    )

    # 2. Define the Target (GCS)
    # This handles project resolution and URI generation
    gcs_target = GCSTargetConnector(
        conn_id='gcs-bucket-project',
        table_name='TBLCONTROLLER',
        gcs_path='raw/local_test/kinetic'
    )

    # 3. Orchestrate with ExtractionOperator
    # Note: targets must be a list to support multi-target pipelines (Option C2)
    get_version_task = ExtractionOperator(
        task_id='select_version',
        source=mssql_source,
        targets=[gcs_target]
    )
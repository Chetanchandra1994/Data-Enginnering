from airflow import DAG
from datetime import datetime
from operators.extraction import ExtractionOperator
from connectors.jdbc.source.progress_source_connector import ProgressSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
from connectors.cloud.target.bigquery_target_connector import BigQueryTargetConnector
import pendulum

local_tz = pendulum.timezone("America/Toronto")

with DAG(
    dag_id='spm.fullload.salesman',
    start_date=datetime(2026, 3, 12, tzinfo=local_tz),
    schedule=None,
    catchup=False,
    tags=["jdbc", "spm", "progress", "gcs", "fullload", "bigquery"],
    max_active_runs=1
) as dag:

    # 1. Define the Source (Progress DB)
    progress_source = ProgressSourceConnector(
        conn_id='gdm',
        database='gdm',
        sql='SELECT ROWID AS "_rowid", CreatedBy AS "CreatedBy", CreatedDate AS "CreatedDate", ModifiedBy AS "ModifiedBy", ModifiedDate AS "ModifiedDate", people_id AS "people_id", salesman_uuid AS "salesman_uuid", "slsmn-code" AS "slsmn_code", "slsmn-name" AS "slsmn_name" FROM PUB."salesman"',
        query_mode='default'
    )

    # 2. Define the Target (GCS)
    gcs_target = GCSTargetConnector(
        conn_id='gcs-bucket-project',
        table_name='salesman',
        gcs_path='raw/SPM_GDM'
    )

    bq_target = BigQueryTargetConnector(
        conn_id='bigquery-edl-landing',
        bq_landing_table='SPM_GDM.salesman',
        bq_merge_procedure='SPM_GDM.sp_Merge_salesman'
    )

    # 3. Use the Operator to run the task
    extract_data = ExtractionOperator(
        task_id='extract_salesman',
        source=progress_source,
        targets=[gcs_target, bq_target]
    )
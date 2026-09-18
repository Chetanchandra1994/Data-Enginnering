from airflow import DAG
from datetime import datetime
from operators.extraction import ExtractionOperator
from connectors.jdbc.source.progress_source_connector import ProgressSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
from connectors.cloud.target.bigquery_target_connector import BigQueryTargetConnector
import pendulum

local_tz = pendulum.timezone("America/Toronto")

with DAG(
    dag_id='spm.fullload.working_shift',
    start_date=datetime(2026, 3, 12, tzinfo=local_tz),
    schedule=None,
    catchup=False,
    tags=["jdbc", "spm", "progress", "gcs", "fullload", "bigquery"],
    max_active_runs=1
) as dag:

    # 1. Define the Source (Progress DB)
    progress_source = ProgressSourceConnector(
        conn_id='acct',
        database='acct',
        sql='SELECT ROWID as "_rowid", "entity-code" as "entity_code", working_shift_code, working_shift_name_id, active, working_shift_uuid, CreatedDate, payroll_working_shift_uuid, ModifiedDate, ModifiedBy, CreatedBy FROM PUB.working_shift',
        query_mode='default'
    )

    # 2. Define the Target (GCS)
    gcs_target = GCSTargetConnector(
        conn_id='gcs-bucket-project',
        table_name='working_shift',
        gcs_path='raw/SPM_CA'
    )

    bq_target = BigQueryTargetConnector(
        conn_id='bigquery-edl-landing',
        bq_landing_table='SPM_CA.working_shift',
        bq_merge_procedure='SPM_CA.sp_Merge_working_shift'
    )

    # 3. Use the Operator to run the task
    extract_data = ExtractionOperator(
        task_id='extract_working_shift',
        source=progress_source,
        targets=[gcs_target, bq_target]
    )
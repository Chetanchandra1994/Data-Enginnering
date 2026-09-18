from airflow import DAG
from datetime import datetime
from operators.extraction import ExtractionOperator
from connectors.jdbc.source.progress_source_connector import ProgressSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
from connectors.cloud.target.bigquery_target_connector import BigQueryTargetConnector
import pendulum

local_tz = pendulum.timezone("America/Toronto")

with DAG(
    dag_id='spm.fullload.working_shift_detail',
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
        sql='SELECT ROWID as "_rowid", working_shift_type, "shop-no" as "shop_no", machn_no, week_day, shift_date, shift_start_time, shift_end_time, break1_start_time, break1_end_time, break2_start_time, break2_end_time, break3_start_time, break3_end_time, total_workers_number, "entity-code" as "entity_code", working_shift_uuid, working_shift_detail_uuid, active_from_date, active_to_date, foreman_id, break1_included_std_time, break2_included_std_time, break3_included_std_time, assembly_workers_number, welding_workers_number, nonworking_time, preparation_workers_number, painting_workers_number, shift_to_update, ModifiedBy, CreatedDate, CreatedBy, ModifiedDate FROM PUB.working_shift_detail',
        query_mode='default'
    )

    # 2. Define the Targets
    gcs_target = GCSTargetConnector(
        conn_id='gcs-bucket-project',
        table_name='working_shift_detail',
        gcs_path='raw/SPM_CA'
    )

    bq_target = BigQueryTargetConnector(
        conn_id='bigquery-edl-landing',
        bq_landing_table='SPM_CA.working_shift_detail',
        bq_merge_procedure='SPM_CA.sp_Merge_working_shift_detail'
    )

    # 3. Use the Operator to run the task
    extract_data = ExtractionOperator(
        task_id='extract_working_shift_detail',
        source=progress_source,
        targets=[gcs_target, bq_target]
    )
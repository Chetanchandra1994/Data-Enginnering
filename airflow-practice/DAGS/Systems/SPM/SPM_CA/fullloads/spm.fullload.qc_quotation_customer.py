from airflow import DAG
from datetime import datetime
from operators.extraction import ExtractionOperator
from connectors.jdbc.source.progress_source_connector import ProgressSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
from connectors.cloud.target.bigquery_target_connector import BigQueryTargetConnector
import pendulum

local_tz = pendulum.timezone("America/Toronto")

with DAG(
    dag_id='spm.fullload.qc_quotation_customer',
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
        sql='SELECT ROWID AS "_rowid","office_code" AS "office_code", "job-no" AS "job_no", "rank" AS "rank", "select_date" AS "select_date", "dummy" AS "dummy", "memo" AS "memo", "warning_text" AS "warning_text", "delivr_date" AS "delivr_date", "last_update_date" AS "last_update_date", "follow_up" AS "follow_up", "customer_uuid" AS "customer_uuid", "erector_privilege_proposed_date" AS "erector_privilege_proposed_date", "ModifiedBy" AS "ModifiedBy", "CreatedBy" AS "CreatedBy", "CreatedDate" AS "CreatedDate", "ModifiedDate" AS "ModifiedDate", "qc_quotation_customer_uuid" AS "qc_quotation_customer_uuid" FROM PUB."qc_quotation_customer"',
        query_mode='default'
    )

    # 2. Define the Targets
    gcs_target = GCSTargetConnector(
        conn_id='gcs-bucket-project',
        table_name='qc_quotation_customer',
        gcs_path='raw/SPM_CA'
    )

    bq_target = BigQueryTargetConnector(
        conn_id='bigquery-edl-landing',
        bq_landing_table='SPM_CA.qc_quotation_customer',
        bq_merge_procedure='SPM_CA.sp_Merge_qc_quotation_customer'
    )

    # 3. Use the Operator to run the task
    extract_data = ExtractionOperator(
        task_id='extract_qc_quotation_customer',
        source=progress_source,
        targets=[gcs_target, bq_target]
    )
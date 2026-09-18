from airflow import DAG
from datetime import datetime
from operators.extraction import ExtractionOperator
from connectors.jdbc.source.progress_source_connector import ProgressSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
from connectors.cloud.target.bigquery_target_connector import BigQueryTargetConnector
import pendulum

local_tz = pendulum.timezone("America/Toronto")

with DAG(
    dag_id='spm.fullload.proj_seq_lp_bigquery',
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
        sql='SELECT ROWID "_rowid",CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, "entity-code", estimated_amount, estimated_plant_fabrication_time, estimated_uom, "no-produit", "no-projet", pces[1] AS "pces_1", pces[2] AS "pces_2", pces[3] AS "pces_3", print_information_on_item, produced_amount, produced_uom, "proj-seq-lp_uuid", requisitions_received_date, "seq-no", shipped_amount, shipped_uom, tmps[1] AS "tmps_1", tmps[2] AS "tmps_2", weight[1] AS "weight_1", weight[2] AS "weight_2", weight[3] AS "weight_3" FROM PUB."proj-seq-lp"',
        query_mode='default'
    )

    # 2. Define the Targets
    gcs_target = GCSTargetConnector(
        conn_id='gcs-bucket-project',
        table_name='proj_seq_lp',
        gcs_path='raw/BigQuery_Fullloads/SPM_CA'
    )

    bq_target = BigQueryTargetConnector(
        conn_id='bigquery-edl-landing',
        bq_landing_table='SPM_CA.proj_seq_lp',
        bq_merge_procedure='SPM_CA.sp_Merge_proj_seq_lp'
    )

    # 3. Use the Operator to run the task
    extract_data = ExtractionOperator(
        task_id='extract_proj_seq_lp',
        source=progress_source,
        targets=[gcs_target, bq_target]
    )
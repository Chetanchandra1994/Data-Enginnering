from airflow import DAG
from datetime import datetime
from operators.extraction import ExtractionOperator
from connectors.jdbc.source.progress_source_connector import ProgressSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
from connectors.cloud.target.bigquery_target_connector import BigQueryTargetConnector
import pendulum

local_tz = pendulum.timezone("America/Toronto")

with DAG(
    dag_id='spm.fullload.warehouse',
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
        sql='SELECT ROWID AS "_rowid","whs-code" AS "whs_code", "description" AS "description", "name" AS "name", "address"[1] AS "address_1", "address"[2] AS "address_2", "city" AS "city", "st" AS "st", "zip-code" AS "zip_code", "country" AS "country", "telephone" AS "telephone", "telex-twx" AS "telex_twx", "tax-code" AS "tax_code", "s_contrc" AS "s_contrc", "mult_inv" AS "mult_inv", "ext_whs" AS "ext_whs", "track-heat-no" AS "track_heat_no", "pct-perte" AS "pct_perte", "item-no" AS "item_no", "ind-reserve" AS "ind_reserve", "ctrl-inv-job" AS "ctrl_inv_job", "used" AS "used", "receipt-code" AS "receipt_code", "epix_maintn" AS "epix_maintn", "epix_used_whs" AS "epix_used_whs", "track-b-location" AS "track_b_location", "master_entity" AS "master_entity", "project_no" AS "project_no", "deck_type" AS "deck_type", "bar_code_follow" AS "bar_code_follow", "vendor_id" AS "vendor_id", "vendor_name" AS "vendor_name", "inv_conciliation_usages_formula" AS "inv_conciliation_usages_formula", "OptimizationManageHeatNo" AS "OptimizationManageHeatNo", "ManageSurfaceItemInWeight" AS "ManageSurfaceItemInWeight", "LinkedABMProjectNumber" AS "LinkedABMProjectNumber", "IgnoreFinancialRawMatCost" AS "IgnoreFinancialRawMatCost", "CreatedBy" AS "CreatedBy", "CreatedDate" AS "CreatedDate", "ModifiedDate" AS "ModifiedDate", "ModifiedBy" AS "ModifiedBy" FROM PUB."warehouse"',
        query_mode='default'
    )

    # 2. Define the Target (GCS)
    gcs_target = GCSTargetConnector(
        conn_id='gcs-bucket-project',
        table_name='warehouse',
        gcs_path='raw/SPM_CA'
    )

    bq_target = BigQueryTargetConnector(
        conn_id='bigquery-edl-landing',
        bq_landing_table='SPM_CA.warehouse',
        bq_merge_procedure='SPM_CA.sp_Merge_warehouse'
    )

    # 3. Use the Operator to run the task
    extract_data = ExtractionOperator(
        task_id='extract_warehouse',
        source=progress_source,
        targets=[gcs_target, bq_target]
    )
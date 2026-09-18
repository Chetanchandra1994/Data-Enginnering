from airflow import DAG
from datetime import datetime
from operators.extraction import ExtractionOperator
from connectors.jdbc.source.progress_source_connector import ProgressSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
import pendulum

local_tz = pendulum.timezone("America/Toronto")

with DAG(
    dag_id='spm.fullload.ess_line',
    start_date=datetime(2026, 3, 12, tzinfo=local_tz),
    schedule=None,
    catchup=False,
    tags=["jdbc", "spm", "progress", "gcs", "fullload"],
    max_active_runs=1
) as dag:

    # 1. Define the Source (Progress DB)
    progress_source = ProgressSourceConnector(
        conn_id='acct',
        database='acct',
        sql='SELECT ROWID AS "_rowid","entity-code" AS "entity_code", "line-no" AS "line_no", "section-no" AS "section_no", "drawing_type" AS "drawing_type", "action-col"[3] AS "action_col_3", "action-col"[4] AS "action_col_4", "action-col"[2] AS "action_col_2", "action-col"[1] AS "action_col_1", "unit-col-2"[1] AS "unit_col_2_1", "unit-col-2"[4] AS "unit_col_2_4", "unit-col-2"[3] AS "unit_col_2_3", "unit-col-2"[2] AS "unit_col_2_2", "col-value-2"[3] AS "col_value_2_3", "col-value-2"[1] AS "col_value_2_1", "col-value-2"[2] AS "col_value_2_2", "col-value-2"[4] AS "col_value_2_4", "no-produit" AS "no_produit", "taxe-prov" AS "taxe_prov", "taxe-fed" AS "taxe_fed", "catg-mat" AS "catg_mat", "line-type" AS "line_type", "col-value"[3] AS "col_value_3", "col-value"[1] AS "col_value_1", "col-value"[2] AS "col_value_2", "col-value"[4] AS "col_value_4", "col-value"[5] AS "col_value_5", "unit-col"[5] AS "unit_col_5", "unit-col"[1] AS "unit_col_1", "unit-col"[3] AS "unit_col_3", "unit-col"[4] AS "unit_col_4", "unit-col"[2] AS "unit_col_2", "prn-total"[3] AS "prn_total_3", "prn-total"[2] AS "prn_total_2", "prn-total"[4] AS "prn_total_4", "prn-total"[1] AS "prn_total_1", "ind-s-cont" AS "ind_s_cont", "dash"[1] AS "dash_1", "dash"[2] AS "dash_2", "statut" AS "statut", "gl-depense" AS "gl_depense", "desc-line"[2] AS "desc_line_2", "desc-line"[1] AS "desc_line_1", "gl-provision" AS "gl_provision", "expense-rate" AS "expense_rate", "gl-income" AS "gl_income", "gl-imputation" AS "gl_imputation", "group-no" AS "group_no", "task_number" AS "task_number", "inv_type" AS "inv_type", "pounds_input" AS "pounds_input", "area_input" AS "area_input", "is_active" AS "is_active", "dw_task" AS "dw_task", "external" AS "external", "erector_privilege" AS "erector_privilege", "CreatedDate" AS "CreatedDate", "ModifiedDate" AS "ModifiedDate", "CreatedBy" AS "CreatedBy", "ModifiedBy" AS "ModifiedBy", "ess-line_uuid" AS "ess_line_uuid" FROM PUB."ess-line"',
        query_mode='default'
    )

    # 2. Define the Target (GCS)
    gcs_target = GCSTargetConnector(
        conn_id='gcs-bucket-project',
        table_name='ess_line',
        gcs_path='raw/SPM_CA'
    )

    # 3. Use the Operator to run the task
    extract_data = ExtractionOperator(
        task_id='extract_ess_line',
        source=progress_source,
        targets=[gcs_target]
    )
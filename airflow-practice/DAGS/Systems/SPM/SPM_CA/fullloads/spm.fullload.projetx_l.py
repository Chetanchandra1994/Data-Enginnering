from airflow import DAG
from datetime import datetime
from operators.extraction import ExtractionOperator
from connectors.jdbc.source.progress_source_connector import ProgressSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
import pendulum

local_tz = pendulum.timezone("America/Toronto")

with DAG(
    dag_id='spm.fullload.projetx_l',
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
        sql='SELECT ROWID AS "_rowid","entity-code" AS "entity_code", "no-estime" AS "no_estime", "no-produit" AS "no_produit", "type-projet" AS "type_projet", "slsmn-code" AS "slsmn_code", "type-fact" AS "type_fact", "qte-budgete" AS "qte_budgete", "qte-estime" AS "qte_estime", "surface" AS "surface", "nbr-poutr" AS "nbr_poutr", "tmps-std-ei"[4] AS "tmps_std_ei_4", "tmps-std-ei"[3] AS "tmps_std_ei_3", "tmps-std-ei"[5] AS "tmps_std_ei_5", "tmps-std-ei"[6] AS "tmps_std_ei_6", "tmps-std-ei"[2] AS "tmps_std_ei_2", "tmps-std-ei"[1] AS "tmps_std_ei_1", "mnt-est-info" AS "mnt_est_info", "net-sale" AS "net_sale", "pst-quoted" AS "pst_quoted", "net-u-price" AS "net_u_price", "ind-f-conn" AS "ind_f_conn", "waste-out" AS "waste_out", "inv-cat" AS "inv_cat", "seq-no" AS "seq_no", "tmps-std-e"[6] AS "tmps_std_e_6", "tmps-std-e"[7] AS "tmps_std_e_7", "tmps-std-e"[5] AS "tmps_std_e_5", "tmps-std-e"[4] AS "tmps_std_e_4", "tmps-std-e"[3] AS "tmps_std_e_3", "tmps-std-e"[2] AS "tmps_std_e_2", "tmps-std-e"[1] AS "tmps_std_e_1", "complex_code" AS "complex_code", "estim_det" AS "estim_det", "estim_des" AS "estim_des", "dsg_cost"[2] AS "dsg_cost_2", "dsg_cost"[3] AS "dsg_cost_3", "dsg_cost"[1] AS "dsg_cost_1", "dsg_cost"[4] AS "dsg_cost_4", "dsg_cost"[5] AS "dsg_cost_5", "dsg_cost"[6] AS "dsg_cost_6", "office_code" AS "office_code", "branch_office_code" AS "branch_office_code", "nbr_escort" AS "nbr_escort", "cost" AS "cost", "vendor_id" AS "vendor_id", "vendor_name" AS "vendor_name", "revenue_quantity_type_uuid" AS "revenue_quantity_type_uuid", "CreatedDate" AS "CreatedDate", "ModifiedDate" AS "ModifiedDate", "CreatedBy" AS "CreatedBy", "ModifiedBy" AS "ModifiedBy", "projetx-l_uuid" AS "projetx_l_uuid" FROM PUB."projetx-l"',
        query_mode='default'
    )

    # 2. Define the Target (GCS)
    gcs_target = GCSTargetConnector(
        conn_id='gcs-bucket-project',
        table_name='projetx_l',
        gcs_path='raw/SPM_CA'
    )

    # 3. Use the Operator to run the task
    extract_data = ExtractionOperator(
        task_id='extract_projetx_l',
        source=progress_source,
        targets=[gcs_target]
    )
from airflow import DAG
from datetime import datetime
from operators.extraction import ExtractionOperator
from connectors.jdbc.source.progress_source_connector import ProgressSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
import pendulum

local_tz = pendulum.timezone("America/Toronto")

with DAG(
    dag_id='spm.fullload.marques',
    start_date=datetime(2026, 3, 25, tzinfo=local_tz), 
    schedule=None,
    catchup=False,
    tags=["jdbc", "spm", "progress", "gcs", "fullload"],
    max_active_runs=1
) as dag:

    progress_source = ProgressSourceConnector(
        conn_id='acct',
        database='acct',
        sql='SELECT ROWID AS "_rowid", "entity-code" AS "entity_code", "no-poids" AS "no_poids", "marque" AS "marque", "d-prod" AS "d_prod", "r-marque" AS "r_marque", "hauteur" AS "hauteur", "remarque" AS "remarque", "m-longueur" AS "m_longueur", "m-poids" AS "m_poids", "m-cout-mat" AS "m_cout_mat", "m-long-ppf" AS "m_long_ppf", "m-tmps-ind"[5] AS "m_tmps_ind_5", "m-tmps-ind"[4] AS "m_tmps_ind_4", "m-tmps-ind"[3] AS "m_tmps_ind_3", "m-tmps-ind"[2] AS "m_tmps_ind_2", "m-tmps-ind"[1] AS "m_tmps_ind_1", "m-seq" AS "m_seq", "cat-struct" AS "cat_struct", "numero-ident" AS "numero_ident", "conn-weight" AS "conn_weight", "m-qtes"[7] AS "m_qtes_7", "m-qtes"[6] AS "m_qtes_6", "m-qtes"[2] AS "m_qtes_2", "m-qtes"[1] AS "m_qtes_1", "m-qtes"[4] AS "m_qtes_4", "m-qtes"[3] AS "m_qtes_3", "m-qtes"[5] AS "m_qtes_5", "orient" AS "orient", "mli" AS "mli", "reference" AS "reference", "furn_cost" AS "furn_cost", "f-mark-upd" AS "f_mark_upd", "orientation" AS "orientation", "m-tmps-std"[3] AS "m_tmps_std_3", "m-tmps-std"[4] AS "m_tmps_std_4", "m-tmps-std"[1] AS "m_tmps_std_1", "m-tmps-std"[5] AS "m_tmps_std_5", "m-tmps-std"[2] AS "m_tmps_std_2", "m-tmps-std"[6] AS "m_tmps_std_6", "us_tmps_std"[5] AS "us_tmps_std_5", "us_tmps_std"[4] AS "us_tmps_std_4", "us_tmps_std"[3] AS "us_tmps_std_3", "us_tmps_std"[2] AS "us_tmps_std_2", "us_tmps_std"[1] AS "us_tmps_std_1", "us_tmps_std"[6] AS "us_tmps_std_6", "m-long-metr" AS "m_long_metr", "dummy" AS "dummy", "prod_startup_est_time2" AS "prod_startup_est_time2", "prod_startup_est_time3" AS "prod_startup_est_time3", "prod_startup_est_time4" AS "prod_startup_est_time4", "prod_startup_est_time5" AS "prod_startup_est_time5", "prod_startup_est_time6" AS "prod_startup_est_time6", "prod_startup_est_time1" AS "prod_startup_est_time1", "deck_accessory_dimension_b" AS "deck_accessory_dimension_b", "deck_accessory_dimension_c" AS "deck_accessory_dimension_c", "deck_accessory_angle" AS "deck_accessory_angle", "deck_accessory_gage" AS "deck_accessory_gage", "deck_accessory_dimension_a" AS "deck_accessory_dimension_a", "cold_formed_mark_uuid" AS "cold_formed_mark_uuid", "finished_quantity_transferred" AS "finished_quantity_transferred", "detail_report_modified" AS "detail_report_modified", "prod_startup_est_time5_initial" AS "prod_startup_est_time5_initial", "prod_startup_est_time6_initial" AS "prod_startup_est_time6_initial", "prod_startup_est_time1_initial" AS "prod_startup_est_time1_initial", "prod_startup_est_time2_initial" AS "prod_startup_est_time2_initial", "prod_startup_est_time3_initial" AS "prod_startup_est_time3_initial", "prod_startup_est_time4_initial" AS "prod_startup_est_time4_initial", "bridge_accessory_mark_uuid" AS "bridge_accessory_mark_uuid", "pre_assembled_with" AS "pre_assembled_with", "marques_uuid" AS "marques_uuid", "BottomChordShapeType" AS "BottomChordShapeType", "TopChordShapeType" AS "TopChordShapeType", "CutLeg" AS "CutLeg", "HasMemberReinforcement" AS "HasMemberReinforcement", "HasTCX" AS "HasTCX", "CutLegLength" AS "CutLegLength", "QuantityShoeTagPrinted" AS "QuantityShoeTagPrinted", "CreatedDate" AS "CreatedDate", "CreatedBy" AS "CreatedBy", "ModifiedDate" AS "ModifiedDate", "ModifiedBy" AS "ModifiedBy", "SJAStatus" AS "SJAStatus", "SJAEstimatedTime" AS "SJAEstimatedTime", "SJAEstimatedTimeInitial" AS "SJAEstimatedTimeInitial", "prod_startup_est_time2_old" AS "prod_startup_est_time2_old", "prod_startup_est_time2_init_old" AS "prod_startup_est_time2_init_old" FROM PUB."marques"',
        limit=10000
    )

    gcs_target = GCSTargetConnector(
        conn_id='gcs-bucket-project',
        table_name='marques',
        gcs_path='raw/SPM_CA'
    )

    extract_data = ExtractionOperator(
        task_id='extract_marques',
        source=progress_source,
        targets=[gcs_target]
    )
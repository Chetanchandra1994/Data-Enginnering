# this is a comment    
import pendulum
from airflow.decorators import dag, task
from operators.extraction import ExtractionOperator
from connectors.jdbc.source.oracle_source_connector import OracleSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
from connectors.cloud.target.bigquery_target_connector import BigQueryTargetConnector
from Systems.EBS.configurations.ebs_config import GLOBAL_CONFIG, TABLES_CONFIG_5_AM, TABLES_CONFIG_6_AM, TABLES_CONFIG_8_AM, TABLES_CONFIG_12_PM , TABLES_CONFIG_10_AM
from datetime import datetime

local_tz = pendulum.timezone("America/Toronto")

def _create_dag(q_conf: dict, schedule: str):
    """Dynamically creates a DAG for a single Oracle table configuration."""
    table_name = q_conf.get("table_name")
    dag_id = f"ebs.stream.{table_name}".lower()
    
    tags = ["oracle", "stream", "ebs", "gcs", "jdbc"]
    if q_conf.get("upload_to_bq"):
        tags.append("bigquery")

    @dag(
        dag_id=dag_id,
        start_date=datetime(2025, 1, 1, tzinfo=local_tz),
        schedule=schedule,
        catchup=False,
        tags=tags,
        max_active_runs=1
    )
    def generated_dag():
        @task
        def run_extraction(**context):
            """Instantiates objects and executes operator logic at runtime."""

            # 1. Instantiate the Source
            source_obj = OracleSourceConnector(
                conn_id=GLOBAL_CONFIG.get("oracle_conn_id"),
                sql=q_conf.get("sql"),
                query_mode=q_conf.get("query_mode"),
                delta_column=q_conf.get("delta_column"),
                xcom_key=f'{dag_id}_delta', # Use dag_id for a unique xcom key
                limit=q_conf.get("limit")
            )

            # 2. Instantiate the Targets with hierarchical connection resolution
            gcs_conn = q_conf.get("bucket_conn_id", GLOBAL_CONFIG.get("bucket_conn_id", "google_cloud_default"))
            bq_conn = q_conf.get("bq_conn_id", GLOBAL_CONFIG.get("bq_conn_id", "google_cloud_default"))

            targets = [
                GCSTargetConnector(
                    conn_id=gcs_conn,
                    gcs_path=q_conf.get("gcs_path"),
                    table_name=table_name
                )
            ]

            if q_conf.get("upload_to_bq"):
                targets.append(
                    BigQueryTargetConnector(
                        conn_id=bq_conn,
                        bq_landing_table=q_conf.get("bq_landing_table"),
                        bq_merge_procedure=q_conf.get("bq_merge_procedure")
                    )
                )

            # 3. Instantiate and execute the ExtractionOperator
            op = ExtractionOperator(
                task_id=f"extract_{table_name}",
                source=source_obj,
                targets=targets
            )
            return op.execute(context=context)

        # Execution Flow
        run_extraction()

    return generated_dag()

# Loop through the configuration lists and create a DAG for each active table
for config in TABLES_CONFIG_5_AM:
    _create_dag(config, schedule="0 5 * * *")

for config in TABLES_CONFIG_6_AM:
    _create_dag(config, schedule="0 6 * * *")

for config in TABLES_CONFIG_8_AM:
    _create_dag(config, schedule="0 8 * * *")

for config in TABLES_CONFIG_10_AM:
    _create_dag(config, schedule="0 10 * * *")

for config in TABLES_CONFIG_12_PM:
    _create_dag(config, schedule="0 12 * * *")
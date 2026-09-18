import pendulum
from airflow.decorators import dag, task
from operators.extraction import ExtractionOperator
from connectors.api.source.rabbitmq_source_connector import RabbitMQSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
from connectors.cloud.target.bigquery_target_connector import BigQueryTargetConnector
import Systems.RabbitMQ.SPM.configurations.rabbitmq_config as rabbitmq_config

def _create_queue_dag(q_conf: dict):
    """Dynamically creates a DAG for a single RabbitMQ queue configuration."""
    queue_name = q_conf.get("queue_name")
    table_name = q_conf.get("table_name")
    dag_id = f"spm.stream.{table_name}".replace("-", "_").lower()

    tags = ["rabbitmq", "stream", "spm", "progress", "gcs"]
    if q_conf.get("upload_to_bq"):
        tags.append("bigquery")

    @dag(
        dag_id=dag_id,
        start_date=pendulum.datetime(2025, 1, 1, tz="UTC"),
        schedule=None,  # This DAG will be triggered by the master poller
        catchup=False,
        tags=tags,
        max_active_runs=1,
        default_args={"executor": "CeleryExecutor"}
    )
    def generated_queue_dag():
        @task
        def run_extraction(**context):
            """Instantiates objects and executes operator logic at runtime."""
            # 1. Instantiate the Source
            source_obj = RabbitMQSourceConnector(
                conn_id=rabbitmq_config.GLOBAL_CONFIG.get("rabbitmq_conn_id"),
                queue_name=queue_name,
                batch_size=q_conf.get("batch_size", 500),
                expand_map=q_conf.get("expand_map")
            )

            # 2. Instantiate the Targets with hierarchical connection resolution
            gcs_conn = q_conf.get("bucket_conn_id", rabbitmq_config.GLOBAL_CONFIG.get("bucket_conn_id", "google_cloud_default"))
            bq_conn = q_conf.get("bq_conn_id", rabbitmq_config.GLOBAL_CONFIG.get("bq_conn_id", "google_cloud_default"))

            targets = [
                GCSTargetConnector(
                    conn_id=gcs_conn,
                    gcs_path=q_conf.get("gcs_path"),
                    table_name=q_conf.get("table_name")
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
                task_id=f"extract_and_load_{queue_name.replace('.', '_')}",
                source=source_obj,
                targets=targets
            )
            data = op.execute(context=context)
            context['ti'].log.info(f"Data from queue {queue_name}: {data}")
            return data

        # Execution Flow
        run_extraction()

    return generated_queue_dag()

# Dynamically discover and combine all QUEUES_CONFIG lists from the config module
all_queue_configs = []
for attr_name in dir(rabbitmq_config):
    if attr_name.startswith("QUEUES_CONFIG_") and isinstance(getattr(rabbitmq_config, attr_name), list):
        all_queue_configs.extend(getattr(rabbitmq_config, attr_name))


# Loop through the configuration list and create a DAG for each active queue
for config in all_queue_configs:
    _create_queue_dag(config)
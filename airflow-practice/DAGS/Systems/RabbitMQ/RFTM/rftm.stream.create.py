from airflow import DAG
from datetime import datetime

from operators.extraction import ExtractionOperator
from connectors.api.source.rabbitmq_source_connector import RabbitMQSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector

with DAG(
    dag_id='rftm.stream.create',
    schedule_interval="*/5 * * * *",
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=['rabbitmq', 'stream', 'rftm', 'gcs'],
    max_active_runs=1,
    default_args={"executor": "CeleryExecutor"}
) as dag:    

    # 1. Define the Source (RabbitMQ)
    # This connector handles message consumption and sanitization.
    rabbit_source = RabbitMQSourceConnector(
        conn_id='amqp',
        queue_name='RFTM.RollFormerProductionTransactions.Create',
        batch_size=500
    )

    # 2. Define the Target (GCS)
    # This connector handles project/bucket resolution and uploads.
    gcs_target = GCSTargetConnector(
        conn_id='gcs-bucket-project',
        table_name='production_transactions',
        gcs_path='raw/Roll_Former'
    )

    # 3. Use the Orchestrator (ExtractionOperator)
    # It manages the lifecycle and the handoff between source and target.
    consume_and_upload = ExtractionOperator(
        task_id='extract_and_load_rftm_create',
        source=rabbit_source,
        targets=[gcs_target]
    )
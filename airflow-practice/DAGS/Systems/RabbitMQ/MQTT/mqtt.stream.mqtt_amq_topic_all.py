from airflow import DAG
from datetime import datetime

from operators.extraction import ExtractionOperator
from connectors.api.source.rabbitmq_source_connector import RabbitMQSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector

with DAG(
    dag_id='mqtt.stream.mqtt_amq_topic_all',
    description='Simplified DAG using polymorphic extraction architecture',
    schedule_interval="*/5 * * * *",
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=['rabbitmq', 'stream', 'mqtt', 'gcs'],
    max_active_runs=1,
    default_args={"executor": "CeleryExecutor"}
) as dag:    

    # 1. Define the Source (RabbitMQ)
    # This connector handles message consumption and sanitization.
    rabbit_source = RabbitMQSourceConnector(
        conn_id='cloudamqp',
        queue_name='mqtt-amq-topic-all-snowflake',
        batch_size=500
    )

    # 2. Define the Target (GCS)
    # This connector handles project/bucket resolution and uploads.
    gcs_target = GCSTargetConnector(
        conn_id='gcs-bucket-project',
        table_name='amq_topic',
        gcs_path='raw/mqtt'
    )

    # 3. Use the Orchestrator (ExtractionOperator)
    # It manages the lifecycle and the handoff between source and target.
    consume_and_upload = ExtractionOperator(
        task_id='consume_and_upload',
        source=rabbit_source,
        targets=[gcs_target]
    )
from airflow import DAG
from datetime import datetime, timedelta

from operators.extraction import ExtractionOperator
from connectors.api.source.rabbitmq_source_connector import RabbitMQSourceConnector
from connectors.api.target.rabbitmq_target_connector import RabbitMQTargetConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
from connectors.base_connector import SourceConnector

# 1. Mock Source for Dummy Data
# This allows us to use the ExtractionOperator to publish our generated data.
class DummySalesSource(SourceConnector):
    def __init__(self, num_messages=500):
        super().__init__(conn_id="mock")
        self.num_messages = num_messages
        self._has_run = False

    def __enter__(self): return self

    def extract(self, context):
        if self._has_run: return False
        
        self.extracted_data = self._generate_messages() 
        self._has_run = True
        return True

# 2. DAG Definition
with DAG(
    dag_id='rabbit_publish_to_queue_consume_to_gcs',
    description='Performance testing using polymorphic connectors',
    schedule_interval='*/5 * * * *',
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=['rabbitmq', 'salesman'],
) as dag:

    # TASK 1: Publish generated data to RabbitMQ
    publish_task = ExtractionOperator(
        task_id='publish_messages_task',
        source=DummySalesSource(500),
        targets=[
            RabbitMQTargetConnector(
                conn_id='amqp',
                queue_name='spm.salesman.airflow',
                message_properties={'delivery_mode': 2}
            )
        ]
    )

    # TASK 2: Consume from RabbitMQ and upload to GCS
    consume_and_upload = ExtractionOperator(
        task_id='consume_and_upload',
        source=RabbitMQSourceConnector(
            conn_id='amqp',
            queue_name='spm.salesman.airflow',
            batch_size=500
        ),
        targets=[
            GCSTargetConnector(
                conn_id='gcs-bucket-project',
                table_name='salesman',
                gcs_path='raw/local_test'
            )
        ]
    )

    publish_task >> consume_and_upload
from airflow import DAG
from datetime import datetime, timedelta
from airflow.operators.dagrun_operator import TriggerDagRunOperator
from connectors.api.source.apigee_custom.apigee_production_planning_source_connector import ApigeeProductionPlanningConnector
from connectors.cloud.target.bigquery_target_connector import BigQueryTargetConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector 
from connectors.api.source.rabbitmq_source_connector import RabbitMQSourceConnector
from operators.listen_operators.rabbitmq_listen_operator import RabbitMQListenOperator
from airflow.models import Variable

default_args = {
    "executor": "CeleryExecutor"
}

with DAG(
    dag_id='manweb.stream.production_line_punch_in',
    default_args = default_args,
    start_date=datetime(2024, 1, 1),
    schedule_interval="*/5 * * * *",
    catchup=False,
    max_active_runs=1,
    tags=['rabbitmq', 'stream', 'manweb', 'gcs', 'bigquery']
) as dag:
    
    target_date_template = "{{ (macros.datetime.now() + macros.timedelta(days=1)).strftime('%Y-%m-%d') }}"

    listen_and_process = RabbitMQListenOperator(
        task_id='listen_and_process',
        trigger_dag_on_success=True,
        message_source=RabbitMQSourceConnector(
            conn_id='amqp',
            queue_name='Manuf.Fab_Prod.Man_Time_Att.PunchIn.AirflowListen',
            batch_size=1
        ),
        source=ApigeeProductionPlanningConnector(
            conn_id='apigee',
            # We use the macro for target_date and params for the MQ data
            endpoint=(
                f"{Variable.get("MANWEBAPP_URL_PATH")}"
                f"/Entity/{{{{ params.mq_data.EntityCode }}}}/"
                f"ProductionLine/{{{{ params.mq_data.ShopNo }}}}/"
                f"FormattedDate/{target_date_template}/"
                f"WorkingShiftDetailUuid/{{{{ params.mq_data.WorkingShiftDetailUuid }}}}"
            ),
            method='GET'
        ),
        targets=[
            GCSTargetConnector(
                conn_id='gcs-bucket-project',
                gcs_path='raw/ProductionPlanningByLineAPI',
                table_name='ProductionLinePunchIn'
            ),
            BigQueryTargetConnector(
                conn_id='bigquery-edl-landing',
                bq_landing_table='ProductionPlanningByLineAPI.ProductionLinePunchIn',
                bq_merge_procedure='ProductionPlanningByLineAPI.sp_Merge_ProductionLinePunchIn'
            )
        ]
    )
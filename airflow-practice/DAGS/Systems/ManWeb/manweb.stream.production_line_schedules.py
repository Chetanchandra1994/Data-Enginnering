from airflow.decorators import dag, task
from datetime import datetime, timedelta

# Connectors and Operators
from connectors.api.source.apigee_custom.apigee_production_schedules_source_connector import ApigeeProductionSchedulesConnector
from connectors.memory.memory_source_connector import MemorySourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
from connectors.cloud.target.bigquery_target_connector import BigQueryTargetConnector
from connectors.cloud.source.bigquery_source_connector import BigquerySourceConnector
from operators.readonly import ReadOnly
from operators.extraction import ExtractionOperator
from airflow.models import Variable

default_args = {
    "executor": "CeleryExecutor"
}

@dag(
    dag_id='manweb.stream.production_line_schedules',
    default_args = default_args,
    start_date=datetime(2026, 1, 1),
    schedule_interval="*/5 * * * *",
    catchup=False,
    tags=['rabbitmq', 'stream', 'manweb', 'gcs', 'bigquery'],
    max_active_runs=1
)
def production_planning_dag():

    # 1. Fetch metadata from BigQuery
    upcoming_shifts = ReadOnly(
        task_id="retrieve_upcoming_shifts",
        source=BigquerySourceConnector(
            conn_id="bigquery-edl-dw", 
            query="SELECT * FROM dw_ProductionManagement.vw_shift_starting_in_next_hour"
        )
    )

    @task
    def process_all_and_merge(records, **context):
        all_api_chunks = []
        
        for record in records:
            try:
                date_obj = datetime.strptime(record['Date'], '%Y-%m-%d')
                formatted_date = (date_obj + timedelta(days=1)).strftime('%Y-%m-%d')
                
                source_obj = ApigeeProductionSchedulesConnector(
                    conn_id='apigee',
                    method='GET',
                    endpoint=f"{Variable.get("MANWEBAPP_URL_PATH")}/Entity/{record['Entity']}/ProductionLine/{record['equipment_id']}/FormattedDate/{formatted_date}/WorkingShiftDetailUuid/{record['Working_shift_detail_uuid']}",
                    skip_if_empty=True,
                    bq_metadata=record,
                    empty_check_key='ProductionLineSchedules'
                )
                
                with source_obj as src:
                    if src.extract(context):
                        batch_bytes = src.get_data()
                        if batch_bytes:
                            all_api_chunks.append(batch_bytes.strip())
                            
            except Exception as e:
                print(f"Error processing record {record}: {e}")
                continue

        if not all_api_chunks:
            print("No data retrieved. Skipping upload.")
            return

        return ExtractionOperator(
            task_id="consolidated_extraction",
            source=MemorySourceConnector(all_api_chunks),
            targets=[
                GCSTargetConnector(
                    conn_id='gcs-bucket-project',
                    gcs_path='raw/ProductionPlanningByLineAPI',
                    table_name='ProductionLineSchedules'
                ),
                BigQueryTargetConnector(
                    conn_id='bigquery-edl-landing',
                    bq_landing_table='ProductionPlanningByLineAPI.ProductionLineSchedules',
                    bq_merge_procedure='ProductionPlanningByLineAPI.sp_Merge_ProductionLineSchedules'
                )
            ]
        ).execute(context=context)

    process_all_and_merge(upcoming_shifts.output)

production_planning_dag_instance = production_planning_dag()
from airflow.decorators import dag, task
from datetime import datetime
from connectors.cloud.source.bigquery_source_connector import BigquerySourceConnector
from operators.readonly import ReadOnly
import json
import logging

@dag(
    dag_id='retrieval_for_multitask_example',
    start_date=datetime(2023, 1, 1),
    schedule_interval=None,
    catchup=False,
    tags=['bq', 'gcs']
)
def example_from_task_to_another():

    get_data_task = ReadOnly(
        task_id="get_small_metadata",
        source=BigquerySourceConnector(
            conn_id="bigquery-edl-landing", 
            query="SELECT * FROM `bigquery-255612.SPM_CA.working_shift`"
        )
    )

    @task
    def process_records(records):
        if not records:
                print("No records found to process.")
                return

        for i, row in enumerate(records):
            pretty_row = json.dumps(row, indent=4)
            print(f"--- Record {i+1} ---")
            print(pretty_row)

    process_records(get_data_task.output)

example_from_task_to_another()
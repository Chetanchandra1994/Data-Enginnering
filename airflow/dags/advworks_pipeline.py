from airflow.sdk import dag, task
from datetime import datetime


@dag(
    dag_id="advworks_pipeline",
    start_date=datetime(2026, 9, 16),
    schedule=None,
    catchup=False,
    tags=["adventureworks", "data-engineering"],
)
def advworks_pipeline():

    @task
    def extract_customer():
        print("Extracting AdventureWorks DimCustomer data...")
        return "customer_extract_complete"

    @task
    def validate_extract(extract_status):
        print(f"Validating extraction: {extract_status}")
        return "validation_complete"

    @task
    def finish(validation_status):
        print(f"Pipeline completed: {validation_status}")

    extract_status = extract_customer()
    validation_status = validate_extract(extract_status)
    finish(validation_status)


advworks_pipeline()
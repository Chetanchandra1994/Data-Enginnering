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
    def extract_data():
        import sys

        sys.path.insert(0, "/opt/airflow/python-ingestion")

        from Stage_8_GCS_extract_all_tables_using_airflow import run_ingestion

        print("Starting AdventureWorks ingestion...")

        result = run_ingestion()

        print(f"Ingestion result: {result}")

        return result

    @task
    def validate_extraction(result):
        print("Validating Airflow extraction result...")

        if result["status"] != "success":
            raise RuntimeError("Extraction failed.")

        for table in result["tables"]:
            print(
                f"Table: {table['table']} | "
                f"Mode: {table['mode']} | "
                f"Rows: {table['rows_extracted']}"
            )

        print("Extraction validation successful.")

        return "validation_success"

    extraction_result = extract_data()
    validation_result = validate_extraction(extraction_result)


advworks_pipeline()
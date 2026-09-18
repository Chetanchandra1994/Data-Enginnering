from typing import Any, Dict
from airflow.exceptions import AirflowException
from airflow.providers.google.cloud.hooks.bigquery import BigQueryHook
from google.cloud.bigquery import TableReference, LoadJobConfig
from google.cloud.exceptions import GoogleCloudError
from connectors.base_connector import TargetConnector

class BigQueryTargetConnector(TargetConnector):
    """
    Target connector that expects a GCS URI as 'data' input and loads it into BigQuery.
    Performs a BigQuery load job and optionally calls a merge stored procedure.
    Implements the TargetConnector interface for Airflow pipelines.
    """
    def __init__(
        self,
        conn_id: str = "google_cloud_default",
        bq_landing_table: str | None = None,
        bq_write_disposition: str = "WRITE_APPEND",
        bq_merge_procedure: str | None = None,
    ):
        """
        Initialize the BigQuery target connector.
        conn_id: Airflow connection ID for BigQuery.
        bq_landing_table: Table to load data into.
        bq_write_disposition: Write disposition for the load job.
        bq_merge_procedure: Optional stored procedure to call after load.
        """
        super().__init__(conn_id)
        self.bq_landing_table = bq_landing_table
        self.bq_write_disposition = bq_write_disposition
        self.bq_merge_procedure = bq_merge_procedure

    def __enter__(self):
        """
        Validate the landing table and initialize the BigQuery hook.
        """
        if not self.bq_landing_table:
            raise AirflowException("BigQuery landing table must be provided.")
        # Initialize the hook once for use in save()
        self.hook = BigQueryHook(gcp_conn_id=self.connection_id)
        return self

    def save(self, log: Any, data: Any, context: Dict[str, Any]):
        """
        Consume a GCS URI string to perform the BigQuery load and optional merge procedure.
        Returns the GCS URI after successful load and merge.
        """
        gcs_uri = data
        
        if not isinstance(gcs_uri, str) or not gcs_uri.startswith("gs://"):
            log.error(f"BigQuery expected a URI string, but received: {type(data)}")
            raise AirflowException(f"Invalid input to BigQueryTargetConnector: {data}")

        # 1. Perform BigQuery Load from GCS
        self._load_from_gcs(log, gcs_uri)
            
        return gcs_uri
    
    def post_process(self, log, data, context):
        # Call Merge Stored Procedure if configured
        self.log.info(f"Beggining post processing for merge procedure if configured.")
        if self.bq_merge_procedure:
            self._execute_procedure(log)
        else:
            self.log.info(f"No merge procedure configured. Skipping post processing.")


    def _load_from_gcs(self, log, gcs_uri):
        """
        Internal logic to load NDJSON from GCS into BigQuery using the configured table and job settings.
        """
        try:
            project_id = self.hook.project_id
            full_table_id = f"{project_id}.{self.bq_landing_table}"
            table_ref = TableReference.from_string(full_table_id)

            job_config = LoadJobConfig(
                source_format="NEWLINE_DELIMITED_JSON",
                write_disposition=self.bq_write_disposition,
                create_disposition="CREATE_NEVER",
                ignore_unknown_values=True,
                autodetect=False 
            )

            log.info(f"Loading {gcs_uri} into {full_table_id}")
            client = self.hook.get_client(project_id=project_id)
            job = client.load_table_from_uri(
                source_uris=gcs_uri,
                destination=table_ref,
                job_config=job_config,
            )
            job.result() # Wait for completion
            log.info(f"BQ Load job {job.job_id} completed.")

        except GoogleCloudError as e:
            log.error(f"BQ load failed for {gcs_uri}: {e}")
            raise AirflowException(f"BigQuery load failed: {e}")

    def _execute_procedure(self, log):
        """Internal logic to call a BigQuery stored procedure."""
        try:
            project_id = self.hook.project_id
            full_procedure_id = f"{project_id}.{self.bq_merge_procedure}"
            sql = f"CALL `{full_procedure_id}`()"
            
            log.info(f"Calling procedure: {full_procedure_id}")
            client = self.hook.get_client(project_id=project_id)
            query_job = client.query(sql)
            query_job.result()
            log.info(f"Procedure '{full_procedure_id}' executed successfully.")

        except GoogleCloudError as e:
            log.error(f"Procedure call failed: {e}")
            raise AirflowException(f"BigQuery procedure call failed: {e}")
        
    def close_connection(self):
        """
        Releases the underlying HTTP session resources.
        Maintains the 'Safe Pipeline' contract for the ExtractionOperator.
        """
        if hasattr(self, 'client') and self.client:
            self.log.info("Closing GCS client transport session.")
            try:
                self.client.close()
            except AttributeError:
                pass
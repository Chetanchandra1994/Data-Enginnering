from airflow.providers.google.common.hooks.base_google import GoogleBaseHook
from airflow.providers.google.cloud.hooks.gcs import GCSHook
from google.cloud import storage
from airflow.exceptions import AirflowException
from connectors.base_connector import SourceConnector

class GCSSourceConnector(SourceConnector):
    """
    Source connector to list or read metadata from Google Cloud Storage (GCS).
    Used for connectivity testing and file discovery in Airflow pipelines.
    """
    def __init__(
        self, 
        conn_id: str = "google_cloud_default", 
        bucket_name: str | None = None, 
        project_id: str | None = None
    ):
        """
        Initialize the GCS source connector.
        conn_id: Airflow connection ID for GCS.
        bucket_name: Name of the GCS bucket to list/read from.
        project_id: GCP project ID.
        """
        super().__init__(conn_id)
        self.bucket_name = bucket_name
        self.project_id = project_id
        self._has_run = False

    def __enter__(self):
        """
        Initialize the GCS Hook using standard Airflow providers.
        """
        self.hook = GCSHook(conn_id=self.connection_id)
        return self

    def extract(self, context: dict) -> bool:
        """
        List blobs in the bucket and serialize the metadata for downstream use.
        Returns True if any blobs are found, False otherwise.
        """
        if self._has_run:
            return False
            
        target_bucket = self.bucket_name or self.hook.project_id
        blobs = self.hook.list(bucket_name=target_bucket)
        
        records = [{"name": b} for b in blobs] if blobs else []
        self.extracted_data = [self._serialize(r) for r in records]
        
        self._has_run = True
        return len(self.extracted_data) > 0
from airflow.providers.google.common.hooks.base_google import GoogleBaseHook
from airflow.providers.google.cloud.hooks.gcs import GCSHook
from google.cloud import storage
from airflow.exceptions import AirflowException
from connectors.base_connector import TargetConnector
from datetime import datetime
import io

class GCSTargetConnector(TargetConnector):
    """
    Target connector for writing data to Google Cloud Storage (GCS).
    Handles file naming, bucket/project resolution, and client setup.
    """
    def __init__(self, conn_id="google_cloud_default", bucket_name=None, 
                 project_id=None, gcs_path=None, table_name=None, file_prefix=None):
        """
        Initialize the GCS target connector.
        conn_id: Airflow connection ID for GCS.
        bucket_name: Name of the GCS bucket to write to.
        project_id: GCP project ID.
        gcs_path: Path in the bucket to write files.
        table_name: Optional table name for metadata.
        file_prefix: Prefix for output files.
        """
        super().__init__(conn_id)
        self.bucket_name = bucket_name
        self.project_id = project_id
        self.gcs_path = gcs_path
        self.table_name = table_name
        self.file_prefix = file_prefix
        self._part_num = 0

    def __enter__(self):
        hook = GoogleBaseHook(gcp_conn_id=self.connection_id)
        self._effective_project_id = self.project_id or hook.project_id
        self._effective_bucket_name = self.bucket_name or self._effective_project_id
        self.client = storage.Client(project=self._effective_project_id)
        return self

    def save(self, log, data: bytes, context: dict): 
        if not data:
            log.info(f"Skipping upload, no data provided for upload.")
            return None
        
        # 1. Retrieve the XCom key dynamically from the Source Connector
        ti = context['ti']

        # 2. Use Logical Date for consistent naming across all connectors in the run
        ts = ti.start_date if ti and ti.start_date else (context.get('logical_date'))
        formatted_date = ts.strftime("%Y%m%d%H%M%S%f")[:-3]
        
        file_name = f"{self.gcs_path}/{self.table_name}/{self.file_prefix}_{self.table_name}_{formatted_date}_{self._part_num}.json"
        
        # 3. Upload to GCS
        bucket = self.client.bucket(self._effective_bucket_name)
        blob = bucket.blob(file_name)
        
        log.info(f"Uploading to gs://{self._effective_bucket_name}/{file_name} with prefix '{self.file_prefix}'")
        # =================================================================
        # START OF CHANGED BLOCK: High-Speed Optimized Binary Streaming
        # =================================================================
        # 1. Set a large transport window to reduce network handshakes
        chunk_size = 32 * 1024 * 1024  # 32MB
        blob.chunk_size = chunk_size
        
        total_bytes = len(data)
        total_mb = total_bytes / (1024 * 1024)
        log.info(f"Total payload size to transfer: {total_mb:.2f} MB")
        log.info("Opening secure channel and streaming to Google Cloud...")
        # Wrap incoming bytes in a stream to correctly track data transfer metrics
        data_stream = io.BytesIO(data)
        # 2. Directly write the entire bytes object. 
        # The underlying Google SDK will automatically stream it in 32MB blocks
        # at native C-speed, bypassing the slow Python while loop.
        with blob.open("wb", content_type="application/jsonl") as f:
            f.write(data_stream.read())

            # Re-calculating your custom tracking variables right inside the context manager
            bytes_uploaded = data_stream.tell()
            current_mb = bytes_uploaded / (1024 * 1024)
            progress_pct = (bytes_uploaded / total_bytes) * 100
        # This executes only when the handshake finishes successfully
        log.info(f"✓ Upload Complete: Streamed {current_mb:.2f}MB / {total_mb:.2f}MB ({progress_pct:.1f}% complete) for part {self._part_num}.")
        # =================================================================
        # END OF CHANGED BLOCK
        # =================================================================
        
        self._part_num += 1
        return f"gs://{self._effective_bucket_name}/{file_name}"
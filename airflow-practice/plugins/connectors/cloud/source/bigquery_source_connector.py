from airflow.providers.google.cloud.hooks.bigquery import BigQueryHook
from google.cloud import bigquery
from airflow.exceptions import AirflowException
from connectors.base_connector import SourceConnector
from decimal import Decimal
from datetime import datetime, date

class BigquerySourceConnector(SourceConnector):
    """
    Source connector to read from BigQuery Table.
    Used for connectivity testing and file discovery in Airflow pipelines.
    """
    def __init__(self, conn_id, query, query_mode='default', delta_column=None, xcom_key=None, project_id=None):
        """
        Initialize the BQ source connector.
        conn_id: Airflow connection ID for GCS.
        Query: Query to execute in BigQuery.
        project_id: GCP project ID.
        query_mode: 'default' or 'delta' for incremental loads
        delta_column: Column to track for high-water mark
        xcom_key: XCom key for storing checkpoint
        """
        super().__init__(conn_id)
        self.query = query
        self.query_mode = query_mode
        self.delta_column = delta_column
        self.xcom_key = xcom_key
        self.project_id = project_id
        self._current_max_value = None
        self._total_records_processed = 0

    def __enter__(self):
        """
        Initialize the BQ Hook using standard Airflow providers.
        """
        self.hook = BigQueryHook(gcp_conn_id=self.connection_id, use_legacy_sql=False)
        self._effective_project_id = self.project_id or self.hook.project_id
        self.client = bigquery.Client(project=self._effective_project_id)
        return self
    
    def _build_query(self, context: dict) -> tuple[str, str]:
        """
        Build the final SQL query based on the query_mode.
        If in 'delta' mode, appends a WHERE clause to filter by the last checkpoint value.
        Returns (final_sql, load_type).
        """
        final_sql = self.query.strip()
        load_type = 'fullload'

        if self.query_mode == 'delta':
            last_val = self._get_last_checkpoint(context)
            
            if last_val:
                self.log.info(f"Found last execution value '{last_val}' for BigQuery delta load.")
                load_type = 'stream'
                delta_condition = f"{self.delta_column} > '{last_val}'"
                
                if ' where ' in final_sql.lower():
                    final_sql = f"{final_sql} AND {delta_condition}"
                else:
                    final_sql = f"{final_sql} WHERE {delta_condition}"
            else:
                self.log.info("No checkpoint found. Performing BigQuery full load.")
        
        return final_sql, load_type

    def extract(self, context: dict) -> bool:
        """
        Extract data from BigQuery using provided Query.
        """

        if not hasattr(self, "_page_iterator"):
            query, self._load_type = self._build_query(context)
            self.log.info(f"Executing BQ {self._load_type} query")
                
            query_job = self.client.query(query)

            results = query_job.result()

            self._page_iterator = results.pages

        try:
            page = next(self._page_iterator)
            records = []
            for row in page:
                r = dict(row.items())
                for key, value in r.items():
                    if isinstance(value, Decimal):
                        r[key] = float(value)
                    elif isinstance(value, (datetime, date)):
                        r[key] = value.isoformat()
                records.append(r)

            batch_count = len(records)
            self._total_records_processed += batch_count
            self.log.info(f"Processed batch of {batch_count} records. Total so far: {self._total_records_processed}")
                
            if self.query_mode == 'delta' and self.delta_column:
                col_name = self.delta_column.replace('-', '_')
                batch_max = max((r.get(col_name) for r in records if r.get(col_name)), default=None)
                if batch_max and (self._current_max_value is None or batch_max > self._current_max_value):
                    self._current_max_value = batch_max

            self.extracted_data = self._serialize(records, context=context)
                
            return True

        except StopIteration:
            self.log.info(f"Extraction complete. Total records processed: {self._total_records_processed}")
            return False
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """
        This prevents the cursor/connection from closing when the producer 
        thread finishes its 'with' block.
        """
        pass

    def close_connection(self):
        """
        Releases the underlying HTTP session resources.
        Maintains the 'Safe Pipeline' contract for the ExtractionOperator.
        """
        if hasattr(self, 'client') and self.client:
            self.log.info("Closing BQ client transport session.")
            try:
                self.client.close()
            except AttributeError:
                pass
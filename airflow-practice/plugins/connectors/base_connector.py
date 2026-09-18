from abc import ABC, abstractmethod
from typing import Any, Optional
from airflow.models.xcom_arg import XComArg
import logging
import orjson
from datetime import datetime

class BaseConnector(ABC):
    """
    Abstract base class for all connectors.
    Provides common interface and utility methods for data extraction and serialization.
    """
    def __init__(self, conn_id: str, limit: int | None = None, src_system_operation: str = 'Insert', **kwargs):
        """
        Initialize the connector with a connection ID and optional row limit.
        """
        self.connection_id = conn_id
        self.limit = limit
        self.src_system_operation = src_system_operation
        self.client: Any = None
        self._current_max_value = None
        self._total_records_processed = 0
        self.log = logging.getLogger(self.__class__.__name__)

    @abstractmethod
    def __enter__(self):
        """
        Context manager entry. Should be implemented by subclasses to handle resource setup.
        """
        pass

    def on_pipeline_success(self, context: dict):
        """
        Finalize source state after targets succeed.
        Executed in the Main Thread to ensure XCom stability.
        This method is meant for any delta load from databases (JDBC,ODBC,BigQuery). It doesn't handle anything that doesn't implement query_mode 'delta'
        """
        self.log.info(f"Executing success hook for {self.__class__.__name__}")

        if getattr(self, 'query_mode', None) != 'delta':
            self.log.info("Success hook skipped: Connector is not in 'delta' mode.")
            return

        if self._current_max_value is not None:
            context['ti'].xcom_push(key=self.xcom_key, value=str(self._current_max_value)) #
            self.log.info(f"Pushed to xcom {self.xcom_key} with value {str(self._current_max_value)}") #
        else:
            self.log.warning(
                f"XCom push skipped for key '{self.xcom_key}'. "
                f"Reason: _current_max_value is None. "
                f"Check if delta_column '{self.delta_column}' exists in the SQL query "
                f"and if any records were actually returned."
            )

    def on_pipeline_failure(self, error: Exception):
        """Optional: Handle source recovery if targets fail."""
        raise error

    def close_connection(self):
        """Optional: Close long-lived connections (JDBC/RabbitMQ)."""
        pass

    def __exit__(self, exc_type, exc_val, exc_tb):
        """
        Context manager exit. Can be overridden by subclasses for cleanup.
        """
        pass

    def _resolve_xcom_args(self, value: Any, context: dict) -> Any:
        """
        Recursively resolve Airflow XComArg objects in the input value using the provided context.
        """
        if isinstance(value, XComArg):
            return value.resolve(context)
        if isinstance(value, dict):
            return {k: self._resolve_xcom_args(v, context) for k, v in value.items()}
        if isinstance(value, list):
            return [self._resolve_xcom_args(i, context) for i in value]
        return value
    
    def _serialize(self, data: Any, context: dict = None) -> bytes:
        """
        If data is a list of records, it serializes each and joins with \n.
        """
        if isinstance(data, bytes):
            return data
        
        # Ensure we are working with a list of records
        records = data if isinstance(data, list) else [data]
        
        serialized_records = []
        for record in records:
            if context and isinstance(record, dict):
                now_iso = datetime.now().strftime('%Y-%m-%dT%H:%M:%S.%f')[:-3] + 'Z'
                record.update({
                    'ipaas_updated_date': record.get('ipaas_updated_date', now_iso),
                    'src_system_operation': record.get('src_system_operation', self.src_system_operation),
                    'airflow_dag_id': context['dag'].dag_id,
                    'airflow_run_id': context['run_id'],
                    'airflow_task_id': context['ti'].task_id
                })
            serialized_records.append(orjson.dumps(record, option=orjson.OPT_SERIALIZE_NUMPY))

        return b"\n".join(serialized_records)

class SourceConnector(BaseConnector):
    """
    Abstract base class for source connectors.
    Defines the interface for data extraction and storage of extracted data.
    """
    def __init__(self, conn_id: str, **kwargs):
        super().__init__(conn_id, **kwargs)
        self.extracted_data: Any = None

    @abstractmethod
    def extract(self, context: dict) -> bool:
        """
        Extract data from the source. Returns True if data was extracted, False otherwise.
        Should be implemented by subclasses.
        """
        pass
    
    def get_data(self) -> Any:
        """
        Return the most recently extracted data.
        """
        return self.extracted_data
    
    def _get_last_checkpoint(self, context: dict) -> str | None:
        """
        Retrieve the last successful high-water mark from XCom.
        Used by child connectors to build delta/incremental queries.
        """
        ti = context['ti']
        return ti.xcom_pull(
            key=self.xcom_key,
            dag_id=context['dag'].dag_id,
            task_ids=ti.task_id,
            include_prior_dates=True
        )
    
    def _push_xcom_max(self, context):
        """
        Push the current max value to XCom for delta/incremental loads.
        Only called when query_mode is 'delta'.
        """
        if self.query_mode != 'delta':
            return

        if self._current_max_value is not None:
            context['ti'].xcom_push(key=self.xcom_key, value=str(self._current_max_value)) #
            self.log.info(f"Pushed to xcom {self.xcom_key} with value {str(self._current_max_value)}") #
        else:
            self.log.warning(
                f"XCom push skipped for key '{self.xcom_key}'. "
                f"Reason: _current_max_value is None. "
                f"Check if delta_column '{self.delta_column}' exists in the SQL query "
                f"and if any records were actually returned."
            )

class TargetConnector(BaseConnector):
    """
    Abstract base for all target connectors (GCS, BigQuery, etc.).
    """
    def __init__(self, conn_id: str, **kwargs):
        super().__init__(conn_id, **kwargs)

    @abstractmethod
    def save(self, logger, data: Any, context: dict):
        """Standard interface for saving extracted data."""
        pass

    def post_process(self, log, data, context):
        """Optionnal: Allow post processing in Target connector"""
        pass
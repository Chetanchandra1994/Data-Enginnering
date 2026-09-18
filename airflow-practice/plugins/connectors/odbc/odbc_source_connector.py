import re
import orjson
import logging
from airflow.exceptions import AirflowException
from connectors.base_connector import SourceConnector
from abc import abstractmethod
from decimal import Decimal
import gc

class OdbcSourceConnector(SourceConnector):
    """
    Base class for all ODBC-based source connectors.
    Aligned with JDBC logic to produce a single NDJSON bytes object.
    """
    NEWLINE_REGEX = re.compile(r'[\r\n\t]+')

    def __init__(self, conn_id, sql, query_mode='default', delta_column=None, xcom_key=None):
        super().__init__(conn_id)
        self.log = logging.getLogger(self.__class__.__name__)
        self.sql = sql
        self.query_mode = query_mode
        self.delta_column = delta_column
        self.xcom_key = xcom_key
        self._header = None
        self._current_max_value = None
        self.limit = 25000
        self._batch_index = 0
        self._total_records_processed = 0

    @abstractmethod
    def _build_query(self, context: dict) -> tuple[str, str]:
        pass

    def _clean_record(self, record: dict) -> dict:
        """Modifies record in-place to ensure numeric and string compatibility."""
        sub_func = self.NEWLINE_REGEX.sub
        for key, value in record.items():
            if isinstance(value, Decimal):
                record[key] = float(value)
            elif isinstance(value, str):
                if any(char in value for char in ('\n', '\r', '\t')):
                    record[key] = sub_func(' ', value)
        return record

    def _sanitize_prepare_batch(self, batch: list[tuple]) -> list[dict]:
        """
        Returns a list of clean dictionnaries, not bytes.
        """
        header = self._header
        return [self._clean_record(dict(zip(header, row))) for row in batch]
    
    def extract(self, context: dict) -> bool:
        """Standard extraction lifecycle compatible with multi-batch processing."""
        self.extracted_data = None
        gc.collect()
        
        if self._header is None:
            sql, self._load_type = self._build_query(context)
            self.log.info(f"Executing {self._load_type} query via pyodbc: {sql}")
            self.cursor.execute(sql)
            
            if not self.cursor.description:
                return False
            
            self._header = [(d[0].replace('-', '_') if d[0] else 'col') for d in self.cursor.description]

        self._batch_index += 1
        self.log.info(f"--- [Batch #{self._batch_index}] Fetching next {self.limit} records ---")
        
        batch = self.cursor.fetchmany(self.limit)

        if not batch:
            self.log.info("No more records found.")
            return False
        
        # 1. Transform raw batch into clean dictionaries
        cleaned_dicts = self._sanitize_prepare_batch(batch)
        self._total_records_processed += len(cleaned_dicts)

        # 2. Update Delta column most recent record if necessary
        if self.query_mode == 'delta' and self.delta_column:
            col_name = self.delta_column.replace('-', '_')
            batch_max = max((r.get(col_name) for r in cleaned_dicts if r.get(col_name)), default=None)
            if batch_max and (self._current_max_value is None or batch_max > self._current_max_value):
                self._current_max_value = batch_max

        self.extracted_data = self._serialize(cleaned_dicts, context=context)

        self.log.info(f"[Batch #{self._batch_index}] Processed {len(cleaned_dicts)} records.")
        return True
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """Standardized empty exit to allow manual cleanup by operator."""
        pass
    
    def close_connection(self):
        """Explicit cleanup only called when the entire task finishes."""
        if hasattr(self, 'cursor') and self.cursor:
            self.log.info("Closing ODBC cursor.")
            self.cursor.close()
        if hasattr(self, 'conn') and self.conn:
            self.log.info("Closing ODBC connection.")
            self.conn.close()
import re
import orjson
import logging
import gc
from decimal import Decimal
from abc import abstractmethod
from connectors.base_connector import SourceConnector

class Psycopg2SourceConnector(SourceConnector):
    """
    Base class for all Psycopg2 (Postgres) based source connectors.
    Optimized for Airflow Metadata extraction without ODBC overhead.
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
        """Modifies record in-place to handle Postgres specific types like memoryview."""
        sub_func = self.NEWLINE_REGEX.sub
        for key, value in record.items():
            # Handle binary/bytea columns (like executor_config)
            if isinstance(value, memoryview):
                record[key] = value.tobytes().decode('utf-8', errors='ignore')
            
            # Existing numeric/string cleaning
            elif isinstance(value, Decimal):
                record[key] = float(value)
            elif isinstance(value, str):
                if any(char in value for char in ('\n', '\r', '\t')):
                    record[key] = sub_func(' ', value)
        return record

    def _sanitize_prepare_batch(self, batch: list[tuple]) -> list[dict]:
        header = self._header
        return [self._clean_record(dict(zip(header, row))) for row in batch]

    def extract(self, context: dict) -> bool:
        """Lifecycle using Psycopg2 fetchmany."""
        self.extracted_data = None
        gc.collect()
        
        if self._header is None:
            sql, self._load_type = self._build_query(context)
            self.log.info(f"Executing {self._load_type} query via Psycopg2: {sql}")
            self.cursor.execute(sql)
            
            if self.cursor.description is None:
                return False
            
            self._header = [d[0].replace('-', '_') for d in self.cursor.description]

        self._batch_index += 1
        self.log.info(f"--- [Batch #{self._batch_index}] Fetching next {self.limit} records ---")
        
        batch = self.cursor.fetchmany(self.limit)

        if not batch:
            self.log.info("Metadata extraction complete.")
            return False
        
        cleaned_dicts = self._sanitize_prepare_batch(batch)
        self._total_records_processed += len(cleaned_dicts)

        # Delta logic for tracking 'start_date' or 'updated_at'
        if self.query_mode == 'delta' and self.delta_column:
            col_name = self.delta_column.replace('-', '_')
            batch_max = max((r.get(col_name) for r in cleaned_dicts if r.get(col_name)), default=None)
            if batch_max and (self._current_max_value is None or batch_max > self._current_max_value):
                self._current_max_value = batch_max

        self.extracted_data = self._serialize(cleaned_dicts, context=context)
        return True

    def close_connection(self):
        """Explicit cleanup for Postgres cursors/connections."""
        if hasattr(self, 'cursor') and self.cursor:
            self.log.info("Closing Psycopg2 cursor.")
            self.cursor.close()
        if hasattr(self, 'conn') and self.conn:
            self.log.info("Closing Psycopg2 connection.")
            self.conn.close()
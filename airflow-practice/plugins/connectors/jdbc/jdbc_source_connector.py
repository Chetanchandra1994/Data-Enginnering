import re
import orjson
import logging
from airflow.exceptions import AirflowException
from connectors.base_connector import SourceConnector
from abc import abstractmethod

class JdbcSourceConnector(SourceConnector):
    """
    Base class for all JDBC-based source connectors (MSSQL, Oracle, Progress).
    Provides shared logic for query execution, batch extraction, sanitization, and incremental (delta) loading.
    """
    NEWLINE_REGEX = re.compile(r'[\r\n\t]+')

    def __init__(self, conn_id, sql, query_mode='default', delta_column=None, xcom_key=None, limit=25000):
        """
        Initialize the JDBC connector with SQL, query mode, and optional delta tracking.
        conn_id: Airflow connection ID
        sql: SQL query to execute
        query_mode: 'default' or 'delta' for incremental loads
        delta_column: Column to track for high-water mark
        xcom_key: XCom key for storing checkpoint
        limit: The maximum number of records to fetch per batch
        """
        super().__init__(conn_id)
        self.log = logging.getLogger(self.__class__.__name__)
        self.sql = sql
        self.query_mode = query_mode
        self.delta_column = delta_column
        self.xcom_key = xcom_key
        self.limit = limit
        self._header = None  # Column names for result set
        self._current_max_value = None  # Tracks max value for delta loads

    @abstractmethod
    def _build_query(self, context: dict) -> tuple[str, str]:
        """
        Abstract method to build the final SQL query for the connector.
        Must be implemented by each leaf connector.
        """
        pass

    def _sanitize_records(self, records: list[dict]) -> list[dict]:
        """
        Cleans records and converts Java types to Python primitives.
        Logs the first record's transformation for verification.
        """
        sub_func = self.NEWLINE_REGEX.sub
        native_python_types = (str, int, float, bool)
        
        if not records:
            return records

        for record in records:
            for key, value in record.items():
                if value is None:
                    continue

                # 1. Handle Strings (Clean newlines/tabs)
                if isinstance(value, str):
                    if any(char in value for char in ('\n', '\r', '\t')):
                        record[key] = sub_func(' ', value)
                    continue

                # 2. Force conversion for Java Proxies
                c_name = str(value.__class__.__name__)
                
                try:
                    if 'Boolean' in c_name:
                        record[key] = bool(value)
                    elif 'Double' in c_name or 'Float' in c_name or 'Decimal' in c_name:
                        record[key] = float(value)
                    elif 'Int' in c_name or 'Long' in c_name or 'Short' in c_name:
                        record[key] = int(value)
                    elif not isinstance(value, native_python_types):
                        # Fallback for unknown non-native types
                        record[key] = str(value)
                except (TypeError, ValueError):
                    record[key] = str(value)
            
        return records
    
    def extract(self, context: dict) -> bool:
        is_initial_call = self._header is None
        
        if is_initial_call:
            sql, self._load_type = self._build_query(context)
            self.log.info(f"Executing {self._load_type} query: {sql}")
            self.cursor.execute(sql)
            self.cursor.arraysize = 20000

            try:
                if hasattr(self.cursor, '_prep') and self.cursor._prep:
                    self.cursor._prep.setFetchSize(20000)
                elif hasattr(self.cursor, '_st') and self.cursor._st:
                    self.cursor._st.setFetchSize(20000)
            except Exception as e:
                self.log.debug(f"JDBC setFetchSize not supported: {e}")
            
            if not self.cursor.description:
                return False
            
            self._header = [(d[0].replace('-', '_') if d[0] else 'col') for d in self.cursor.description]
    
        fetch_size = self.limit
        batch = self.cursor.fetchmany(fetch_size)
        
        if not batch:
            self.log.info(f"No records found/remaining for {self.__class__.__name__}.")
            return False

        records = [dict(zip(self._header, row)) for row in batch]

        cleaned_records = self._sanitize_records(records)

        if self.query_mode == 'delta' and self.delta_column:
            col_name = self.delta_column.replace('-', '_')
            batch_max = max((r.get(col_name) for r in records if r.get(col_name)), default=None)
            if batch_max and (self._current_max_value is None or batch_max > self._current_max_value):
                self._current_max_value = batch_max

        self.extracted_data = self._serialize(cleaned_records, context=context)

        self.log.info(f"Retrieved {len(batch)} records from {self.__class__.__name__}.")

        return True
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """
        This prevents the cursor/connection from closing when the producer 
        thread finishes its 'with' block.
        """
        pass

    def close_connection(self):
        """
        The only location where resources are freed.
        """
        if hasattr(self, 'cursor') and self.cursor:
            self.log.info("Closing JDBC cursor.")
            self.cursor.close()
        if hasattr(self, 'conn') and self.conn:
            self.log.info("Closing JDBC connection.")
            self.conn.close()
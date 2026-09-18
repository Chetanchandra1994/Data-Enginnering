from typing import Dict, Any, List
from datetime import datetime
import orjson
import logging

from airflow.exceptions import AirflowException
from airflow.providers.snowflake.hooks.snowflake import SnowflakeHook
from airflow.hooks.base import BaseHook

from connectors.base_connector import TargetConnector

class SnowflakeTargetConnector(TargetConnector):
    """
    Target connector for handling audit-style bulk inserts into Snowflake tables.
    Collapses batches into a single VARIANT row for high-performance ingestion.
    """
    REQUIRED_COLUMNS = ['DATA', 'FILENAME', 'FILE_ROW_NUMBER', 'FILE_LAST_MODIFIED', 'START_SCAN_TIME']

    def __init__(self, conn_id: str, target_schema: str, table_name: str, file_prefix: str = None):
        super().__init__(conn_id)
        self.target_schema = target_schema
        self.table_name = table_name
        self.file_prefix = file_prefix
        self.hook = None
        self.conn = None
        self.conn_extra = None
        self.database = None
        self.log = logging.getLogger(self.__class__.__name__)

    def __enter__(self):
        if not self.connection_id:
            raise AirflowException("Snowflake connection_id is required.")
        self.hook = SnowflakeHook(snowflake_conn_id=self.connection_id)
        self.conn = self.hook.get_conn()
        self.conn_extra = BaseHook.get_connection(self.connection_id).extra_dejson
        self.database = self.conn_extra.get('database')
        return self

    def _execute_bulk_insert(self, records: List[Dict[str, Any]], context: Dict[str, Any]):
        """
        Inserts the batch as a single row grouped under the 'data' key.
        """
        fully_qualified_table = f"{self.database}.{self.target_schema}.{self.table_name}"

        # Grouping all records into one dictionary to preserve view logic
        grouped_records = [{"data": records}]
        
        row_placeholder = "(%s, %s, %s, %s, %s)"
        
        sql = f"""
            INSERT INTO {fully_qualified_table} ({", ".join(self.REQUIRED_COLUMNS)})
            SELECT PARSE_JSON(v.d), v.f, v.r, v.m, v.s
            FROM (VALUES {row_placeholder}) AS v(d, f, r, m, s)
        """
        
        flat_params = []
        for i, raw_record in enumerate(grouped_records, start=1):
            metadata = self._generate_metadata(raw_record, context=context)
            
            flat_params.extend([
                orjson.dumps(metadata["DATA_RECORD"]).decode('utf-8'),
                metadata["FILENAME"],
                len(records), # Use total count as the audit row number
                metadata["FILE_LAST_MODIFIED"],
                metadata["START_SCAN_TIME"],
            ])

        self.log.info(f"Executing batch insert: 1 row containing {len(records)} records.")
        self.hook.run(sql=sql, parameters=flat_params, autocommit=True)

    def _generate_metadata(self, record: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
        """
        Generates metadata using the Airflow logical date for consistent run-level filtering.
        """
        # Use logical_date for uniform timestamps across all batches in a run
        ts = context.get('logical_date') or datetime.now()
        
        ts_iso = ts.strftime('%Y-%m-%d %H:%M:%S.%f')[:-3]
        ts_str = ts.strftime('%Y%m%d%H%M%S%f')[:-3]

        fname = f"raw/{self.target_schema}/{self.table_name}/{self.file_prefix}_{ts_str}_0.json"
        
        return {
            "DATA_RECORD": record, 
            "FILENAME": fname, 
            "FILE_ROW_NUMBER": 1,
            "FILE_LAST_MODIFIED": ts_iso, 
            "START_SCAN_TIME": ts_iso
        }
    
    def save(self, log: Any, data: Any, context: Dict[str, Any] = None):
        if not data:
            return
        
        # Parse data into records
        if isinstance(data, bytes):
            records = [orjson.loads(line) for line in data.split(b'\n') if line.strip()]
        else:
            records = [
                (orjson.loads(r) if isinstance(r, (bytes, str)) else r) 
                for r in data
            ]
        
        if records:
            self._execute_bulk_insert(records, context=context)

    def close_connection(self):
        if self.conn:
            self.log.info("Closing Snowflake connection.")
            self.conn.close()
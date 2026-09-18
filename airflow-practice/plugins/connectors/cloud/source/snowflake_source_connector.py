from typing import Dict, Any, List
from datetime import datetime
import orjson

from airflow.exceptions import AirflowException
from airflow.providers.snowflake.hooks.snowflake import SnowflakeHook
from airflow.hooks.base import BaseHook

from connectors.base_connector import SourceConnector

class SnowflakeSourceConnector(SourceConnector):
    """
    Reads data from Snowflake. Implements the SourceConnector interface.
    """
    def __init__(self, conn_id: str, sql: str):
        super().__init__(conn_id)
        self.sql = sql
        self._has_run = False

    def __enter__(self):
        self.hook = SnowflakeHook(conn_id=self.connection_id)
        return self

    def extract(self, context: dict) -> bool:
        if self._has_run:
            return False

        self.log.info(f"Extracting data from Snowflake via query: {self.sql}")
        df = self.hook.get_pandas_df(self.sql)
        records = df.to_dict(orient='records')
        self.extracted_data = [self._serialize(r) for r in records]
        
        self._has_run = True
        return len(self.extracted_data) > 0

    def __exit__(self, exc_type, exc_val, exc_tb):
        pass
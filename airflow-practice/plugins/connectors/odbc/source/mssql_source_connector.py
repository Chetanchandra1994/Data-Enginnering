from connectors.odbc.odbc_source_connector import OdbcSourceConnector
from hooks.odbc.odbc_mssql_hook import OdbcMssqlHook

class MssqlSourceConnector(OdbcSourceConnector):
    """
    Leaf connector for Microsoft SQL Server via ODBC.
    Handles connection setup and dynamic SQL query building for full and incremental (delta) loads.
    """
    
    def __init__(self, database: str = None, **kwargs):
        """
        Initialize the MSSQL connector with the target database name.
        """
        self.database = database
        super().__init__(**kwargs)

    def __enter__(self):
        """
        Establish a ODBC connection to Microsoft SQL Server using the custom hook.
        """
        hook = OdbcMssqlHook(conn_id=self.connection_id, database=self.database)
        self.conn = hook.get_conn()
        self.cursor = self.conn.cursor()
        return self

    def _build_query(self, context: dict) -> tuple[str, str]:
        """
        Build the final SQL query based on the query_mode.
        If in 'delta' mode, appends a WHERE clause to filter by the last checkpoint value.
        Returns (final_sql, load_type).
        """
        final_sql = self.sql.strip()
        load_type = 'fullload'

        if self.query_mode == 'delta':
            # Use inherited helper to pull last checkpoint
            last_val = self._get_last_checkpoint(context)
            
            if last_val:
                self.log.info(f"Found last execution value '{last_val}' for MSSQL delta load.")
                load_type = 'stream'
                delta_condition = f"{self.delta_column} > '{last_val}'"
                
                if ' where ' in final_sql.lower():
                    final_sql = f"{final_sql} AND {delta_condition}"
                else:
                    final_sql = f"{final_sql} WHERE {delta_condition}"
            else:
                self.log.info("No checkpoint found. Performing MSSQL full load.")
        
        return final_sql, load_type
    
    def on_pipeline_success(self, context):
        """
        Override the success hook to force SQL Server-compatible 3-digit 
        millisecond precision in XCom state.
        """
        if self.query_mode == 'delta' and self._current_max_value:
            # SQL Server DATETIME conversion fails with 6-digit microseconds (.000000)
            # We truncate to 3 digits (.000) for compatibility
            if hasattr(self._current_max_value, 'strftime'):
                formatted_val = self._current_max_value.strftime('%Y-%m-%d %H:%M:%S.%f')[:-3]
            else:
                formatted_val = str(self._current_max_value)
                
            self.log.info(f"MSSQL Success Hook: Pushing truncated timestamp to XCom: {formatted_val}")
            context['ti'].xcom_push(key=self.xcom_key, value=formatted_val)
        else:
            self.log.info("MSSQL Success Hook: No delta value to push.")
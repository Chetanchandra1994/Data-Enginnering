from connectors.jdbc.jdbc_source_connector import JdbcSourceConnector
from hooks.jdbc.jdbc_mssql_hook import JdbcMssqlHook

class MssqlSourceConnector(JdbcSourceConnector):
    """
    Leaf connector for Microsoft SQL Server via JDBC.
    Handles connection setup and dynamic SQL query building for full and incremental (delta) loads.
    """
    
    def __init__(self, database: str, **kwargs):
        """
        Initialize the MSSQL connector with the target database name.
        """
        self.database = database
        super().__init__(**kwargs)

    def __enter__(self):
        """
        Establish a JDBC connection to Microsoft SQL Server using the custom hook.
        """
        hook = JdbcMssqlHook(conn_id=self.connection_id, database=self.database)
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
from connectors.jdbc.jdbc_source_connector import JdbcSourceConnector
from hooks.jdbc.jdbc_oracle_hook import JdbcOracleHook

class OracleSourceConnector(JdbcSourceConnector):
    """
    Leaf connector for Oracle Database via JDBC.
    Handles connection setup and dynamic SQL query building for full and incremental (delta) loads.
    Uses host-based connection strings via JdbcOracleHook.
    """

    def __init__(self, **kwargs):
        """
        Initialize the Oracle connector. No database argument needed; uses host-based connection.
        """
        super().__init__(**kwargs)

    def __enter__(self):
        """
        Initialize the Oracle JDBC connection via the specialized hook.
        Only the connection ID is required for the hook.
        """
        hook = JdbcOracleHook(conn_id=self.connection_id)
        self.conn = hook.get_conn()
        self.cursor = self.conn.cursor()
        return self

    def _build_query(self, context: dict) -> tuple[str, str]:
        """
        Build the final SQL query for Oracle, handling TO_TIMESTAMP for delta columns.
        If in 'delta' mode, appends a WHERE clause to filter by the last checkpoint value.
        Returns (final_sql, load_type).
        """
        final_sql = self.sql.strip()
        load_type = 'fullload'

        if self.query_mode == 'delta':
            last_val = self._get_last_checkpoint(context) # Inherited from JdbcSourceLegacyConnector
            
            if last_val:
                self.log.info(f"Found last execution value '{last_val}' for Oracle delta load.")
                load_type = 'stream'
                delta_cond = f"{self.delta_column} > TO_TIMESTAMP('{last_val}', 'YYYY-MM-DD HH24:MI:SS.FF3')"
                
                if ' where ' in final_sql.lower():
                    final_sql = f"{final_sql} AND {delta_cond}"
                else:
                    final_sql = f"{final_sql} WHERE {delta_cond}"
            else:
                self.log.info("No checkpoint found. Performing Oracle full load.")
        
        return final_sql, load_type
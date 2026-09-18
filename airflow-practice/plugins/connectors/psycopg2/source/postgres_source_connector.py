from connectors.psycopg2.psycopg2_source_connector import Psycopg2SourceConnector
from hooks.psycopg2.psycopg2_postgres_hook import Psycopg2PostgresHook

class PostgresSourceConnector(Psycopg2SourceConnector):
    """
    Source connector for the Airflow Metadata DB (Postgres).
    """
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

    def __enter__(self):
        """
        Establish connection to the Metadata DB.
        """
        hook = Psycopg2PostgresHook(conn_id=self.connection_id)
        self.conn = hook.get_conn()
        self.cursor = self.conn.cursor()
        return self

    def _build_query(self, context: dict) -> tuple[str, str]:
        """
        Builds the SQL for table extraction.
        Uses inherited delta logic to pull only new records since the last run.
        """
        final_sql = self.sql.strip()
        load_type = 'fullload'

        if self.query_mode == 'delta':
            last_val = self._get_last_checkpoint(context)
            
            if last_val:
                self.log.info(f"Metadata Delta: Resuming from {last_val}")
                load_type = 'stream'
                # Airflow Postgres uses standard ISO timestamps
                delta_condition = f"{self.delta_column} > '{last_val}'"
                
                if ' where ' in final_sql.lower():
                    final_sql = f"{final_sql} AND {delta_condition}"
                else:
                    final_sql = f"{final_sql} WHERE {delta_condition}"
        
        return final_sql, load_type
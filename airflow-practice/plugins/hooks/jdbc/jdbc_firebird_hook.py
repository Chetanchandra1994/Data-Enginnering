from hooks.jdbc.jdbc_base_hook import JdbcBaseHook
import jaydebeapi

class JdbcFirebirdHook(JdbcBaseHook):
    DRIVER_CLASS = "org.firebirdsql.jdbc.FBDriver"
    DRIVER_PATH = "/opt/airflow/drivers/jaybird-5.0.4.java11.jar"

    def __init__(self, conn_id: str, database: str = None, **kwargs):
        super().__init__(conn_id=conn_id, **kwargs)
        self.database = database

    def get_conn(self) -> jaydebeapi.Connection:
        """
        Overrides the base method to disable auto-commit.
        Firebird requires this to keep the ResultSet open for batch fetching.
        """
        conn_metadata = self.get_connection_metadata()
        conn_url = self._get_conn_url(conn_metadata)
        
        self.log.info(f"Connecting to {self.DRIVER_CLASS} at {conn_url}")
        
        # Establish the connection
        conn = jaydebeapi.connect(
            jclassname=self.DRIVER_CLASS,
            url=conn_url,
            driver_args=[conn_metadata.login, conn_metadata.password],
            jars=[self.DRIVER_PATH],
        )

        # CRITICAL: Disable autoCommit to allow stable fetchmany/cursor behavior
        # .jconn access the underlying Java connection object
        conn.jconn.setAutoCommit(False)
        
        return conn

    def _get_conn_url(self, conn) -> str:
        """
        Constructs the Firebird JDBC URL.
        Format: jdbc:firebirdsql://host:port/path/to/db.fdb
        """
        extra = conn.extra_dejson

        role_name = extra.get('role_name')
        database_name = extra.get('database_name')

        return f"jdbc:firebirdsql://{conn.host}/{database_name}?roleName={role_name}"
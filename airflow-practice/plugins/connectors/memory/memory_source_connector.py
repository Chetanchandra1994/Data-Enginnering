from connectors.base_connector import SourceConnector

class MemorySourceConnector(SourceConnector):
    """
    A lightweight child of SourceConnector.
    Injects pre-collected byte chunks into the ExtractionOperator pipeline.
    """
    def __init__(self, data_list: list[bytes], **kwargs):
        super().__init__(conn_id=None, **kwargs)
        self.data_list = data_list
        self._extracted = False

    def __enter__(self):
        return self

    def extract(self, context: dict) -> bool:
        """Standard lifecycle: informs the operator that data is ready."""
        if not self._extracted and self.data_list:
            self._extracted = True
            return True
        return False

    def get_data(self) -> bytes:
        """Joins byte chunks into NDJSON format for downstream targets."""
        return b"\n".join(self.data_list)

    def __exit__(self, exc_type, exc_val, exc_tb): pass
    def close_connection(self): pass
    def on_pipeline_success(self, context): pass
    def on_pipeline_failure(self, error): pass
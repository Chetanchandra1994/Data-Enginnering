import xmltodict
from typing import Any
from connectors.api.api_base_connector import StatefulApiConnector
from hooks.api.soap_oauth2_hook import SoapAuthHook

class SoapSourceConnector(StatefulApiConnector):
    """Connector for extracting data from SOAP APIs."""

    def __init__(self, conn_id, soap_method_name, record_path, soap_method_kwargs=None, **kwargs):
        super().__init__(conn_id, **kwargs)
        self.soap_method_name = soap_method_name
        self.record_path = record_path
        self.soap_method_kwargs = soap_method_kwargs or {}

    def __enter__(self):
        self.hook = SoapAuthHook(conn_id=self.connection_id, **self.kwargs)
        self.client = self.hook.get_conn()
        return self

    def _execute_api_call(self, context: dict) -> Any:
        """Executes the SOAP method and returns a parsed dictionary."""
        resolved_kwargs = self._resolve_xcom_args(self.soap_method_kwargs, context)
        method = getattr(self.client.service, self.soap_method_name)
        response_xml = method(**resolved_kwargs)
        
        # Standardize the output format for the metadata processor
        parsed_dict = xmltodict.parse(response_xml)
        return {"records": self._find_records(parsed_dict, self.record_path)}

    def _find_records(self, data: dict, path: str) -> list:
        keys = path.split('.')
        for key in keys:
            data = data.get(key, {}) if isinstance(data, dict) else {}
        return data if isinstance(data, list) else [data] if data else []
from __future__ import annotations

from typing import Any

from hooks.base_hook import BaseHook
from airflow.exceptions import AirflowException

# All SOAP/Zeep imports are now in the hook
from zeep import Client
from zeep.wsse.username import UsernameToken
from zeep.exceptions import Fault as ZeepFault
from requests.auth import HTTPBasicAuth
from zeep.transports import Transport
from requests import Session

class SoapAuthHook(BaseHook):
    def __init__(self, conn_id: str = 'soap_default', auth_method: str = 'wsse', **kwargs):
        super().__init__(conn_id=conn_id, **kwargs)
        self.auth_method = auth_method
        self.client: Client | None = None

    def _get_client(self, wsdl_url: str, username: str, password: str) -> Client:
        """
        Builds the Zeep client with specified credentials and WSDL.
        """
        if self.auth_method in ('wsse', 'wsse_text'):
            self.log.info(f"Initializing Zeep client with WSSecurity (UsernameToken, PasswordText) via auth_method: '{self.auth_method}'")
            return Client(wsdl=wsdl_url, wsse=UsernameToken(username, password))
        
        elif self.auth_method == 'basic':
            self.log.info("Initializing Zeep client with HTTP Basic Auth")
            session = Session()
            session.auth = HTTPBasicAuth(username, password)
            transport = Transport(session=session)
            return Client(wsdl=wsdl_url, transport=transport)
        
        else:
            raise ValueError(f"Invalid auth_method: {self.auth_method}.")

    def get_conn(self) -> Client:
        if self.client:
            return self.client

        conn = self.get_connection_metadata()
        extra = conn.extra_dejson
        
        wsdl_url = extra.get("wsdl_url")
        if not wsdl_url:
            raise ValueError(f"Missing 'wsdl_url' in extra for connection {self.conn_id}")

        self.client = self._get_client(wsdl_url, conn.login, conn.password)
        return self.client

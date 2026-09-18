import re
import orjson
import logging
from typing import Any, Dict, List
from abc import abstractmethod
from airflow.exceptions import AirflowSkipException
from connectors.base_connector import SourceConnector

class ApiBaseConnector(SourceConnector):
    """
    Standardized base for all API-based connectors.
    Enforces a strict extraction lifecycle: Execute -> Skip Check -> Parse -> Process.
    """
    NEWLINE_REGEX = re.compile(r'[\r\n\t]+')

    def __init__(
        self, 
        conn_id: str, 
        skip_if_empty: bool = False, 
        empty_check_key: str | None = None,
        **kwargs
    ):
        super().__init__(conn_id, **kwargs)
        self.skip_if_empty = skip_if_empty
        self.empty_check_key = empty_check_key
        self._has_run = False
        self.log = logging.getLogger(self.__class__.__name__)

    @abstractmethod
    def _execute_api_call(self, context: dict) -> Any:
        """
        Leaf connectors MUST implement this. 
        Focus only on the Hook call and returning raw data.
        """
        pass

    def _parse_api_response(self, raw_result: Any) -> Any:
        """
        Optional: Override if specific extraction from a wrapper 
        (like 'Document.Records') is needed before processing.
        """
        return raw_result

    def extract(self, context: dict) -> bool:
        """
        The 'Master' lifecycle method. Ensures consistency across all APIs.
        """
        if self._has_run:
            return False

        # 1. Execute the actual call (Implemented by Leaf)
        raw_result = self._execute_api_call(context)

        # 2. Validation & Skip Logic
        if self._should_skip(raw_result):
            return False

        # 3. Parsing (Extends the raw result if necessary)
        parsed_data = self._parse_api_response(raw_result)
        
        # 4. Processing: Sanitization, Serialization, and Metadata
        self.extracted_data = self._process_and_track_metadata(parsed_data, context)
        
        self._has_run = True # Lifecycle protection
        return True

    def _process_and_track_metadata(self, data: Any, context: dict) -> List[bytes]:
        """
        Stateless version of processing. 
        Overridden by StatefulApiConnector to add XCom most recent record values.
        """
        sanitized = self._deep_sanitize(data)
        
        # Consistent logging for all API connectors
        record_count = self._count_records(sanitized)
        self.log.info(f"Retrieved {record_count} records from {self.__class__.__name__}.")
            
        return self._serialize(sanitized, context=context)

    def _count_records(self, data: Any) -> int:
        """Helper to find record count for standardized logging."""
        if isinstance(data, list):
            return len(data)
        if isinstance(data, dict):
            # Check for explicit key or find first list
            if "records" in data:
                return len(data["records"])
            for val in data.values():
                if isinstance(val, list):
                    return len(val)
        return 0 if data is None else 1

    def _should_skip(self, result: Any) -> bool:
        """Logic to determine if execution should halt due to empty data."""
        is_empty = False
        if result is None:
            is_empty = True
        elif isinstance(result, dict) and self.empty_check_key:
            is_empty = not result.get(self.empty_check_key)
        else:
            is_empty = not result

        if is_empty:
            self.log.info(f"No data retrieved from {self.__class__.__name__}. Skipping.")
            return True
        return False

    def _deep_sanitize(self, obj: Any) -> Any:
        """Recursively cleans strings of newlines and tabs."""
        # If the object is a list, recursively sanitize each element.
        if isinstance(obj, list):
            return [self._deep_sanitize(i) for i in obj]
        # If the object is a dictionary, sanitize keys and recursively sanitize values.
        elif isinstance(obj, dict):
            return {
                k.replace("-", "_") if isinstance(k, str) else k: self._deep_sanitize(v)
                for k, v in obj.items()
            }
        # Finally, once all recursive objects are sanitized, the string values are sanitized by removing newline and tab characters.
        elif isinstance(obj, str):
            return self.NEWLINE_REGEX.sub(' ', obj)
        return obj

class StatefulApiConnector(ApiBaseConnector):
    """
    Extends API logic to support incremental loads via XCom state tracking.
    """
    def __init__(
        self, 
        conn_id: str, 
        xcom_key: str | None = None, 
        delta_column: str | None = None, 
        query_mode: str = 'delta',
        **kwargs
    ):
        """
        Initialize with XCom tracking fields.
        xcom_key: The key in the JSON response to track (e.g., 'LastModifiedDate').
        delta_column: The XCom key name to save the value under.
        """
        super().__init__(conn_id, **kwargs)
        self.xcom_key = xcom_key
        self.delta_column = delta_column
        self.query_mode = query_mode
        self._current_max_value = None

    def _process_and_track_metadata(self, data: Any, context: dict) -> List[bytes]:
        """
        Refined lifecycle: Standard Processing -> State Tracking.
        """
        # 1. Use Parent for deep sanitization, record logging, and serialization
        serialized_batch = super()._process_and_track_metadata(data, context)
        # 2. Add State Tracking logic
        if self.xcom_key and self.delta_column:
            self._handle_xcom_metadata(data, context)
        return serialized_batch

    def _handle_xcom_metadata(self, data: Any, context: dict):
        """
        Logic to find records and track the most recent record value.
        """        
        records = []
        if isinstance(data, list):
            records = data
        elif isinstance(data, dict):
            if "records" in data:
                records = data["records"]
            else:
                for val in data.values():
                    if isinstance(val, list):
                        records = val
                        break
        
        if not records and data:
            records = [data]

        for item in records:            
            if isinstance(item, dict) and self.delta_column in item:
                current = item.get(self.delta_column)
                if self._current_max_value is None or (current is not None and current > self._current_max_value):
                    self._current_max_value = current
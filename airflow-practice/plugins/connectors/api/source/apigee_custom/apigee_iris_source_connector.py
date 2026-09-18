import xmltodict
from typing import Any
import orjson
from datetime import datetime
from connectors.api.source.apigee_source_connector import ApigeeSourceConnector
from decimal import Decimal, ROUND_HALF_UP
import re

DATE_PATTERN = re.compile(r'^\d{2}/(\d{2}/)?\d{4}( \d{2}:\d{2}(:\d{2})?)?$')

class ApigeeIrisSourceConnector(ApigeeSourceConnector):
    """
    Specialized Iris connector utilizing the API lifecycle hook.
    """

    def __init__(self, record_path="Document.Record", **kwargs):
        kwargs.setdefault('skip_if_empty', True)
        super().__init__(**kwargs)
        self.record_path = record_path

    def _find_records(self, data: dict, path: str) -> list:
        """Helper to traverse the nested dictionary using a dot-notation path."""
        current = data
        for key in path.split('.'):
            if isinstance(current, dict):
                current = current.get(key, {})
            else:
                return []
        
        if isinstance(current, list):
            return current
        return [current] if current and current != {} else []

    def _parse_api_response(self, raw_result: Any) -> list[dict]:
        """
        Specialized logic to peel IRIS SOAP layers.
        Integrated into ApiBaseConnector lifecycle.
        """
        if not (isinstance(raw_result, str) and raw_result.strip().startswith('<')):
            return []

        try:
            data = xmltodict.parse(raw_result)
            env = next((v for k, v in data.items() if 'Envelope' in k), data)
            body = next((v for k, v in env.items() if 'Body' in k), env)
            wrapper = next((v for k, v in body.items() if not k.startswith('@')), {})
            raw_data = wrapper.get('Data') or wrapper.get('ExportDataResult', '')

            inner_str = raw_data.get('#text', '') if isinstance(raw_data, dict) else raw_data

            if isinstance(inner_str, str) and inner_str.strip().startswith('<'):
                parsed_inner = xmltodict.parse(inner_str)
                records = self._find_records(parsed_inner, self.record_path)
                return [self._sanitize_record(rec) for rec in records]
        except Exception as e:
            self.log.warning(f"IRIS parsing failed: {e}")
            
        return []

    def _sanitize_record(self, record: dict) -> dict:
        """Recursively fix dates (US/Euro), Numbers, and lists."""
        for key, value in list(record.items()):
            # 1. Handle Lists (Flatten to String)
            if isinstance(value, list):
                record[key] = ",".join([str(i) for i in value if i is not None])
                continue

            # 2. Handle Nested Dicts
            if isinstance(value, dict):
                self._sanitize_record(value)
                continue

            # 3. Skip non-strings
            if not isinstance(value, str):
                continue

            # 4. Handle Dates (Now with US/Euro Fallback)
            if DATE_PATTERN.match(value):
                try:
                    # Case A: MM/YYYY (Monthly Sheets shorthand)
                    if len(value) == 7 and '/' in value:
                        dt_obj = datetime.strptime(value, '%m/%Y')
                        record[key] = dt_obj.strftime('%Y-%m-%d')
                    
                    # Case B & C: Full Dates/Timestamps
                    else:
                        has_time = ' ' in value
                        # Build the base pattern dynamically based on presence of time/seconds
                        base_fmt = '%m/%d/%Y'
                        if has_time:
                            base_fmt += ' %H:%M'
                            if value.count(':') == 2: base_fmt += ':%S'
                        
                        try:
                            # Attempt US Format (MM/DD/YYYY)
                            dt_obj = datetime.strptime(value, base_fmt)
                        except ValueError:
                            # FALLBACK: Attempt Euro Format (DD/MM/YYYY)
                            euro_fmt = base_fmt.replace('%m/%d', '%d/%m')
                            dt_obj = datetime.strptime(value, euro_fmt)
                        
                        # Output for BigQuery
                        if has_time:
                            record[key] = dt_obj.strftime('%Y-%m-%d %H:%M:%S')
                        else:
                            record[key] = dt_obj.strftime('%Y-%m-%d')
                    continue 
                except ValueError:
                    pass

            # 5. Handle Numeric Comma + BQ Rounding
            if re.match(r'^-?\d+[.,]\d+$', value):
                try:
                    clean_val = value.replace(',', '.')
                    dec_val = Decimal(clean_val).quantize(
                        Decimal('1.00'), 
                        rounding=ROUND_HALF_UP
                    )
                    record[key] = str(dec_val)
                except:
                    pass 
                
        return record
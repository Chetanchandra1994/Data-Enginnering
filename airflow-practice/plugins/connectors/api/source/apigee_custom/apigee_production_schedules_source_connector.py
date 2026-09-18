import orjson
import pendulum
from typing import Any, List, Dict
from connectors.api.source.apigee_source_connector import ApigeeSourceConnector

class ApigeeProductionSchedulesConnector(ApigeeSourceConnector):
    """
    Specialized connector that flattens responses and validates 
    worker counts against the BigQuery metadata record.
    """

    def __init__(self, bq_metadata: dict, **kwargs):
        super().__init__(**kwargs)
        self.bq_metadata = bq_metadata

    def _parse_api_response(self, raw_result: Any) -> List[Dict]:
        try:
            data = orjson.loads(raw_result) if isinstance(raw_result, (str, bytes)) else raw_result
        except Exception as e:
            self.log.error(f"Failed to decode API JSON response: {e}")
            return []

        # Get expected values from the initial BQ metadata
        expected_assembly = float(self.bq_metadata.get('assembly_workers_number', 0))
        expected_welding = float(self.bq_metadata.get('welding_workers_number', 0))

        flat_records = []
        current_ts = pendulum.now('UTC').to_iso8601_string()
        schedules = data.get("ProductionLineSchedules", [])

        for line in schedules:
            shop_number = line.get("ShopNumber")
            shift_schedules = line.get("ShiftSchedules", [])
            
            for shift in shift_schedules:
                # Extract worker counts from API response
                api_assembly = float(shift.get("AssemblyWorkersNumber", 0))
                api_welding = float(shift.get("WeldingWorkersNumber", 0))

                # Validation: Logic to stop merging if values have changed
                if api_assembly != expected_assembly or api_welding != expected_welding:
                    self.log.info(
                        f"Production plan change detected for Shift {shift.get('WorkingShiftDetailUUID')}. "
                        f"Initial Plan: (A:{expected_assembly}, W:{expected_welding}) | "
                        f"New API Plan: (A:{api_assembly}, W:{api_welding}). "
                        f"Stopping merge to maintain data integrity."
                    )
                    return [] # Returning empty list stops the pipeline for this record

                # If valid, build the flattened record
                flat_records.append({
                    "EntityCode": data.get("EntityCode"),
                    "ScheduleDate": data.get("ScheduleDate"),
                    "ShopNumber": shop_number,
                    "WorkingShiftDetailUUID": shift.get("WorkingShiftDetailUUID"),
                    "ProductionLineSchedules": [line],
                    "ipaas_updated_date": current_ts,
                    "src_system_operation": "Insert"
                })

        return flat_records
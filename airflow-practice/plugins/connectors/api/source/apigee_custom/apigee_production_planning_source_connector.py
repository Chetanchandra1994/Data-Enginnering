import orjson
import pendulum
from typing import Any
from connectors.api.source.apigee_source_connector import ApigeeSourceConnector

class ApigeeProductionPlanningConnector(ApigeeSourceConnector):
    """
    Specialized connector for Production Planning.
    Flattens hierarchical API responses and injects current timestamps.
    """

    def _parse_api_response(self, raw_result: Any) -> list[dict]:
        triggerer_data = getattr(self, 'triggerer_data', {})
        if not triggerer_data:
            self.log.error("triggerer_data is missing! REQUIRED fields for BQ will be NULL.")
    
        try:
            data = orjson.loads(raw_result) if isinstance(raw_result, (str, bytes)) else raw_result
        except Exception as e:
            self.log.error(f"Failed to parse API response: {e}")
            return []
        
        try:
            # The response from the Apigee API call
            data = orjson.loads(raw_result) if isinstance(raw_result, (str, bytes)) else raw_result
        except Exception as e:
            self.log.error(f"Failed to decode API JSON response: {e}")
            return []

        flat_records = []
        
        # 2. Extract identifiers from RabbitMQ (triggerer_data)
        # We use strict mapping here as you requested
        entity_code = str(triggerer_data.get("EntityCode", "")).upper()
        punch_in = triggerer_data.get("PunchInDatetime")
        machine_uuid = triggerer_data.get("ProdctMachnUuid")
        shift_detail_uuid = triggerer_data.get("WorkingShiftDetailUuid")
        shop_number = triggerer_data.get("ShopNo")
        
        current_ts = pendulum.now('UTC').to_iso8601_string()

        # Iterate through the API response schedules
        schedules = data.get("ProductionLineSchedules", [])
        self.log.info(f"API returned {len(schedules)} ProductionLineSchedules.")

        for line in schedules:
            shop_name = line.get("ShopName")
            shift_schedules = line.get("ShiftSchedules", [])

            for shift in shift_schedules:
                # Construct the WorkingShift STRUCT
                working_shift = {
                    "Name": shift.get("WorkingShiftName"),
                    "StartDateTime": shift.get("ShiftStartDateTime"),
                    "EndDateTime": shift.get("ShiftEndDateTime"),
                    "HasTransactions": shift.get("ShiftHasTransactions"),
                    "PayrollCode": shift.get("PayrollWorkingShiftCode"),
                    "AssemblyWorkersNumber": float(shift.get("AssemblyWorkersNumber", 0)),
                    "WeldingWorkersNumber": float(shift.get("WeldingWorkersNumber", 0)),
                    "PaintingWorkersNumber": float(shift.get("PaintingWorkersNumber", 0))
                }

                # Construct the Schedule STRUCT
                requisitions = shift.get("Requisitions", [])
                requisitions_list = []
                for req in requisitions:
                    requisitions_list.append({
                        "RequisitionNumber": req.get("RequisitionNumber"),
                        "Status": req.get("RequisitionStatus"),
                        "OrderWithinShift": req.get("OrderWithinShift"),
                        "PlannedStartDateTime": req.get("PlannedStartDateTime"),
                        "PlannedEndDateTime": req.get("PlannedEndDateTime"),
                        "ProductNumber": req.get("ProductNumber"),
                        "ProjectNumber": req.get("ProjectNumber"),
                        "SalesGroupNumber": str(req.get("SalesGroupNumber")),
                        "Marks": req.get("Marks", []) 
                    })

                schedule = {"Requisitions": requisitions_list}

                # Final record assembly
                record = {
                    "ipaas_updated_date": current_ts,
                    "EntityCode": entity_code,
                    "ShopNumber": shop_number,
                    "WorkingShiftDetailUuid": shift_detail_uuid,
                    "ProdctMachnUuid": machine_uuid,
                    "PunchInDatetime": punch_in,
                    "ShopName": shop_name,
                    "WorkingShift": working_shift,
                    "Schedule": schedule
                }
                
                flat_records.append(record)

        # 4. Final Summary Log
        self.log.info(f"Flattening complete. Generated {len(flat_records)} records for BQ.")
        return flat_records
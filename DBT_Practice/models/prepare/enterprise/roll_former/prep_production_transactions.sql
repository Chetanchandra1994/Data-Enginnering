{{
  config(
    materialized = "view",
    alias = "production_transactions",
    schema='roll_former'
  )
}}

SELECT
 DATA:"Transaction_Id" AS TRANSACTION_ID
,DATA:"Entity_Code" AS ENTITY_CODE
,DATA:"Equipment_Name" AS EQUIPMENT_NAME
,DATA:"Start_Time" AS START_TIME
,DATA:"End_Time" AS END_TIME
,DATA:"Required_Global_Item_UUID" AS REQUIRED_GLOBAL_ITEM_UUID
,DATA:"Required_Steel_Grade_UUID" AS REQUIRED_STEEL_GRADE_UUID
,DATA:"Required_Sort_Item_Code" AS REQUIRED_SORT_ITEM_CODE
,DATA:"Used_Sort_Item_Code" AS USED_SORT_ITEM_CODE
,DATA:"Used_Slitted_Coil_Number" AS USED_SLITTED_COIL_NUMBER
,DATA:"Quantity_Done" AS QUANTITY_DONE
,DATA:"Request_Length" AS REQUEST_LENGTH
,DATA:"Used_Length" AS USED_LENGTH
,DATA:"Substitution_Reason_Code" AS SUBSTITUTION_REASON_CODE
,DATA:"Required_Item_Code" AS REQUIRED_ITEM_CODE
,DATA:"Substitution_Reason_Description_French" AS SUBSTITUTION_REASON_DESCRIPTION_FRENCH
,DATA:"Substitution_Reason_Description_English" AS SUBSTITUTION_REASON_DESCRIPTION_ENGLISH
,DATA:"Requisition_Number" AS REQUISITION_NUMBER
,DATA:"Product_No" AS PRODUCT_NO
,DATA:"Mark" AS MARK
,DATA:"Component_Type" AS COMPONENT_TYPE
,DATA:"Operator_Name" AS OPERATOR_NAME
,DATA:"Event_By" AS EVENT_BY
,DATA:"Event_Date" AS EVENT_DATE
,DATA:"Event_Type" AS EVENT_TYPE
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
from {{ source("landing_roll_former", "PRODUCTION_TRANSACTIONS") }}
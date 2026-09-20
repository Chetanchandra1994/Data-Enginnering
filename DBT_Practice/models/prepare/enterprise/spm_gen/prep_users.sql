{{
  config(
    materialized = "view",
    alias = "users",
    schema='spm_gen'
  )
}}


SELECT
 DATA:"User_Code" AS USER_CODE
,DATA:"User_Name" AS USER_NAME
,DATA:"site_id" AS SITE_ID
,DATA:"Memo" AS MEMO
,DATA:"Last_In_Date" AS LAST_IN_DATE
,DATA:"Last_In_Hrs" AS LAST_IN_HRS
,DATA:"Last_Out_Date" AS LAST_OUT_DATE
,DATA:"Last_Out_Hrs" AS LAST_OUT_HRS
,DATA:"Lang_Code" AS LANG_CODE
,DATA:"Dir_Out_File" AS DIR_OUT_FILE
,DATA:"inactive" AS INACTIVE
,DATA:"Inactive_User_Code" AS INACTIVE_USER_CODE
,DATA:"Inactive_Date" AS INACTIVE_DATE
,DATA:"mod_out_file" AS MOD_OUT_FILE
,DATA:"Win_Mode" AS WIN_MODE
,DATA:"Pwd_Delay" AS PWD_DELAY
,DATA:"Pwd_Last_Change" AS PWD_LAST_CHANGE
,DATA:"Pwd_expiration_date" AS PWD_EXPIRATION_DATE
,DATA:"Pwd_From_login_hrs" AS PWD_FROM_LOGIN_HRS
,DATA:"Pwd_To_login_hrs" AS PWD_TO_LOGIN_HRS
,DATA:"Pwd_Login_Days_6" AS PWD_LOGIN_DAYS_6
,DATA:"Pwd_Login_Days_5" AS PWD_LOGIN_DAYS_5
,DATA:"Pwd_Login_Days_7" AS PWD_LOGIN_DAYS_7
,DATA:"Pwd_Login_Days_1" AS PWD_LOGIN_DAYS_1
,DATA:"Pwd_Login_Days_2" AS PWD_LOGIN_DAYS_2
,DATA:"Pwd_Login_Days_3" AS PWD_LOGIN_DAYS_3
,DATA:"Pwd_Login_Days_4" AS PWD_LOGIN_DAYS_4
,DATA:"Pwd_Invalid" AS PWD_INVALID
,DATA:"TTY_History_List" AS TTY_HISTORY_LIST
,DATA:"Pwd_History" AS PWD_HISTORY
,DATA:"Pwd_Bypass_Mask" AS PWD_BYPASS_MASK
,DATA:"Pwd_Bypass_Invalid" AS PWD_BYPASS_INVALID
,DATA:"Pwd_Bypass_History" AS PWD_BYPASS_HISTORY
,DATA:"Pwd_Can_Change" AS PWD_CAN_CHANGE
,DATA:"Use_Sys_Out_File_Unix" AS USE_SYS_OUT_FILE_UNIX
,DATA:"Web_Module_ID" AS WEB_MODULE_ID
,DATA:"Win_Env_Id" AS WIN_ENV_ID
,DATA:"Win_Group" AS WIN_GROUP
,DATA:"Win_Group_Sub" AS WIN_GROUP_SUB
,DATA:"Win_Split" AS WIN_SPLIT
,DATA:"Win_State" AS WIN_STATE
,DATA:"Win_X" AS WIN_X
,DATA:"Win_Y" AS WIN_Y
,DATA:"Win_Width" AS WIN_WIDTH
,DATA:"Win_Height" AS WIN_HEIGHT
,DATA:"Win_History" AS WIN_HISTORY
,DATA:"Win_History_List" AS WIN_HISTORY_LIST
,DATA:"Email" AS EMAIL
,DATA:"TTY_Env_Id" AS TTY_ENV_ID
,DATA:"TTY_History" AS TTY_HISTORY
,DATA:"Use_Sys_Out_File" AS USE_SYS_OUT_FILE
,DATA:"Dir_Out_File_Unix" AS DIR_OUT_FILE_UNIX
,DATA:"Mod_Out_File_Unix" AS MOD_OUT_FILE_UNIX
,DATA:"TTY_Printer_ID" AS TTY_PRINTER_ID
,DATA:"TTY_Group" AS TTY_GROUP
,DATA:"TTY_Group_Sub" AS TTY_GROUP_SUB
,DATA:"Win_Scheduled_Reports_Filter" AS WIN_SCHEDULED_REPORTS_FILTER
,DATA:"_rowid" AS ROW_ID
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,FILENAME                            AS METADATA_FILENAME 
,FILE_ROW_NUMBER                     AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                  AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                     AS METADATA_START_SCAN_TIME
,{{ dbt_utils.generate_surrogate_key(['DATA:"User_Code"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP
from {{ source("landing_spm_gen", "USERS") }}
-- to only take the files after the last fullLoad
  WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
    (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_gen", "USERS") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
    )
 
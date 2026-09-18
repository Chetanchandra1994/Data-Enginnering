from airflow import DAG
from datetime import datetime
from operators.extraction import ExtractionOperator
from connectors.jdbc.source.progress_source_connector import ProgressSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
import pendulum

local_tz = pendulum.timezone("America/Toronto")

with DAG(
    dag_id='spm.fullload.users',
    start_date=datetime(2026, 3, 12, tzinfo=local_tz), 
    schedule='0 5 * * *',
    catchup=False,
    tags=["jdbc", "spm", "progress", "gcs", "fullload"],
    max_active_runs=1
) as dag:

    # 1. Define the Source (Progress DB)
    progress_source = ProgressSourceConnector(
        conn_id='gen',
        database='gen',
        sql='SELECT ROWID AS "_rowid","User_Code" AS "User_Code", SUBSTRING(User_Name, 1, 35) AS "User_Name", "site_id" AS "site_id", "Memo" AS "Memo", "Last_In_Date" AS "Last_In_Date", "Last_In_Hrs" AS "Last_In_Hrs", "Last_Out_Date" AS "Last_Out_Date", "Last_Out_Hrs" AS "Last_Out_Hrs", "Lang_Code" AS "Lang_Code", "Dir_Out_File" AS "Dir_Out_File", "inactive" AS "inactive", "Inactive_User_Code" AS "Inactive_User_Code", "Inactive_Date" AS "Inactive_Date", "mod_out_file" AS "mod_out_file", "Win_Mode" AS "Win_Mode", "Pwd_Delay" AS "Pwd_Delay", "Pwd_Last_Change" AS "Pwd_Last_Change", "Pwd_expiration_date" AS "Pwd_expiration_date", "Pwd_From_login_hrs" AS "Pwd_From_login_hrs", "Pwd_To_login_hrs" AS "Pwd_To_login_hrs", "Pwd_Login_Days"[6] AS "Pwd_Login_Days_6", "Pwd_Login_Days"[5] AS "Pwd_Login_Days_5", "Pwd_Login_Days"[7] AS "Pwd_Login_Days_7", "Pwd_Login_Days"[1] AS "Pwd_Login_Days_1", "Pwd_Login_Days"[2] AS "Pwd_Login_Days_2", "Pwd_Login_Days"[3] AS "Pwd_Login_Days_3", "Pwd_Login_Days"[4] AS "Pwd_Login_Days_4", "Pwd_Invalid" AS "Pwd_Invalid", "TTY_History_List" AS "TTY_History_List", "Pwd_History" AS "Pwd_History", "Pwd_Bypass_Mask" AS "Pwd_Bypass_Mask", "Pwd_Bypass_Invalid" AS "Pwd_Bypass_Invalid", "Pwd_Bypass_History" AS "Pwd_Bypass_History", "Pwd_Can_Change" AS "Pwd_Can_Change", "Use_Sys_Out_File_Unix" AS "Use_Sys_Out_File_Unix", "Web_Module_ID" AS "Web_Module_ID", "Win_Env_Id" AS "Win_Env_Id", "Win_Group" AS "Win_Group", "Win_Group_Sub" AS "Win_Group_Sub", "Win_Split" AS "Win_Split", "Win_State" AS "Win_State", "Win_X" AS "Win_X", "Win_Y" AS "Win_Y", "Win_Width" AS "Win_Width", "Win_Height" AS "Win_Height", "Win_History" AS "Win_History", "Win_History_List" AS "Win_History_List", "Email" AS "Email", "TTY_Env_Id" AS "TTY_Env_Id", "TTY_History" AS "TTY_History", "Use_Sys_Out_File" AS "Use_Sys_Out_File", "Dir_Out_File_Unix" AS "Dir_Out_File_Unix", "Mod_Out_File_Unix" AS "Mod_Out_File_Unix", "TTY_Printer_ID" AS "TTY_Printer_ID", "TTY_Group" AS "TTY_Group", "TTY_Group_Sub" AS "TTY_Group_Sub", "Win_Scheduled_Reports_Filter" AS "Win_Scheduled_Reports_Filter" FROM PUB."users"',
        query_mode='default'
    )

    # 2. Define the Target (GCS)
    gcs_target = GCSTargetConnector(
        conn_id='gcs-bucket-project',
        table_name='users',
        gcs_path='raw/SPM_GEN'
    )

    # 3. Use the Operator to run the task
    extract_data = ExtractionOperator(
        task_id='extract_users',
        source=progress_source,
        targets=[gcs_target]
    )
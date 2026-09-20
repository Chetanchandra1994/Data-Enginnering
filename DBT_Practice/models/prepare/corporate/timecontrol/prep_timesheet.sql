{{
  config(
    materialized = "view",
    alias = "TIMESHEET",
    schema='TIMECONTROL',
    tags=["employee_timesheet_control"]
  )
}}

SELECT
U.value:PSH_KEY::integer as psh_key,
U.value:PSL_KEY::integer as psl_key,
U.value:PSD_KEY::integer as psd_key,
NULLIF(TRIM(U.value:emp_code::string),'NaN') as emp_code,
INITCAP(NULLIF(TRIM(U.value:emp_first::string),'NaN')) as emp_first,
INITCAP(NULLIF(TRIM(U.value:emp_last::string),'NaN')) as emp_last,
INITCAP(NULLIF(TRIM(U.value:emp_name::string),'NaN')) as emp_name,
NULLIF(TRIM(U.value:emp_fld1::string),'NaN') as emp_fld1,
NULLIF(TRIM(U.value:emp_fld2::double),'NaN') as emp_fld2,
NULLIF(TRIM(U.value:emp_fld3::string),'NaN') as emp_fld3,
NULLIF(TRIM(U.value:emp_fld4::string),'NaN') as emp_fld4,
NULLIF(TRIM(U.value:emp_fld5::string),'NaN') as emp_fld5,
NULLIF(TRIM(U.value:emp_fld6::string),'NaN') as emp_fld6,
NULLIF(TRIM(U.value:emp_fld7::string),'NaN') as emp_fld7,
NULLIF(TRIM(U.value:emp_fld8::string),'NaN') as emp_fld8,
NULLIF(TRIM(U.value:emp_fld9::string),'NaN') as emp_fld9,
NULLIF(TRIM(U.value:emp_fld10::string),'NaN') as emp_fld10,
NULLIF(TRIM(U.value:emp_fld11::string),'NaN') as emp_fld11,
NULLIF(TRIM(U.value:emp_fld12::string),'NaN') as emp_fld12,
NULLIF(TRIM(U.value:emp_fld15::string),'NaN') as emp_fld15,
TO_TIMESTAMP(U.value:psh_tstmp::string, 'YYYYMMDDHH24MI') as psh_tstmp,
TO_DATE(U.value:Psh_psdate::string,'YYYYMMDD') as psh_psdate,
TO_DATE(U.value:Psh_pedate::string,'YYYYMMDD') as psh_pedate,
TO_DATE(U.value:Psd_date::string,'YYYYMMDD') as psd_date,
TO_DATE(U.value:psd_wedate::string,'YYYYMMDD') as psd_wedate,
TO_TIMESTAMP(U.value:psl_tstmp::string,'YYYYMMDDHH24MI') as psl_tstmp,
NULLIF(TRIM(U.value:psl_fld1::string),'NaN') as psl_fld1,
NULLIF(TRIM(U.value:psl_fld2::string),'NaN') as psl_fld2,
NULLIF(TRIM(U.value:psl_fld3::string),'NaN') as psl_fld3,
NULLIF(TRIM(U.value:prj_name::string),'NaN') as prj_name,
NULLIF(TRIM(U.value:PRJ_DESC::string),'NaN') as prj_desc,
NULLIF(TRIM(U.value:CAC_DESC::string),'NaN') as cac_desc,
NULLIF(TRIM(U.value:prj_fld2::string),'NaN') as prj_fld2,
NULLIF(TRIM(U.value:prj_fld5::string),'NaN') as prj_fld5,
NULLIF(TRIM(U.value:prj_fld6::string),'NaN') as prj_fld6,
NULLIF(TRIM(U.value:chh_code::string),'NaN') as chh_code,
NULLIF(TRIM(U.value:chh_desc::string),'NaN') as chh_desc,
NULLIF(TRIM(U.value:chh_fld3::string),'NaN') as chh_fld3,
NULLIF(TRIM(U.value:PSL_RAT_CD::string),'NaN') as psl_rat_cd,
IFNULL(U.value:Hours::double,0) as hours,
IFNULL(U.value:PSD_SUNDAY::double,0) as psd_sunday,
IFNULL(U.value:PSD_MONDAY::double,0) as psd_monday,
IFNULL(U.value:PSD_TUESDAY::double,0) as psd_tuesday,
IFNULL(U.value:PSD_WEDNESDAY::double,0) as psd_wednesday,
IFNULL(U.value:PSD_THURSDAY::double,0) as psd_thursday,
IFNULL(U.value:PSD_FRIDAY::double,0) as psd_firday,
IFNULL(U.value:PSD_SATURDAY::double,0) as psd_saturday,
FILENAME                                as metadata_filename,
FILE_ROW_NUMBER                         as metadata_file_row_number,
FILE_LAST_MODIFIED                      as metadata_file_last_modified,
START_SCAN_TIME                         as metatada_start_scan_time
FROM 
    {{ source("landing_timecontrol", "TIMESHEET") }} T,
    LATERAL FLATTEN(INPUT => T.DATA:data, OUTER => TRUE) U
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_timecontrol", "TIMESHEET") }} T
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )
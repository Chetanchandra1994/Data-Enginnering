{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "dim_Sales_Contract",
    schema= "dimensions",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR",
    meta = {
    'table_key': 'SALES_CONTRACT_SK',
    'tests': {
      'unique_sk':{}    
    }
  }
  )
}}

SELECT
	{{ dbt_utils.generate_surrogate_key(['QQ.JOB_NO','QQ.OFFICE_CODE',"'spm'"]) }} AS SALES_CONTRACT_SK,
  QQ.JOB_NO										            AS SALES_CONTRACT_CODE,
	QQ.OFFICE_CODE									        AS SRC_OFFICE_CODE,
	'spm' 											            AS ORIGIN_APPLICATION_CODE,					-- RDM - APPLICATION
	QQ.RDM_SALES_OFFICE_DEPARTMENT_CODE			AS SALES_OFFICE_DEPARTMENT_CODE,			-- RDM - SALES OFFICE DEPARTMENT
	PE.D_OUVERTURE 								          AS SALES_CONTRACT_DATE,
	QQ.RDM_PROJECT_STEP 							      AS SALES_CONTRACT_STATUS_CODE,				-- RDM - PROJECT STEP
	QQ.RDM_ACTIVE_STATUS_CODE						    AS SALES_CONTRACT_ACTIVE_STATUS_CODE		-- RDM - ACTIVE STATUS	
FROM {{ref('norm_qc_quotation')}} QQ
LEFT JOIN {{ref('norm_projet_e')}} PE
ON QQ.NO_PROJET = PE.NO_PROJET
WHERE QQ.PROJCT_STEP BETWEEN 15 AND 95
{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "dim_Sales_Contract_Line",
    schema= "dimensions",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR",
    meta = {
    'table_key': 'SALES_CONTRACT_LINE_SK',
    'tests': {
      'unique_sk':{}    
    }
  }
  )
}}

SELECT 
  {{ dbt_utils.generate_surrogate_key(['QQ.JOB_NO', 'QQ.OFFICE_CODE','QQP.ESTIMT_MODUL','QQP.SEQ_NO',"'spm'"]) }} 			
                                        AS SALES_CONTRACT_LINE_SK, -- SURROGATE KEY
	QQ.JOB_NO										          AS SALES_CONTRACT_CODE,  
	QQ.OFFICE_CODE									      AS SRC_OFFICE_CODE, 
	CONCAT(QQP.ESTIMT_MODUL,'-',QQP.SEQ_NO) 	AS SALES_CONTRACT_LINE_CODE, 
	'spm' 											          AS ORIGIN_APPLICATION_CODE,	-- RDM APPLICATION
  QQ.RDM_SALES_OFFICE_DEPARTMENT_CODE		AS SALES_OFFICE_DEPARTMENT_CODE		-- RDM - SALES OFFICE DEPARTMENT
     
FROM 
    {{ref('norm_qc_quotation')}} QQ
LEFT JOIN 
    {{ref('norm_qc_quotation_product')}} QQP   
    ON QQ.OFFICE_CODE = QQP.OFFICE_CODE AND QQ.JOB_NO = QQP.JOB_NO
WHERE QQ.PROJCT_STEP BETWEEN 15 AND 95
	AND (QQP.ACC_NO <> 0 OR QQP.PRODCT_NO <> 0)
	AND QQP.PRODCT_NO <> 999
	AND UPPER(QQP.SPM_ENTITY_CODE) <> 'BREAK'
	AND (QQP.ESTIMT_MODUL <> 4 OR (QQP.ESTIMT_MODUL = 4 AND QQP.QC_QUOT_PRODUCT_HIERARCHY_UUID IS NOT NULL))
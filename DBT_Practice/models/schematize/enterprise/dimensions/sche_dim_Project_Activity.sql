{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "dim_project_activity",
    schema= "dimensions",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR",
    meta = {
      'table_key': 'PROJECT_ACTIVITY_SK',
      'tests': {
        'unique_sk':{}    
      }
    }
  )
}}



SELECT DISTINCT
	{{dbt_utils.generate_surrogate_key(['PL.ENTITY_CODE','PL.NO_PRODUIT',"'Production'"])}}					AS PROJECT_ACTIVITY_SK,								-- SURROGATE KEY
	CONCAT(PL.ENTITY_CODE,'-',PL.NO_PRODUIT) 					                                               AS PROJECT_ACTIVITY_CODE,
  'Production'											                                                            AS PROJECT_ACTIVITY_TYPE_CODE,
	PS.RDM_ACTIVE_STATUS_CODE									                                                    AS PROJECT_ACTIVITY_ACTIVE_STATUS_CODE
FROM {{ref('norm_projet_l')}} PL
	LEFT JOIN {{ref('norm_produit_s')}} PS ON PL.NO_PRODUIT = PS.NO_PRODUIT AND PL.ENTITY_CODE = PS.ENTITY_CODE
UNION ALL
SELECT DISTINCT
	{{dbt_utils.generate_surrogate_key(['ET.ENTITY_CODE','ET.LINE_NO',"'Services'"])}} 						AS PROJECT_ACTIVITY_SK,
	CONCAT(ET.ENTITY_CODE,'-',ET.LINE_NO) 						                                      AS PROJECT_ACTIVITY_CODE,
  'Services'												                                                  AS PROJECT_ACTIVITY_TYPE_CODE,
	EL.RDM_ACTIVE_STATUS_CODE									                                          AS PROJECT_ACTIVITY_ACTIVE_STATUS_CODE
FROM {{ref('norm_ess_trans')}} ET 
	LEFT JOIN {{ref('norm_ess_line')}} EL ON ET.LINE_NO = EL.LINE_NO AND ET.ENTITY_CODE = EL.ENTITY_CODE
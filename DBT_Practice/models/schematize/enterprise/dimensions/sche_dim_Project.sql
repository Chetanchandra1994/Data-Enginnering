{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "dim_project",
    schema= "dimensions",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR",
    meta = {
    'table_key': 'PROJECT_SK',
    'tests': {
      'unique_sk':{}    
    }
  }    
  )
}}

SELECT 
  {{ dbt_utils.generate_surrogate_key(['PG.NO_PROJET', 'COD.RDM_FINANCIAL_COMPANY_CODE']) }} AS PROJECT_SK,        -- SURROGATE KEY
  PG.NO_PROJET                                                                               AS PROJECT_CODE,
  COD.RDM_FINANCIAL_COMPANY_CODE                                                             AS FINANCIAL_COMPANY_CODE,        -- RDM - FINANCIAL COMPANY
  BU.BUSINESS_UNIT_CODE                                                                      AS BUSINESS_UNIT_CODE,
  P.PROJECT_CURRENCY_CODE                                                                    AS PROJECT_CURRENCY_CODE,         -- RDM - CURRENCY
  P.EXCHGN_RATE                                                                              AS PROJECT_CURRENCY_RATE,
  PE.D_OUVERTURE                                                                             AS PROJECT_START_DATE,
  CDPE.PROJECT_CLOSE_DATE                                                                    AS PROJECT_CLOSE_DATE, 
  PG.NOM_PROJET_L                                                                            AS PROJECT_NAME_FR,
  PG.NOM_PROJET_L                                                                            AS PROJECT_NAME_EN,
  CDPE.PROJECT_STATUS_CODE								                                                   AS PROJECT_STATUS_CODE,					-- RDM - PROJECT STATUS
	CDPE.PROJECT_TYPE										                                                       AS PROJECT_TYPE_CODE,
  CDPE.CLASS_CATEGORY                                                                        AS PROJECT_CLASS_CATEGORY_NAME,
  CDPE.CLASS_CODE                                                                            AS PROJECT_CLASS_NAME,
  CASE WHEN P.PACKAGE = 1 THEN 'IsAPackage'
		WHEN P.PACKAGE = 0 THEN 'NotAPackage'
		ELSE NULL	END 													                                                 AS PROJECT_PACKAGE_STATUS_CODE,			-- RDM - PROJECT PACKAGE STATUS
  CASE 
    WHEN P.ERECTOR_PRIVILEGE_INCLUDED = 1 THEN 'BuildMaster'
    WHEN P.ERECTOR_PRIVILEGE_INCLUDED = 0 THEN 'NonBuildMaster'
    ELSE NULL 
  END                                                                                        AS PROJECT_BUILD_MASTER_STATUS_CODE, 
  CDPE.PROJECT_MANAGER                                                                       AS PROJECT_MANAGER_FULL_NAME,     
  CDPE.PROJECT_SALESREP                                                                      AS PROJECT_SALESREP_FULL_NAME,    
  UPPER(CONCAT(IFNULL(TRIM(PG.ADRESSE_LIV_1),''),' ',
    IFNULL(TRIM(PG.ADRESSE_LIV_2),''),' ',
    IFNULL(TRIM(PG.ADRESSE_LIV_3),'')))                                                      AS PROJECT_SHIPPING_ADDRESS,
  UPPER(PG.CMG_ZIP_CODE)                                                                     AS PROJECT_SHIPPING_POSTAL_CODE,
  UPPER(PG.CMG_CITY)                                                                         AS PROJECT_SHIPPING_CITY_CODE,
  UPPER(PG.CMG_STATE)                                                                        AS PROJECT_SHIPPING_STATE_CODE,
  UPPER(PG.COUNTY_CODE)                                                                      AS PROJECT_SHIPPING_COUNTY_CODE,
  UPPER(PG.CMG_COUNTRY)                                                                      AS PROJECT_SHIPPING_COUNTRY_CODE  
  FROM {{ref('norm_projet_g')}} PG
	LEFT JOIN {{ref('norm_projet_e')}} PE ON PG.NO_PROJET = PE.NO_PROJET
	LEFT JOIN {{ref('norm_business_unit')}} BU ON PG.BUSINESS_UNIT_ID = BU.BUSINESS_UNIT_ID
	LEFT JOIN {{ref('norm_project')}} P ON PG.GDM_PROJECT_ID = P.PROJECT_ID
	LEFT JOIN {{ ref('norm_cmg_dw_projects_etl')}} CDPE ON P.PROJECT_CODE = CDPE.PROJECT_CODE
	CROSS JOIN {{ ref('norm_cmg_outbound_databases')}} COD


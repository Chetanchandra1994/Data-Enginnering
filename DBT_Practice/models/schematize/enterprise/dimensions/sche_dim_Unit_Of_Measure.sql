  {{
    config(
      full_refresh = true,
      materialized="dynamic_table",
      target_lag="downstream",
      snowflake_warehouse= var('task_warehouse'),
      alias = "dim_Unit_Of_Measure",
      schema= "dimensions",
      post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR",
      meta = {
      'table_key': 'UOM_SK',
      'tests': {
        'unique_sk':{}    
      }
    }
    )
  }}

  SELECT
    {{dbt_utils.generate_surrogate_key(['UOM_CODE']) }} 	:: VARCHAR(32)		    AS UOM_SK, 					-- SURROGATE KEY
    UOM_CODE :: STRING			                                                    AS ORIGIN_UOM_CODE,
    RDM_UOM_CODE :: STRING			                                                AS UOM_CODE,				-- RDM - UNIT OF MEASURE
    RDM_UOM_NAME_FR :: STRING                                                   AS UOM_NAME_FR,
    RDM_UOM_NAME_EN :: STRING                                                   AS UOM_NAME_EN,
    RDM_UOM_TYPE_NAME_FR :: STRING                                              AS UOM_TYPE_NAME_FR,
    RDM_UOM_TYPE_NAME_EN :: STRING                                              AS UOM_TYPE_NAME_EN,
    RDM_UOM_SYSTEM_NAME_FR :: STRING                                            AS UOM_SYSTEM_NAME_FR,
    RDM_UOM_SYSTEM_NAME_EN :: STRING                                            AS UOM_SYSTEM_NAME_EN
  FROM {{ref('norm_uom')}}
  WHERE RDM_UOM_CODE <> 'Not Found'



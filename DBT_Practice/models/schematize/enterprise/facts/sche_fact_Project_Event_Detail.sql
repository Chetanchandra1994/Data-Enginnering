{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "fact_Project_Event_Detail",
    schema= "facts",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"
  )
}}

SELECT 
    {{ dbt_utils.generate_surrogate_key(['GDM_DEP.PROJECT_STEP_CODE','GDM_EV.EVENT_NAME_CODE', 'CA_PROJ_EV.no_projet', 'CA_PROJ_EV.sequence', "'spm'" ]) }} as PROJECT_EVENT_DETAIL_SK
   
    ,GDM_DEP.PROJECT_STEP_CODE AS PROJECT_STEP_CODE
    ,GDM_EV.EVENT_NAME_CODE AS EVENT_NAME_CODE
    ,CA_PROJ_EV.no_projet AS PROJECT_CODE
    ,CA_PROJ_EV.sequence AS PROJECT_EVENT_CODE
    ,'spm' AS EVENT_ORIGIN_APPLICATION_CODE 
    ,DIM_EV_T.EVENT_TYPE_SK AS EVENT_TYPE_SK
    ,DIM_PROJ_EV.PROJECT_EVENT_SK AS PROJECT_EVENT_SK
    ,DIM_EMP_1.EMPLOYEE_SK AS SUBMITTED_BY_EMPLOYEE_SK
    ,DIM_EMP_2.EMPLOYEE_SK AS PROJECT_MANAGER_SK
    ,DIM_PROJ.PROJECT_SK AS PROJECT_SK
    ,CA_PROJ_EV_DT.ENTITY_CODE  AS LOCATION_SITE_CODE --RDM TO DO
    ,{{ target.name }}_ENTERPRISE_SCHEMATIZE.PUBLIC.format_date_key(CA_PROJ_EV_DT.CREATION_DATETIME, 'YYYY-MM-DD HH24:MI:SS.FF') AS DETAIL_CREATION_DATE_KEY
    ,CA_PROJ_EV_DT.CREATION_DATETIME AS CREATION_DATETIME 
    ,{{ target.name }}_ENTERPRISE_SCHEMATIZE.PUBLIC.format_date_key(CA_PROJ_EV_DT.CANCELLATION_DATETIME, 'YYYY-MM-DD HH24:MI:SS.FF') AS CANCELLATION_DATE_KEY
    ,CA_PROJ_EV_DT.CANCELLATION_DATETIME AS CANCELLATION_DATETIME 
    ,DC1.CUSTOMER_SK AS PROJECT_CUSTOMER_SK
    ,CASE WHEN CA_PROJ_EV.PAYMENT_TO_VENDOR_CODE IS NOT NULL THEN DPTS.PAYMENT_TO_SK
          WHEN CA_PROJ_EV.PAYMENT_TO_CUSTOMER_UUID IS NOT NULL THEN DPTC.PAYMENT_TO_SK
      END AS PAYMENT_TO_SK     
    ,DCU.CURRENCY_SK AS AMOUNT_CURRENCY_SK
    ,DCU1.CURRENCY_SK AS TO_CURRENCY_CAD_SK
    ,DCU2.CURRENCY_SK AS TO_CURRENCY_USD_SK
    ,CA_PROJ_EV_DT.COST AS ADDITIONAL_COST_AMOUNT
    ,CA_PROJ_EV_DT.provision_amount AS PROVISION_AMOUNT
    ,CA_PROJ_EV_DT.credit_payment_amount AS TRANSACTION_AMOUNT
    

FROM {{ref('norm_project_event')}}  CA_PROJ_EV

LEFT JOIN {{ref('norm_project_event_detail')}} CA_PROJ_EV_DT ON CA_PROJ_EV.project_event_uuid = CA_PROJ_EV_DT.project_event_uuid

LEFT JOIN {{ref('norm_event')}} GDM_EV ON CA_PROJ_EV_DT.event_uuid = GDM_EV.event_uuid

LEFT JOIN {{ref('norm_department')}} GDM_DEP ON GDM_EV.department_uuid = GDM_DEP.department_uuid

LEFT JOIN {{ref('norm_projet_g')}} CA_G ON CA_G.no_projet = CA_PROJ_EV.no_projet
LEFT JOIN {{ref('norm_project')}} GDM_P ON CA_G.gdm_project_id = GDM_P.project_id

LEFT JOIN {{ref('norm_customer')}} CUST ON CA_PROJ_EV.PAYMENT_TO_CUSTOMER_UUID = CUST.CUSTOMER_UUID
                
LEFT JOIN {{ref('norm_vendor')}} VEND ON UPPER(CA_PROJ_EV.PAYMENT_TO_VENDOR_CODE) = UPPER(VEND.VENDOR_CODE)
LEFT JOIN {{ref('sche_bridge_Supplier')}} BR_SUPP ON UPPER(VEND.VENDOR_CODE) = UPPER(BR_SUPP.SPM_CODE)

LEFT JOIN {{ref('sche_dim_Event_Type')}} DIM_EV_T 
                ON DIM_EV_T.PROJECT_STEP_CODE = GDM_DEP.PROJECT_STEP_CODE
               AND DIM_EV_T.event_name_code = GDM_EV.event_name_code
               AND DIM_EV_T.origin_application_code = EVENT_ORIGIN_APPLICATION_CODE

LEFT JOIN {{ref('sche_dim_Project_Event')}} DIM_PROJ_EV 
                ON DIM_PROJ_EV.project_code = CA_PROJ_EV.no_projet 
               AND DIM_PROJ_EV.project_event_code = CA_PROJ_EV.sequence

LEFT JOIN {{ref('sche_dim_Project')}} DIM_PROJ 
                ON DIM_PROJ.project_code = CA_PROJ_EV.no_projet

LEFT JOIN {{ref("norm_people")}} PEOPLE_1 
            ON NULLIF(CA_PROJ_EV.submitted_by_people_id, 0) = PEOPLE_1.people_id
            
LEFT JOIN {{ref('sche_dim_Employee')}} DIM_EMP_1
            ON lower(SPLIT_PART(PEOPLE_1.email, '@', 1))= lower(SPLIT_PART(dim_emp_1.professional_email, '@', 1))
            
LEFT JOIN {{ref("norm_people")}}  PEOPLE_2 
            ON PEOPLE_2.code = ca_g.manager
            
LEFT JOIN {{ref('sche_dim_Employee')}} DIM_EMP_2
            ON lower(SPLIT_PART(PEOPLE_2.email, '@', 1))= lower(SPLIT_PART(dim_emp_2.professional_email, '@', 1))      
LEFT JOIN {{ref('sche_dim_Customer')}} DC1
    ON UPPER(CA_G.cust_no) = UPPER(DC1.customer_code)
LEFT JOIN {{ref('sche_dim_Customer')}} DC2
    ON UPPER(CUST.cust_no) = UPPER(DC2.customer_code)
LEFT JOIN {{ref('sche_dim_Payment_To')}} DPTC 
    ON DC2.CUSTOMER_SK = DPTC.CUSTOMER_SK
LEFT JOIN {{ref('sche_dim_Payment_To')}} DPTS
    ON BR_SUPP.SUPPLIER_SK = DPTS.SUPPLIER_SK
LEFT JOIN {{ref('sche_dim_Currency')}} DCU 
    ON GDM_P.PROJECT_CURRENCY_CODE = DCU.CURRENCY_CODE
LEFT JOIN {{ref('sche_dim_Currency')}} DCU1 
    ON DCU1.CURRENCY_CODE = 'CAD'
LEFT JOIN {{ref('sche_dim_Currency')}} DCU2 
    ON DCU2.CURRENCY_CODE = 'USD'



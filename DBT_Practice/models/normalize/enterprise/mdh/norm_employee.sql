{{
  config(
    materialized = "view",
    alias = "employee",
    schema='mdh',
    meta = {
        'table_key': 'MAIN_EMPLOYEE_NUMBER',
        'tests': {
            'null_values':{
                'columns':[
                    'FINANCIAL_COMPANY_CODE',
                    'EMPLOYEE_STATUS'
                ]
            }
        }    
    }
  )
}}

SELECT
  UPPER(a.MAIN_EMPLOYEE_NUMBER::string) AS MAIN_EMPLOYEE_NUMBER,
  b.Standard_Application_Value AS FINANCIAL_COMPANY_CODE,
  a.PROFESSIONAL_EMAIL::string AS PROFESSIONAL_EMAIL,
  a.FIRST_NAME::string AS FIRST_NAME,
  a.LAST_NAME::string AS LAST_NAME,
  c.Standard_Application_Value as EMPLOYEE_STATUS
FROM {{ref('prep_employee')}} a
LEFT JOIN
    {{ref('gov_referencedata_rdm')}} b ON b.Business_Application_Code = 'mdh-employee'
    AND b.Business_Application_Domain_Code = 'FinancialCompany'
    AND b.Business_Application_Value = UPPER(a.MAIN_LEGAL_ENTITY::string)
LEFT JOIN
    {{ref('gov_referencedata_rdm')}} c ON c.Business_Application_Code = 'mdh-employee'
    AND c.Business_Application_Domain_Code = 'PersonnelStatus'
    AND INITCAP(c.Business_Application_Value) = INITCAP(a.STATUS::string)

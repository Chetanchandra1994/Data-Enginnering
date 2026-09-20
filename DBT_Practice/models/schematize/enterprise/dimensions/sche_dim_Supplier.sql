{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "dim_supplier",
    schema= "dimensions",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"
  )
}}

SELECT
    {{ dbt_utils.generate_surrogate_key(['a.SUPPLIERCODE']) }} AS Supplier_SK
    , a.SUPPLIERCODE AS Supplier_Number
    , a.SUPPLIERTYPECODE AS Supplier_Type_Code
    , a.SUPPLIER_NAME AS Supplier_Name
    , a.COMPANYCODE AS Company_Code
    , a.NATUREOFSUPPLYCODE AS Nature_of_Supply_Code
    , b.STANDARD_APPLICATION_VALUE_NAME_EN AS Nature_of_Supply_Name
    , a.OURCUSTOMERNUMBER AS Our_Customer_Number
    , a.SOURCESYSTEM AS Source_System
    , a.SUPPLIERSTATUSCODE AS Supplier_Status_Code
    , a.LOCATIONS_ARRAY[0].Country::STRING AS Country
    , a.LOCATIONS_ARRAY[0].AdministrativeArea::STRING AS Administrative_Area
    , a.LOCATIONS_ARRAY[0].Locality::STRING AS Locality
    , a.LOCATIONS_ARRAY[0].Route::STRING AS Route
    , a.LOCATIONS_ARRAY[0].POBoxNumber::STRING AS PO_Box_Number
    , a.LOCATIONS_ARRAY[0].PostalCode::STRING AS Postal_Code
FROM {{ref('norm_canammodel_suppliers')}} AS a
LEFT JOIN {{ref('gov_referencedata_rdm')}} AS b
    ON a.NatureOfSupplyCode = b.STANDARD_APPLICATION_VALUE
    AND b.BUSINESS_APPLICATION_CODE = 'oracle-ebs'
    AND b.STANDARD_DOMAIN_APPLICATION_CODE = 'NatureOfSupply'
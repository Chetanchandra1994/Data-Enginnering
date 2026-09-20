{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "dim_Invoice_From_Profile",
    schema= "dimensions",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"
  )
}}

with 

raw_data as (

    select 
        SUPPLIERCODE
      , IF_CURRENCYCODE
      , IF_NAME
      , IF_PAYMENTMETHODCODE
      , IF_PAYMENTTERMCODE
      , IFF(SUPPLIERCODE=IF_PROFILECODE, IF_SITECODE, IF_PROFILECODE) as IF_PROFILECODE
      , IF_STATUSCODE
      , IF_LOCATIONS_ARRAY[0].Country::string as IF_Country
      , IF_LOCATIONS_ARRAY[0].AdministrativeArea::string as IF_Administrative_Area
      , IF_LOCATIONS_ARRAY[0].Locality::string as IF_Locality
      , IF_LOCATIONS_ARRAY[0].Route::string as IF_Route
      , IF_LOCATIONS_ARRAY[0].POBoxNumber::string as IF_PO_Box_Number
      , IF_LOCATIONS_ARRAY[0].PostalCode::string as IF_Postal_Code
    from {{ref('norm_enterprisemodel_suppliersInvoiceFromProfiles')}}

)

select 
  {{ dbt_utils.generate_surrogate_key(['SUPPLIERCODE', 'IF_PROFILECODE']) }} as IF_PROFILE_SK
, {{ dbt_utils.generate_surrogate_key(['SUPPLIERCODE']) }} as SUPPLIER_SK
, IF_CURRENCYCODE as IF_Currency_Code
, IF_NAME
, IF_PAYMENTMETHODCODE as IF_Payment_Method_Code
, IF_PAYMENTTERMCODE as IF_Payment_Term_Code
, IF_PROFILECODE as IF_Profile_Code
, IF_STATUSCODE as IF_Status_Code
, IF_Country
, IF_Administrative_Area
, IF_Locality
, IF_Route
, IF_PO_Box_Number
, IF_Postal_Code
from raw_data

{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "dim_Pay_To_Profile",
    schema= "dimensions",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"
  )
}}

with 

raw_data as (

    select 
        SUPPLIERCODE
      , PT_CURRENCYCODE
      , PT_NAME
      , PT_PAYMENTMETHODCODE
      , PT_PAYMENTTERMCODE
      , IFF(SUPPLIERCODE=PT_PROFILECODE, PT_SITECODE, PT_PROFILECODE) as PT_PROFILECODE
      , PT_STATUSCODE
      , PT_LOCATIONS_ARRAY[0].Country::string as PT_Country
      , PT_LOCATIONS_ARRAY[0].AdministrativeArea::string as PT_Administrative_Area
      , PT_LOCATIONS_ARRAY[0].Locality::string as PT_Locality
      , PT_LOCATIONS_ARRAY[0].Route::string as PT_Route
      , PT_LOCATIONS_ARRAY[0].POBoxNumber::string as PT_PO_Box_Number
      , PT_LOCATIONS_ARRAY[0].PostalCode::string as PT_Postal_Code
    from {{ref('norm_enterprisemodel_suppliersPayToProfiles')}}

)

select 
  {{ dbt_utils.generate_surrogate_key(['SUPPLIERCODE', 'PT_PROFILECODE']) }} as PT_PROFILE_SK
, {{ dbt_utils.generate_surrogate_key(['SUPPLIERCODE']) }} as SUPPLIER_SK
, PT_CURRENCYCODE as PT_Currency_Code
, PT_NAME
, PT_PAYMENTMETHODCODE as PT_Payment_Method_Code
, PT_PAYMENTTERMCODE as PT_Payment_Term_Code
, PT_PROFILECODE as PT_Profile_Code
, PT_STATUSCODE as PT_Status_Code
, PT_Country
, PT_Administrative_Area
, PT_Locality
, PT_Route
, PT_PO_Box_Number
, PT_Postal_Code
from raw_data

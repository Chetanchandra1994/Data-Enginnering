{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="1 hour",
    snowflake_warehouse= var('task_warehouse'),
    alias = "steel_receipt_line_details",
    schema= "dataproducts_bronze",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"
  )
}}

SELECT
     RL.po_no as PURCHASE_ORDER_NUMBER
    ,RL.line_no as PURCHASE_ORDER_LINE_NUMBER
    ,RL.receipt_no AS RECEIPT_NO
    ,RL.RCPT_LINE_NO AS RECEIPT_LINE_NO
    ,RL.item_no AS ITEM_NUMBER
    ,WH.CITY AS WAREHOUSE_CITY
    ,RL.receipt_date AS RECEIPT_LINE_DATE
    ,C.name AS STEEL_COUNTRY_OF_ORIGIN
    ,C.nafta AS STEEL_COUNTRY_ORIGIN_IS_CUSMA
    ,RL.DESCRIPTION AS ITEM_DESCRIPTION
    ,RL.VENDOR_CODE AS RECEIPT_LINE_VENDOR_CODE
    ,DS.SUPPLIER_NAME AS SUPPLIER_USUAL_NAME
    ,INITCAP(DN1.NAME) AS RAW_MATERIAL_CATEGORY_NAME
    ,INITCAP(DN2.NAME) AS RAW_MATERIAL_SUBCATEGORY_NAME
    ,INITCAP(SICC.DESCRIPTION) AS STEEL_CATEGORY
    ,SUM(RL.QTY_RECEIVED/2000) as WEIGHT_IN_TONS
FROM 
    {{ref('norm_receipt_line')}}  RL
LEFT JOIN
    {{ref('norm_country')}}  C
ON
    UPPER(RL.country_code) = UPPER(C.country_code)
LEFT JOIN
    {{ref('sche_bridge_Supplier')}} BS
ON
    UPPER(RL.VENDOR_CODE) = UPPER(BS.SPM_CODE)
LEFT JOIN
    {{ref('sche_dim_Supplier')}}  DS
ON
    UPPER(BS.SUPPLIER_SK) = UPPER(DS.SUPPLIER_SK)
LEFT JOIN
    {{ref('norm_item')}}  I
ON
    UPPER(RL.ITEM_NO) = UPPER(I.ITEM_NO)
LEFT JOIN
    {{ref('norm_global_item')}}  GI
ON
    UPPER(I.GLOBAL_ITEM_UUID) = UPPER(GI.GLOBAL_ITEM_UUID)
LEFT JOIN
    {{ref('norm_item_subcategory')}}  ISUB
ON
    UPPER(GI.ITEM_SUBCATEGORY_UUID) = UPPER(ISUB.ITEM_SUBCATEGORY_UUID)
LEFT JOIN
    {{ref('norm_item_category')}}  IC
ON
    UPPER(ISUB.ITEM_CATEGORY_UUID) = UPPER(IC.ITEM_CATEGORY_UUID)
LEFT JOIN
    {{ref('norm_data_name')}}  DN1
ON
    UPPER(IC.ITEM_CATEGORY_NAME_ID) = UPPER(DN1.NAME_ID) AND
    DN1.LANGUAGE_CODE = 1
LEFT JOIN
    {{ref('norm_data_name')}} DN2
ON
    UPPER(ISUB.item_subcategory_name_id) = UPPER(DN2.NAME_ID) AND
    DN2.LANGUAGE_CODE = 1
LEFT JOIN 
    {{ref('norm_warehouse')}} WH
ON
    UPPER(RL.WHS_CODE) = UPPER(WH.whs_code)
LEFT JOIN
    {{ref('norm_dsa_steel_items_categ_custom')}} SICC
ON
    UPPER(SICC.CATEGORY_CODE) = UPPER(IC.ITEM_CATEGORY_CODE)
WHERE UPPER(RL.UOM_CODE) = 'LB' AND 
UPPER(RL.ITEM_NO) NOT IN ('*REF','*DIV') AND
RL.PO_NO IS NOT NULL
GROUP BY 
     PURCHASE_ORDER_NUMBER
    ,PURCHASE_ORDER_LINE_NUMBER
    ,RECEIPT_NO
    ,RECEIPT_LINE_NO
    ,ITEM_NUMBER
    ,WAREHOUSE_CITY
    ,RECEIPT_LINE_DATE
    ,STEEL_COUNTRY_OF_ORIGIN
    ,STEEL_COUNTRY_ORIGIN_IS_CUSMA
    ,ITEM_DESCRIPTION
    ,RECEIPT_LINE_VENDOR_CODE
    ,SUPPLIER_USUAL_NAME
    ,RAW_MATERIAL_CATEGORY_NAME
    ,RAW_MATERIAL_SUBCATEGORY_NAME
    ,STEEL_CATEGORY
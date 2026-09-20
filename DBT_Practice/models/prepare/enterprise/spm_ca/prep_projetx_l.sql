{{
  config(
    materialized = "view",
    alias = "projetx_l",
    schema='spm_ca'
  )
}}

SELECT
 DATA:"entity_code" AS ENTITY_CODE
,DATA:"no_estime" AS NO_ESTIME
,DATA:"no_produit" AS NO_PRODUIT
,DATA:"type_projet" AS TYPE_PROJET
,DATA:"slsmn_code" AS SLSMN_CODE
,DATA:"type_fact" AS TYPE_FACT
,DATA:"qte_budgete" AS QTE_BUDGETE
,DATA:"qte_estime" AS QTE_ESTIME
,DATA:"surface" AS SURFACE
,DATA:"nbr_poutr" AS NBR_POUTR
,DATA:"tmps_std_ei_4" AS TMPS_STD_EI_4
,DATA:"tmps_std_ei_3" AS TMPS_STD_EI_3
,DATA:"tmps_std_ei_5" AS TMPS_STD_EI_5
,DATA:"tmps_std_ei_6" AS TMPS_STD_EI_6
,DATA:"tmps_std_ei_2" AS TMPS_STD_EI_2
,DATA:"tmps_std_ei_1" AS TMPS_STD_EI_1
,DATA:"mnt_est_info" AS MNT_EST_INFO
,DATA:"net_sale" AS NET_SALE
,DATA:"pst_quoted" AS PST_QUOTED
,DATA:"net_u_price" AS NET_U_PRICE
,DATA:"ind_f_conn" AS IND_F_CONN
,DATA:"waste_out" AS WASTE_OUT
,DATA:"inv_cat" AS INV_CAT
,DATA:"seq_no" AS SEQ_NO
,DATA:"tmps_std_e_6" AS TMPS_STD_E_6
,DATA:"tmps_std_e_7" AS TMPS_STD_E_7
,DATA:"tmps_std_e_5" AS TMPS_STD_E_5
,DATA:"tmps_std_e_4" AS TMPS_STD_E_4
,DATA:"tmps_std_e_3" AS TMPS_STD_E_3
,DATA:"tmps_std_e_2" AS TMPS_STD_E_2
,DATA:"tmps_std_e_1" AS TMPS_STD_E_1
,DATA:"complex_code" AS COMPLEX_CODE
,DATA:"estim_det" AS ESTIM_DET
,DATA:"estim_des" AS ESTIM_DES
,DATA:"dsg_cost_2" AS DSG_COST_2
,DATA:"dsg_cost_3" AS DSG_COST_3
,DATA:"dsg_cost_1" AS DSG_COST_1
,DATA:"dsg_cost_4" AS DSG_COST_4
,DATA:"dsg_cost_5" AS DSG_COST_5
,DATA:"dsg_cost_6" AS DSG_COST_6
,DATA:"office_code" AS OFFICE_CODE
,DATA:"branch_office_code" AS BRANCH_OFFICE_CODE
,DATA:"nbr_escort" AS NBR_ESCORT
,DATA:"cost" AS COST
,DATA:"vendor_id" AS VENDOR_ID
,DATA:"vendor_name" AS VENDOR_NAME
,DATA:"revenue_quantity_type_uuid" AS REVENUE_QUANTITY_TYPE_UUID
,DATA:"projetx_l_uuid" AS PROJETX_L_UUID
,DATA:"_rowid" AS ROW_ID
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"CreatedDate" AS CREATED_DATE
,DATA:"ModifiedDate" AS MODIFIED_DATE
,DATA:"CreatedBy" AS CREATED_BY
,DATA:"ModifiedBy" AS MODIFIED_BY
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,{{ dbt_utils.generate_surrogate_key(['DATA:"projetx_l_uuid"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

from {{ source("landing_spm_ca", "PROJETX_L") }}
-- to only take the files after the last fullLoad
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_ca", "PROJETX_L") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )
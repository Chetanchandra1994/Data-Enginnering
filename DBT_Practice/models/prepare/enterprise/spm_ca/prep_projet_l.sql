{{
  config(
    materialized = "view",
    alias = "projet_l",
    schema='spm_ca',
    tags=["projet_l"]
  )
}}

SELECT
DATA:"entity_code" AS ENTITY_CODE
,DATA:"no_projet" AS NO_PROJET
,DATA:"no_produit" AS NO_PRODUIT
,DATA:"type_fact" AS TYPE_FACT
,DATA:"stats_tmps_e_1" AS STATS_TMPS_E_1
,DATA:"stats_tmps_e_3" AS STATS_TMPS_E_3
,DATA:"stats_tmps_e_7" AS STATS_TMPS_E_7
,DATA:"stats_tmps_e_6" AS STATS_TMPS_E_6
,DATA:"stats_tmps_e_5" AS STATS_TMPS_E_5
,DATA:"stats_tmps_e_2" AS STATS_TMPS_E_2
,DATA:"stats_tmps_e_4" AS STATS_TMPS_E_4
,DATA:"stats_tmps_is_2" AS STATS_TMPS_IS_2
,DATA:"stats_tmps_is_1" AS STATS_TMPS_IS_1
,DATA:"stats_tmps_is_6" AS STATS_TMPS_IS_6
,DATA:"stats_tmps_is_4" AS STATS_TMPS_IS_4
,DATA:"stats_tmps_is_5" AS STATS_TMPS_IS_5
,DATA:"stats_tmps_is_3" AS STATS_TMPS_IS_3
,DATA:"stats_tmps_ir_4" AS STATS_TMPS_IR_4
,DATA:"stats_tmps_ir_3" AS STATS_TMPS_IR_3
,DATA:"stats_tmps_ir_2" AS STATS_TMPS_IR_2
,DATA:"stats_tmps_ir_1" AS STATS_TMPS_IR_1
,DATA:"stats_tmps_ir_6" AS STATS_TMPS_IR_6
,DATA:"stats_tmps_ir_5" AS STATS_TMPS_IR_5
,DATA:"dessin_deb" AS DESSIN_DEB
,DATA:"dessin_fin" AS DESSIN_FIN
,DATA:"stats_unites_2" AS STATS_UNITES_2
,DATA:"stats_unites_1" AS STATS_UNITES_1
,DATA:"stats_unites_3" AS STATS_UNITES_3
,DATA:"stats_unites_5" AS STATS_UNITES_5
,DATA:"stats_unites_4" AS STATS_UNITES_4
,DATA:"stats_poids_6" AS STATS_POIDS_6
,DATA:"stats_poids_8" AS STATS_POIDS_8
,DATA:"stats_poids_1" AS STATS_POIDS_1
,DATA:"stats_poids_2" AS STATS_POIDS_2
,DATA:"stats_poids_3" AS STATS_POIDS_3
,DATA:"stats_poids_4" AS STATS_POIDS_4
,DATA:"stats_poids_5" AS STATS_POIDS_5
,DATA:"stats_poids_7" AS STATS_POIDS_7
,DATA:"stats_tmps_ei_1" AS STATS_TMPS_EI_1
,DATA:"stats_tmps_ei_5" AS STATS_TMPS_EI_5
,DATA:"stats_tmps_ei_2" AS STATS_TMPS_EI_2
,DATA:"stats_tmps_ei_3" AS STATS_TMPS_EI_3
,DATA:"stats_tmps_ei_4" AS STATS_TMPS_EI_4
,DATA:"stats_tmps_ei_6" AS STATS_TMPS_EI_6
,DATA:"complex_code" AS COMPLEX_CODE
,DATA:"statut" AS STATUT
,DATA:"d_hist_livr_1" AS D_HIST_LIVR_1
,DATA:"d_hist_livr_2" AS D_HIST_LIVR_2
,DATA:"d_hist_livr_6" AS D_HIST_LIVR_6
,DATA:"d_hist_livr_5" AS D_HIST_LIVR_5
,DATA:"d_hist_livr_4" AS D_HIST_LIVR_4
,DATA:"d_hist_livr_3" AS D_HIST_LIVR_3
,DATA:"estim_det" AS ESTIM_DET
,DATA:"type_projet" AS TYPE_PROJET
,DATA:"slsmn_code" AS SLSMN_CODE
,DATA:"mnt_facture" AS MNT_FACTURE
,DATA:"stats_annuel_4" AS STATS_ANNUEL_4
,DATA:"stats_annuel_1" AS STATS_ANNUEL_1
,DATA:"stats_annuel_3" AS STATS_ANNUEL_3
,DATA:"stats_annuel_2" AS STATS_ANNUEL_2
,DATA:"ind_f_conn" AS IND_F_CONN
,DATA:"net_sale" AS NET_SALE
,DATA:"pst_quoted" AS PST_QUOTED
,DATA:"net_u_price" AS NET_U_PRICE
,DATA:"estim_des" AS ESTIM_DES
,DATA:"desgo_q" AS DESGO_Q
,DATA:"waste_out" AS WASTE_OUT
,DATA:"inv_cat" AS INV_CAT
,DATA:"stats_tmps_s_3" AS STATS_TMPS_S_3
,DATA:"stats_tmps_s_4" AS STATS_TMPS_S_4
,DATA:"stats_tmps_s_5" AS STATS_TMPS_S_5
,DATA:"stats_tmps_s_6" AS STATS_TMPS_S_6
,DATA:"stats_tmps_s_2" AS STATS_TMPS_S_2
,DATA:"stats_tmps_s_7" AS STATS_TMPS_S_7
,DATA:"stats_tmps_s_1" AS STATS_TMPS_S_1
,DATA:"stats_tmps_r_1" AS STATS_TMPS_R_1
,DATA:"stats_tmps_r_2" AS STATS_TMPS_R_2
,DATA:"stats_tmps_r_7" AS STATS_TMPS_R_7
,DATA:"stats_tmps_r_3" AS STATS_TMPS_R_3
,DATA:"stats_tmps_r_6" AS STATS_TMPS_R_6
,DATA:"stats_tmps_r_4" AS STATS_TMPS_R_4
,DATA:"stats_tmps_r_5" AS STATS_TMPS_R_5
,DATA:"dsg_cost_2" AS DSG_COST_2
,DATA:"dsg_cost_6" AS DSG_COST_6
,DATA:"dsg_cost_1" AS DSG_COST_1
,DATA:"dsg_cost_5" AS DSG_COST_5
,DATA:"dsg_cost_4" AS DSG_COST_4
,DATA:"dsg_cost_3" AS DSG_COST_3
,DATA:"mark_design_qty" AS MARK_DESIGN_QTY
,DATA:"time_procss_r" AS TIME_PROCSS_R
,DATA:"cost_procss_r" AS COST_PROCSS_R
,DATA:"stats_cost_3" AS STATS_COST_3
,DATA:"stats_cost_2" AS STATS_COST_2
,DATA:"stats_cost_1" AS STATS_COST_1
,DATA:"cmg_end_detail" AS CMG_END_DETAIL
,DATA:"time_procss_i" AS TIME_PROCSS_I
,DATA:"cost_procss_i" AS COST_PROCSS_I
,DATA:"office_code" AS OFFICE_CODE
,DATA:"branch_office_code" AS BRANCH_OFFICE_CODE
,DATA:"score_hrs_ton" AS SCORE_HRS_TON
,DATA:"vendor_id" AS VENDOR_ID
,DATA:"vendor_name" AS VENDOR_NAME
,DATA:"revenue_quantity_type_uuid" AS REVENUE_QUANTITY_TYPE_UUID
,DATA:"erector_priv_shipped_uom_transf" AS ERECTOR_PRIV_SHIPPED_UOM_TRANSF
,DATA:"projet_l_uuid" AS PROJET_L_UUID
,DATA:"_rowid" AS ROW_ID
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"CreatedDate" AS CREATED_DATE
,DATA:"ModifiedDate" AS MODIFIED_DATE
,DATA:"CreatedBy" AS CREATED_BY
,DATA:"ModifiedBy" AS MODIFIED_BY
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,{{ dbt_utils.generate_surrogate_key(['DATA:"entity_code"','DATA:"no_projet"','DATA:"no_produit"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

from {{ source("landing_spm_ca", "PROJET_L") }}
-- to only take the files after the last fullLoad
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_ca", "PROJET_L") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )
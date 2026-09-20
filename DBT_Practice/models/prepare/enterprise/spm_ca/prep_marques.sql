{{
 config(
 materialized = "view",
 alias = "marques",
 schema='spm_ca'
 )
}}

SELECT
    UPPER(DATA:"entity_code"::string) AS ENTITY_CODE
    ,UPPER(DATA:"no_poids"::integer) AS NO_POIDS
    ,UPPER(NULLIF(DATA:"marque"::string,'')) AS MARQUE
    ,DATA:"d_prod"::date AS D_PROD
    ,NULLIF(DATA:"r_marque"::string,'') AS R_MARQUE
    ,DATA:"hauteur"::double AS HAUTEUR
    ,NULLIF(DATA:"remarque"::string,'') AS REMARQUE
    ,DATA:"m_longueur"::double AS M_LONGUEUR
    ,DATA:"m_poids"::double AS M_POIDS
    ,DATA:"m_cout_mat"::double AS M_COUT_MAT
    ,DATA:"m_long_ppf"::string AS M_LONG_PPF
    ,DATA:"m_tmps_ind_1"::double AS M_TMPS_IND_1
    ,DATA:"m_tmps_ind_2"::double AS M_TMPS_IND_2
    ,DATA:"m_tmps_ind_3"::double AS M_TMPS_IND_3
    ,DATA:"m_tmps_ind_4"::double AS M_TMPS_IND_4
    ,DATA:"m_tmps_ind_5"::double AS M_TMPS_IND_5
    ,DATA:"m_seq"::integer AS M_SEQ
    ,NULLIF(DATA:"cat_struct"::string,'') AS CAT_STRUCT
    ,DATA:"numero_ident"::integer AS NUMERO_IDENT
    ,DATA:"conn_weight"::double AS CONN_WEIGHT
    ,DATA:"m_qtes_1"::integer AS M_QTES_1
    ,DATA:"m_qtes_2"::integer AS M_QTES_2
    ,DATA:"m_qtes_3"::integer AS M_QTES_3
    ,DATA:"m_qtes_4"::integer AS M_QTES_4
    ,DATA:"m_qtes_5"::integer AS M_QTES_5
    ,DATA:"m_qtes_6"::integer AS M_QTES_6
    ,DATA:"m_qtes_7"::integer AS M_QTES_7
    ,DATA:"orient"::integer AS ORIENT
    ,NULLIF(DATA:"mli"::string,'') AS MLI
    ,NULLIF(DATA:"reference"::string,'') AS REFERENCE
    ,DATA:"furn_cost"::double AS FURN_COST
    ,TO_BOOLEAN(DATA:"f_mark_upd"::string) AS F_MARK_UPD
    ,NULLIF(DATA:"orientation"::string,'') AS ORIENTATION
    ,DATA:"m_tmps_std_1"::double AS M_TMPS_STD_1
    ,DATA:"m_tmps_std_2"::double  AS M_TMPS_STD_2
    ,DATA:"m_tmps_std_3"::double  AS M_TMPS_STD_3
    ,DATA:"m_tmps_std_4"::double  AS M_TMPS_STD_4
    ,DATA:"m_tmps_std_5"::double  AS M_TMPS_STD_5
    ,DATA:"m_tmps_std_6"::double  AS M_TMPS_STD_6
    ,DATA:"us_tmps_std_1"::double  AS US_TMPS_STD_1
    ,DATA:"us_tmps_std_2"::double  AS US_TMPS_STD_2
    ,DATA:"us_tmps_std_3"::double  AS US_TMPS_STD_3
    ,DATA:"us_tmps_std_4"::double  AS US_TMPS_STD_4
    ,DATA:"us_tmps_std_5"::double  AS US_TMPS_STD_5
    ,DATA:"us_tmps_std_6"::double  AS US_TMPS_STD_6
    ,DATA:"m_long_metr"::double  AS M_LONG_METR
    --ALWAYS NNULL
    --,NULLIF(DATA:"dummy"::string,'') AS DUMMY
    ,DATA:"prod_startup_est_time1"::double  AS PROD_STARTUP_EST_TIME1
    ,DATA:"prod_startup_est_time2"::double  AS PROD_STARTUP_EST_TIME2
    ,DATA:"prod_startup_est_time3"::double  AS PROD_STARTUP_EST_TIME3
    ,DATA:"prod_startup_est_time4"::double  AS PROD_STARTUP_EST_TIME4
    ,DATA:"prod_startup_est_time5"::double  AS PROD_STARTUP_EST_TIME5
    ,DATA:"prod_startup_est_time6"::double  AS PROD_STARTUP_EST_TIME6
    ,DATA:"deck_accessory_dimension_b"::double AS DECK_ACCESSORY_DIMENSION_B
    ,DATA:"deck_accessory_dimension_c"::double AS DECK_ACCESSORY_DIMENSION_C
    ,DATA:"deck_accessory_angle"::integer AS DECK_ACCESSORY_ANGLE
    ,DATA:"deck_accessory_gage"::integer  AS DECK_ACCESSORY_GAGE
    ,DATA:"deck_accessory_dimension_a"::double AS DECK_ACCESSORY_DIMENSION_A
    ,UPPER(NULLIF(DATA:"cold_formed_mark_uuid"::string,'')) AS COLD_FORMED_MARK_UUID
    ,DATA:"finished_quantity_transferred"::double AS FINISHED_QUANTITY_TRANSFERRED
    ,TO_BOOLEAN(DATA:"detail_report_modified"::string) AS DETAIL_REPORT_MODIFIED
    ,DATA:"prod_startup_est_time1_initial"::double  AS PROD_STARTUP_EST_TIME1_INITIAL
    ,DATA:"prod_startup_est_time2_initial"::double  AS PROD_STARTUP_EST_TIME2_INITIAL
    ,DATA:"prod_startup_est_time3_initial"::double  AS PROD_STARTUP_EST_TIME3_INITIAL
    ,DATA:"prod_startup_est_time4_initial"::double  AS PROD_STARTUP_EST_TIME4_INITIAL
    ,DATA:"prod_startup_est_time5_initial"::double  AS PROD_STARTUP_EST_TIME5_INITIAL
    ,DATA:"prod_startup_est_time6_initial"::double  AS PROD_STARTUP_EST_TIME6_INITIAL
    ,UPPER(NULLIF(DATA:"bridge_accessory_mark_uuid"::string,'')) AS BRIDGE_ACCESSORY_MARK_UUID
    ,NULLIF(DATA:"pre_assembled_with"::string,'') AS PRE_ASSEMBLED_WITH
    ,DATA:"marques_uuid"::string AS MARQUES_UUID
    ,NULLIF(DATA:"BottomChordShapeType"::string,'') AS BOTTOMCHORDSHAPETYPE
    ,NULLIF(DATA:"TopChordShapeType"::string,'') AS TOPCHORDSHAPETYPE
    ,DATA:"CutLeg"::integer AS CUTLEG
    ,TO_BOOLEAN(DATA:"HasMemberReinforcement"::string) AS HASMEMBERREINFORCEMENT
    ,TO_BOOLEAN(DATA:"HasTCX"::string) AS HASTCX
    --Always 0
    --,DATA:"CutLegLength"::double AS CUTLEGLENGTH
    ,DATA:"QuantityShoeTagPrinted"::double AS QUANTITYSHOETAGPRINTED
    ,TO_TIMESTAMP_NTZ(DATA:"CreatedDate"::string) AS CREATEDDATE
    ,NULLIF(DATA:"CreatedBy"::string,'') AS CREATEDBY
    ,TO_TIMESTAMP_NTZ(DATA:"ModifiedDate"::string) AS MODIFIEDDATE
    ,NULLIF(DATA:"ModifiedBy"::string,'') AS MODIFIEDBY
    ,DATA:"SJAStatus"::integer AS SJASTATUS
    ,DATA:"SJAEstimatedTime"::double AS SJAESTIMATEDTIME
    ,DATA:"SJAEstimatedTimeInitial"::double AS SJAESTIMATEDTIMEINITIAL
    ,DATA:"prod_startup_est_time2_old"::double AS PROD_STARTUP_EST_TIME2_OLD
    ,DATA:"prod_startup_est_time2_init_old"::double AS PROD_STARTUP_EST_TIME2_INIT_OLD
    ,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
    ,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
    ,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
    ,FILENAME AS METADATA_FILENAME 
    ,FILE_ROW_NUMBER AS METADATA_FILE_ROW_NUMBER
    ,FILE_LAST_MODIFIED AS METADATA_FILE_LAST_MODIFIED
    ,START_SCAN_TIME AS METADATA_START_SCAN_TIME
    ,{{ dbt_utils.generate_surrogate_key(['DATA:"entity_code"','DATA:"no_poids"','DATA:"m_seq"']) }} as TABLE_SK
    ,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP
FROM {{ source("landing_spm_ca", "MARQUES") }}
-- to only take the files after the last fullLoad
WHERE 
 split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
 (SELECT min_timestamp
 FROM
 (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
 FROM {{ source("landing_spm_ca", "MARQUES") }}
 WHERE type_file LIKE 'fullload%'
 QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
 )
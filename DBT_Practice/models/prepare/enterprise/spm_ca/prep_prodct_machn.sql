{{
  config(
    materialized = "view",
    alias = "prodct_machn",
    schema='spm_ca'
  )
}}

SELECT
    DATA:"BridgePreparationDefaultPrepQty" AS BRIDGEPREPARATIONDEFAULTPREPQTY,
    DATA:"BridgePreparationGroupOrder" AS BRIDGEPREPARATIONGROUPORDER,
    DATA:"EquipmentID" AS EQUIPMENTID,
    DATA:"StatusDisplay" AS STATUSDISPLAY,
    DATA:"active" AS ACTIVE,
    DATA:"automatic_production_data_purge" AS AUTOMATIC_PRODUCTION_DATA_PURGE,
    DATA:"automatic_production_entry" AS AUTOMATIC_PRODUCTION_ENTRY,
    DATA:"capacity" AS CAPACITY,
    DATA:"data_warehouse_transfer" AS DATA_WAREHOUSE_TRANSFER,
    DATA:"date_d_entr" AS DATE_D_ENTR,
    DATA:"date_p_entr" AS DATE_P_ENTR,
    DATA:"deck_embossing" AS DECK_EMBOSSING,
    DATA:"delay_before_assembly" AS DELAY_BEFORE_ASSEMBLY,
    DATA:"delay_for_realtime_correction" AS DELAY_FOR_REALTIME_CORRECTION,
    DATA:"dept_no" AS DEPT_NO,
    DATA:"description" AS DESCRIPTION,
    DATA:"display_shop_detail" AS DISPLAY_SHOP_DETAIL,
    DATA:"entity_code" AS ENTITY_CODE,
    DATA:"equipment_type_uuid" AS EQUIPMENT_TYPE_UUID,
    DATA:"hole_thickn" AS HOLE_THICKN,
    DATA:"hole_time" AS HOLE_TIME,
    DATA:"item_management_preparation" AS ITEM_MANAGEMENT_PREPARATION,
    DATA:"length_factor" AS LENGTH_FACTOR,
    DATA:"length_meter" AS LENGTH_METER,
    DATA:"length_time" AS LENGTH_TIME,
    DATA:"machn_no" AS MACHN_NO,
    DATA:"maximum_speed" AS MAXIMUM_SPEED,
    DATA:"perimt_factor" AS PERIMT_FACTOR,
    DATA:"perimt_time" AS PERIMT_TIME,
    DATA:"piece_time" AS PIECE_TIME,
    DATA:"prep_shift_number_to_display" AS PREP_SHIFT_NUMBER_TO_DISPLAY,
    DATA:"preparation_allow_group" AS PREPARATION_ALLOW_GROUP,
    DATA:"preparation_planning" AS PREPARATION_PLANNING,
    DATA:"printer" AS PRINTER,
    DATA:"prod_cum_cm" AS PROD_CUM_CM,
    DATA:"prod_cum_lbs" AS PROD_CUM_LBS,
    DATA:"prod_cum_min" AS PROD_CUM_MIN,
    DATA:"prod_de_cm" AS PROD_DE_CM,
    DATA:"prod_de_lbs" AS PROD_DE_LBS,
    DATA:"prod_de_min" AS PROD_DE_MIN,
    DATA:"prodct_machn_uuid" AS PRODCT_MACHN_UUID,
    DATA:"prodct_rate" AS PRODCT_RATE,
    DATA:"rebut_tolere" AS REBUT_TOLERE,
    DATA:"robot" AS ROBOT,
    DATA:"shop_uuid" AS SHOP_UUID,
    DATA:"strokes_counter" AS STROKES_COUNTER,
    DATA:"strokes_email_sent" AS STROKES_EMAIL_SENT,
    DATA:"strokes_maintenance" AS STROKES_MAINTENANCE,
    DATA:"strokes_managers" AS STROKES_MANAGERS,
    DATA:"t_ep" AS T_EP,
    DATA:"t_lot" AS T_LOT,
    DATA:"tomaj" AS TOMAJ,
    DATA:"transfer_format" AS TRANSFER_FORMAT,
    DATA:"uom_code" AS UOM_CODE,
    DATA:"validate_coil_information" AS VALIDATE_COIL_INFORMATION,
    DATA:"virtek_laser" AS VIRTEK_LASER,
    DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE,
    DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP,
    FILENAME AS METADATA_FILENAME,
    FILE_ROW_NUMBER AS METADATA_FILE_ROW_NUMBER,
    FILE_LAST_MODIFIED AS METADATA_FILE_LAST_MODIFIED,
    START_SCAN_TIME AS METADATA_START_SCAN_TIME
    ,{{ dbt_utils.generate_surrogate_key(['DATA:"prodct_machn_uuid"']) }} as TABLE_SK
    ,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

FROM
    {{ source("landing_spm_ca", "PRODCT_MACHN") }}
WHERE
    -- Only take the files after the last fullLoad
    SPLIT(FILENAME, '_')[ARRAY_SIZE(SPLIT(FILENAME, '_')) - 2] >= (
        SELECT
            min_timestamp
        FROM
            (
                SELECT
                    SPLIT(FILENAME, '_')[ARRAY_SIZE(SPLIT(FILENAME, '_')) - 2] AS min_timestamp,
                    SPLIT(FILENAME, '/')[3] AS type_file
                FROM
                    {{ source("landing_spm_ca", "PRODCT_MACHN") }}
                WHERE
                    type_file LIKE 'fullload%'
                QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1
            )
    )
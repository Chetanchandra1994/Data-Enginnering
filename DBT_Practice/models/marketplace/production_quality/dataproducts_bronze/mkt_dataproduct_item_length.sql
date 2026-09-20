{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "item_length",
    schema= "dataproducts_bronze",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR",
    meta = {
    'cron_prod': '*/5 7-19 * * *',
    'cron_test': '0 7 * * *',
    'timezone': 'America/Toronto'    
}  
  )
}}

WITH
base_item_measures AS (
    SELECT
        ia.in_entity, 
        ia.whs_code, 
        ia.item_no,
        i.sort_name, 
        ia.bin_location,
        ia.mesure1 AS raw_mesure1,
        ia.mesure2 AS raw_mesure2,
        ia.mli, 
        ia.heat_no,
        c.name as country_of_origin, 
        ia.no_reser, 
        ia.no_projet_to,
        i.udm_alt,
        i.mesure AS item_mesure_system,
        i.facteur AS item_facteur, 
        i.uom_code AS item_uom_code, 
        i.global_item_uuid, 
        i.steel_grade_uuid,
        CASE
            WHEN i.mesure = 1 THEN ia.mesure1 * 25.4
            ELSE ia.mesure1
        END AS mesure1_mm,
        CASE
            WHEN i.mesure = 1 THEN ia.mesure1
            ELSE ia.mesure1 / 25.4
        END AS mesure1_inches,

        CASE
            WHEN i.mesure = 1 THEN ia.mesure2 * 25.4
            ELSE ia.mesure2
        END AS mesure2_mm,
        CASE
            WHEN i.mesure = 1 THEN ia.mesure2
            ELSE ia.mesure2 / 25.4
        END AS mesure2_inches,
        DN.name as description_en,
        DN2.name as description_fr,
        TC.technical_category_code as item_technical_category,
        SG.description as steel_grade_description
    FROM {{ ref ('norm_item_alt') }} ia
    JOIN {{ ref ('norm_item') }} i ON UPPER(ia.in_entity) = UPPER(i.in_entity) AND UPPER(ia.item_no) = UPPER(i.item_no)    
    LEFT JOIN {{ ref ('norm_global_item') }} GI
    ON I.GLOBAL_ITEM_UUID = GI.global_item_uuid
    LEFT JOIN {{ ref ('norm_data_name') }}  DN
    on GI.global_item_name_id = DN.name_id and DN.language_code = 1
    LEFT JOIN {{ ref ('norm_data_name') }}  DN2
    on GI.global_item_name_id = DN2.name_id and DN2.language_code = 2
    LEFT JOIN {{ ref ('norm_technical_category') }}  TC
    ON GI.technical_category_uuid = TC.technical_category_uuid
    LEFT JOIN {{ ref ('norm_steel_grade') }}  SG
    ON I.STEEL_GRADE_UUID = SG.STEEL_GRADE_UUID
    LEFT JOIN {{ ref ('norm_heat_no_country') }} HNC
    ON IA.heat_no = HNC.heat_no
    LEFT JOIN {{ ref ('norm_country') }} C
    ON HNC.country_code = C.country_code
),
-- 2. Filter item_whs
valid_item_whs AS (
    SELECT
        iw.in_entity,
        iw.whs_code,
        iw.item_no,
        iwd.cost
    FROM {{ ref ('norm_item_whs') }} iw
    LEFT JOIN {{ ref ('norm_item_whs_d') }} IWD
        ON IW.IN_ENTITY = IWD.IN_ENTITY AND IW.ITEM_NO = IWD.ITEM_NO AND IW.WHS_CODE = IWD.WHS_CODE
    --ONLY ITEM MEASURED IN LENGTH
    WHERE iw.cost_method = '6'
      AND (
            EXISTS (
                SELECT 1 FROM {{ ref ('norm_item_alt') }} ia_check
                WHERE UPPER(ia_check.in_entity) = UPPER(iw.in_entity)
                  AND UPPER(ia_check.whs_code) = UPPER(iw.whs_code)
                  AND UPPER(ia_check.item_no) = UPPER(iw.item_no)
            ) OR
            EXISTS (
                SELECT 1 FROM {{ ref ('norm_item_alt_po') }} iapo_check
                WHERE UPPER(iapo_check.in_entity) = UPPER(iw.in_entity)
                  AND UPPER(iapo_check.whs_code) = UPPER(iw.whs_code)
                  AND UPPER(iapo_check.item_no) = UPPER(iw.item_no)
            )
      )
),
-- 3. Main processing, joining all tables
item_alt_processed AS (
    SELECT
        bim.in_entity, 
        bim.whs_code, 
        bim.item_no, 
        bim.sort_name,
        bim.bin_location, 
        bim.raw_mesure1, 
        bim.raw_mesure2,
        bim.mli, 
        bim.heat_no,
        bim.country_of_origin, 
        bim.no_reser, 
        bim.no_projet_to,
        bim.udm_alt, 
        bim.item_mesure_system, 
        bim.item_facteur, 
        bim.item_uom_code,
        bim.global_item_uuid, 
        bim.steel_grade_uuid,
        bim.mesure1_mm, 
        bim.mesure1_inches, 
        bim.mesure2_mm,
        FLOOR(bim.mesure2_mm / 1000)::VARCHAR || 'M' || ROUND(MOD(bim.mesure2_mm, 1000)/10,0)::VARCHAR || 'CM' as mesure_meter,             
        bim.mesure2_inches,
        FLOOR(bim.mesure2_inches / 12)::VARCHAR || '’-' || ROUND(MOD(bim.mesure2_inches, 12),1)::VARCHAR || '’’' AS mesure2_feet, 
        ROUND(bim.mesure2_inches / 12.0, 2) AS mesure2_feet_decimal,
        it.no_item_num,
        u_for_item_udm_alt.base_uom AS base_uom,
        u_for_item_uom_code.unit AS uom_unit_for_cost_calc,
        CASE 
            WHEN bim.udm_alt IN ('PD','FT') THEN 25.4      
            WHEN bim.udm_alt IN ('P2','SF') THEN 929.0304
            WHEN bim.udm_alt = 'M2' THEN 1000.0
            ELSE 1.0
        END AS v_mm_from_udm_alt,
        CASE
            WHEN bim.udm_alt IN ('M2', 'M') THEN 1.0
            ELSE 25.4
        END AS v_mesure_fact_for_poids,
        rp.prodct_status,
        rp.delivr_status,
        rp.no_job_shop,
        bim.description_en,
        bim.description_fr,
        bim.item_technical_category,
        IFF(bim.no_reser <> 0 AND bim.no_reser is not null, 'SHORT', IFF(bim.no_projet_to IS NOT NULL, 'LONG', null)) as reservation_type,
        bim.steel_grade_description,
        viw.cost as whs_d_cost_for_cost_calc       
    FROM base_item_measures bim
    LEFT JOIN valid_item_whs viw
        ON UPPER(bim.in_entity) = UPPER(viw.in_entity)
        AND UPPER(bim.whs_code) = UPPER(viw.whs_code)
        AND UPPER(bim.item_no) = UPPER(viw.item_no)
    LEFT JOIN {{ ref ('norm_item_tech') }} it
        ON UPPER(bim.in_entity) = UPPER(it.in_entity) AND UPPER(bim.item_no) = UPPER(it.no_article)
    LEFT JOIN {{ ref ('norm_uom') }} u_for_item_udm_alt
        ON UPPER(bim.udm_alt) = UPPER(u_for_item_udm_alt.uom_code)
    LEFT JOIN {{ ref ('norm_uom') }} u_for_item_uom_code
        ON UPPER(bim.item_uom_code) = UPPER(u_for_item_uom_code.uom_code)
    LEFT JOIN {{ ref ('norm_req_prod') }} rp
        ON bim.no_reser = rp.no_job_shop AND bim.no_projet_to = rp.no_projet AND rp.no_job_shop <> 0

),
-- 4. Calculations for display values and grouping keys
final_calcs AS (
    SELECT
        iap.*,

        COUNT(*) OVER (
            PARTITION BY iap.item_no, iap.raw_mesure2, iap.mli, iap.heat_no, iap.reservation_type, iap.no_job_shop, iap.whs_code, iap.bin_location, iap.no_projet_to
        ) AS nbr_pieces,
        ROW_NUMBER() OVER (
            PARTITION BY iap.item_no, iap.raw_mesure2, iap.mli, iap.heat_no, iap.reservation_type, iap.no_job_shop, iap.whs_code, iap.bin_location, iap.no_projet_to
            ORDER BY
                iap.bin_location DESC, iap.raw_mesure2 DESC, iap.mli DESC
        ) AS rn_for_display_group
    FROM item_alt_processed iap
),
-- 5. Calculate poids_tot
results AS (
    SELECT
        fc.*,
        -- Progress report formula
        (fc.nbr_pieces *
         GREATEST(1, fc.raw_mesure1 * fc.v_mesure_fact_for_poids) *
         (fc.raw_mesure2 * fc.v_mesure_fact_for_poids) *
         fc.item_facteur / fc.v_mm_from_udm_alt
        ) AS poids_tot_lbs,
        -- Progress report formula
        ROUND((fc.nbr_pieces *
         GREATEST(1, fc.raw_mesure1 * fc.v_mesure_fact_for_poids) *
         (fc.raw_mesure2 * fc.v_mesure_fact_for_poids) *
         fc.item_facteur / fc.v_mm_from_udm_alt
        ) * fc.whs_d_cost_for_cost_calc / fc.uom_unit_for_cost_calc,2) as cost
    FROM final_calcs fc
    WHERE fc.rn_for_display_group = 1 -- Simulates the LAST-OF logic for display
),
item_alt_po as (
SELECT
    iap.in_entity,
    iap.whs_code,
    iap.no_projet_to,
    null as bin_location,
    CASE
            WHEN i.mesure = 1 THEN iap.mesure_2 * 25.4
            ELSE iap.mesure_2
    END AS mesure2_mm,
    CASE
            WHEN i.mesure = 1 THEN iap.mesure_2
            ELSE iap.mesure_2 / 25.4
        END AS mesure2_inches,
    iap.item_no,
    i.sort_name,
    iap.mesure_1,
    iap.mesure_2,
    iap.heat_no,
    c.name as country_of_origin,
    iap.reference,
    iap.mli,
    i.udm_alt,
    i.mesure AS item_mesure_system,
    i.facteur AS item_facteur, 
    i.uom_code AS item_uom_code, 
    DN.name as description_en,
    DN2.name as description_fr,
    TC.technical_category_code as item_technical_category,
    SG.description as steel_grade_description,
    COUNT(*) OVER (
            PARTITION BY iap.item_no, iap.mesure_2, iap.mli, iap.heat_no, iap.whs_code, iap.no_projet_to, iap.reference
        ) AS nbr_pieces,
    viw.cost as whs_d_cost_for_cost_calc,
    ROW_NUMBER() OVER (
            PARTITION BY iap.item_no, iap.mesure_2, iap.mli, iap.heat_no, iap.whs_code, iap.no_projet_to, iap.reference
            ORDER BY
                iap.item_no desc, iap.mesure_2 desc, iap.mli desc, iap.heat_no desc, iap.whs_code desc
        ) AS rn_for_display_group,
    CASE
            WHEN i.udm_alt IN ('M2', 'M') THEN 1.0
            ELSE 25.4
        END AS v_mesure_fact_for_poids,
    CASE
        WHEN i.udm_alt IN ('PD', 'FT') THEN 25.4
        WHEN i.udm_alt IN ('P2', 'SF') THEN 929.0304
        WHEN i.udm_alt = 'M2' THEN 1000.0
        ELSE 1.0
    END AS v_mm_from_udm_alt,
    viw.cost as cost,
    u_for_item_uom_code.unit as uom_unit_for_cost_calc
    FROM {{ ref ('norm_item_alt_po') }} iap
    JOIN {{ ref ('norm_item') }} i ON UPPER(iap.in_entity) = UPPER(i.in_entity) AND UPPER(iap.item_no) = UPPER(i.item_no)
    LEFT JOIN {{ ref ('norm_global_item') }} GI
    ON I.GLOBAL_ITEM_UUID = GI.global_item_uuid
    LEFT JOIN {{ ref ('norm_data_name') }}  DN
    on GI.global_item_name_id = DN.name_id and DN.language_code = 1
    LEFT JOIN {{ ref ('norm_data_name') }}  DN2
    on GI.global_item_name_id = DN2.name_id and DN2.language_code = 2
    LEFT JOIN {{ ref ('norm_technical_category') }}  TC
    ON GI.technical_category_uuid = TC.technical_category_uuid
    LEFT JOIN {{ ref ('norm_steel_grade') }}  SG
    ON I.STEEL_GRADE_UUID = SG.STEEL_GRADE_UUID
    LEFT JOIN {{ ref ('norm_heat_no_country') }} HNC
    ON IAP.heat_no = HNC.heat_no
    LEFT JOIN {{ ref ('norm_country') }} C
    ON HNC.country_code = C.country_code
    LEFT JOIN valid_item_whs viw
        ON UPPER(iap.in_entity) = UPPER(viw.in_entity)
        AND UPPER(iap.whs_code) = UPPER(viw.whs_code)
        AND UPPER(iap.item_no) = UPPER(viw.item_no)
    LEFT JOIN {{ ref ('norm_uom') }} u_for_item_udm_alt
        ON UPPER(I.udm_alt) = UPPER(u_for_item_udm_alt.uom_code)
    LEFT JOIN {{ ref ('norm_uom') }} u_for_item_uom_code
        ON UPPER(I.uom_code) = UPPER(u_for_item_uom_code.uom_code)
    
),
item_alt_po_processed as(
SELECT
    iap.item_no as item_number,
    iap.sort_name as sort_name,
    iap.description_en as item_description_en,
    iap.description_fr as item_description_fr,
    iap.no_projet_to as project_number_assigned_to,
    iap.item_technical_category as item_technical_category,
    iap.steel_grade_description as item_steel_grade_description,
    iap.whs_code as warehouse_code,
    iap.bin_location as bin_location,
    FLOOR(iap.mesure2_inches / 12)::VARCHAR || '’-' || ROUND(MOD(iap.mesure2_inches, 12),1)::VARCHAR || '’’' AS length_feet,
    ROUND(iap.mesure2_inches / 12.0, 2) AS length_feet_decimal,
    mesure2_mm as length_millimeter,
    iap.mli,    
    iap.heat_no,
    iap.country_of_origin,
    ROUND((iap.nbr_pieces *
         GREATEST(1, iap.mesure_1 * iap.v_mesure_fact_for_poids) *
         (iap.mesure_2 * iap.v_mesure_fact_for_poids) *
         iap.item_facteur / iap.v_mm_from_udm_alt
        ) * iap.cost / iap.uom_unit_for_cost_calc,2
    ) as cost,
    iap.nbr_pieces as amount_of_pieces,
    CASE WHEN IAP.reference IS NULL THEN iap.nbr_pieces END AS suggested_buying_quantity,
    CASE WHEN IAP.reference IS NOT NULL THEN iap.nbr_pieces END AS on_po_quantity,
    NULL as total_weight_lbs,
    CASE WHEN IAP.reference IS NULL THEN (iap.nbr_pieces *
         GREATEST(1, iap.mesure_1 * iap.v_mesure_fact_for_poids) *
         (iap.mesure_2 * iap.v_mesure_fact_for_poids) *
         iap.item_facteur / iap.v_mm_from_udm_alt
        )
    END AS suggested_buying_weight,
    CASE WHEN IAP.reference IS NOT NULL THEN (iap.nbr_pieces *
         GREATEST(1, iap.mesure_1 * iap.v_mesure_fact_for_poids) *
         (iap.mesure_2 * iap.v_mesure_fact_for_poids) *
         iap.item_facteur / iap.v_mm_from_udm_alt
        )
    END AS on_po_weight,
    IFF(iap.no_projet_to IS NOT NULL, 'LONG', null) as reservation_type,
    null as reservation_number,
    'item_alt_po' as source_data
FROM item_alt_po iap
WHERE rn_for_display_group = 1
)
SELECT
    r.item_no AS item_number,
    r.sort_name AS sort_name,
    r.description_en AS item_description_en,
    r.description_fr AS item_description_fr,
    r.no_projet_to AS project_number_assigned_to,
    r.item_technical_category AS item_technical_category,
    r.steel_grade_description AS item_steel_grade_description,
    r.whs_code as warehouse_code,
    r.bin_location AS bin_location,
    r.mesure2_feet AS length_feet,
    r.mesure2_feet_decimal AS length_feet_decimal ,
    r.mesure2_mm AS length_millimeter,      
    r.mli AS mli,
    r.heat_no AS heat_no,
    r.country_of_origin as country_of_origin,
    r.cost as cost,
    r.nbr_pieces as on_hands_quantity,
    r.poids_tot_lbs as total_weight_lbs,
    NULL as suggested_buying_quantity,
    NULL as suggested_buying_weight,
    NULL as on_po_quantity,
    NULL as on_po_weight,
    r.reservation_type as reservation_type,
    r.no_job_shop as reservation_number
FROM results r
UNION ALL
SELECT
    item_number,
    sort_name,
    item_description_en,
    item_description_fr,
    project_number_assigned_to,
    item_technical_category,
    item_steel_grade_description,
    warehouse_code,
    bin_location,
    length_feet,
    length_feet_decimal,
    length_millimeter,      
    mli,
    heat_no,
    country_of_origin,
    null as cost,
    null as on_hands_quantity,
    total_weight_lbs,
    suggested_buying_quantity,
    suggested_buying_weight,
    on_po_quantity,
    on_po_weight,
    reservation_type,
    reservation_number
FROM item_alt_po_processed
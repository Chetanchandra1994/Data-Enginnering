 {{
  config(
    materialized = "view",
    alias = "pa_projects_all",
    schema='EBS'
  )
}}

SELECT
PROJECT_ID::number(15,0) AS PROJECT_ID
,UPPER(NULLIF(TRIM(NAME::string),'')) AS NAME
,UPPER(NULLIF(TRIM(SEGMENT1::string),'')) AS SEGMENT1
,TO_TIMESTAMP_NTZ(LAST_UPDATE_DATE::string) AS LAST_UPDATE_DATE
,LAST_UPDATED_BY::number(15,0) AS LAST_UPDATED_BY
,TO_TIMESTAMP_NTZ(CREATION_DATE::string) AS CREATION_DATE
,CREATED_BY::number(15,0) AS CREATED_BY
,LAST_UPDATE_LOGIN::number(15,0) AS LAST_UPDATE_LOGIN
,UPPER(NULLIF(TRIM(PROJECT_TYPE::string),'')) AS PROJECT_TYPE
,CARRYING_OUT_ORGANIZATION_ID::number(15,0) AS CARRYING_OUT_ORGANIZATION_ID
,UPPER(NULLIF(TRIM(PUBLIC_SECTOR_FLAG::string),'')) AS PUBLIC_SECTOR_FLAG
,UPPER(NULLIF(TRIM(PROJECT_STATUS_CODE::string),'')) AS PROJECT_STATUS_CODE
,UPPER(NULLIF(TRIM(DESCRIPTION::string),'')) AS DESCRIPTION
,TO_TIMESTAMP_NTZ(START_DATE::string) AS START_DATE
,TO_TIMESTAMP_NTZ(COMPLETION_DATE::string) AS COMPLETION_DATE
,TO_TIMESTAMP_NTZ(CLOSED_DATE::string) AS CLOSED_DATE
,UPPER(NULLIF(TRIM(DISTRIBUTION_RULE::string),'')) AS DISTRIBUTION_RULE
,LABOR_INVOICE_FORMAT_ID::number(15,0) AS LABOR_INVOICE_FORMAT_ID
,NON_LABOR_INVOICE_FORMAT_ID::number(15,0) AS NON_LABOR_INVOICE_FORMAT_ID
,RETENTION_INVOICE_FORMAT_ID::number(15,0) AS RETENTION_INVOICE_FORMAT_ID
,RETENTION_PERCENTAGE::number(17,2) AS RETENTION_PERCENTAGE
,BILLING_OFFSET::number(15,0) AS BILLING_OFFSET
--,BILLING_CYCLE::number(15,0) AS BILLING_CYCLE                                                             --column entirely NULL
,UPPER(NULLIF(TRIM(LABOR_STD_BILL_RATE_SCHDL::string),'')) AS LABOR_STD_BILL_RATE_SCHDL
,LABOR_BILL_RATE_ORG_ID::number(15,0) AS LABOR_BILL_RATE_ORG_ID
--,LABOR_SCHEDULE_FIXED_DATE::string AS LABOR_SCHEDULE_FIXED_DATE                                           --column entirely NULL
--,LABOR_SCHEDULE_DISCOUNT::number(7,4) AS LABOR_SCHEDULE_DISCOUNT                                          --column entirely NULL
,UPPER(NULLIF(TRIM(TEMPLATE_FLAG::string),'')) AS TEMPLATE_FLAG
--,VERIFICATION_DATE::string AS VERIFICATION_DATE                                                           --column entirely NULL
,CREATED_FROM_PROJECT_ID::number(15,0) AS CREATED_FROM_PROJECT_ID
,TO_TIMESTAMP_NTZ(TEMPLATE_START_DATE_ACTIVE::string) AS TEMPLATE_START_DATE_ACTIVE
,UPPER(NULLIF(TRIM(NON_LABOR_STD_BILL_RATE_SCHDL::string),'')) AS NON_LABOR_STD_BILL_RATE_SCHDL
,TO_TIMESTAMP_NTZ(TEMPLATE_END_DATE_ACTIVE::string) AS TEMPLATE_END_DATE_ACTIVE
,NON_LABOR_BILL_RATE_ORG_ID::number(15,0) AS NON_LABOR_BILL_RATE_ORG_ID
--,NON_LABOR_SCHEDULE_FIXED_DATE::string AS NON_LABOR_SCHEDULE_FIXED_DATE                                   --column entirely NULL
--,NON_LABOR_SCHEDULE_DISCOUNT::string AS NON_LABOR_SCHEDULE_DISCOUNT                                       --column entirely NULL
,UPPER(NULLIF(TRIM(LIMIT_TO_TXN_CONTROLS_FLAG::string),'')) AS LIMIT_TO_TXN_CONTROLS_FLAG
,UPPER(NULLIF(TRIM(PROJECT_LEVEL_FUNDING_FLAG::string),'')) AS PROJECT_LEVEL_FUNDING_FLAG
--,INVOICE_COMMENT::string AS INVOICE_COMMENT                                                               --column entirely NULL
,UNBILLED_RECEIVABLE_DR::number(22,5) AS UNBILLED_RECEIVABLE_DR
,UNEARNED_REVENUE_CR::number(22,5) AS UNEARNED_REVENUE_CR
,REQUEST_ID::number(15,0) AS REQUEST_ID
,PROGRAM_ID::number(15,0) AS PROGRAM_ID
,PROGRAM_APPLICATION_ID::number(15,0) AS PROGRAM_APPLICATION_ID
,TO_TIMESTAMP_NTZ(PROGRAM_UPDATE_DATE::string) AS PROGRAM_UPDATE_DATE
--,SUMMARY_FLAG::string AS SUMMARY_FLAG                                                                     --column contains one distinct value 'N'
--,ENABLED_FLAG::string AS ENABLED_FLAG                                                                     --column contains one distinct value 'Y'
/*Columns entirely null
,SEGMENT2::string AS SEGMENT2
,SEGMENT3::string AS SEGMENT3
,SEGMENT4::string AS SEGMENT4
,SEGMENT5::string AS SEGMENT5
,SEGMENT6::string AS SEGMENT6
,SEGMENT7::string AS SEGMENT7
,SEGMENT8::string AS SEGMENT8
,SEGMENT9::string AS SEGMENT9
,SEGMENT10::string AS SEGMENT10*/
,UPPER(NULLIF(TRIM(ATTRIBUTE_CATEGORY::string),'')) AS ATTRIBUTE_CATEGORY
,UPPER(NULLIF(TRIM(ATTRIBUTE1::string),'')) AS ATTRIBUTE1
,UPPER(NULLIF(TRIM(ATTRIBUTE2::string),'')) AS ATTRIBUTE2
,UPPER(NULLIF(TRIM(ATTRIBUTE3::string),'')) AS ATTRIBUTE3
,UPPER(NULLIF(TRIM(ATTRIBUTE4::string),'')) AS ATTRIBUTE4
,ATTRIBUTE5::string AS ATTRIBUTE5
,ATTRIBUTE6::string AS ATTRIBUTE6
,UPPER(NULLIF(TRIM(ATTRIBUTE7::string),'')) AS ATTRIBUTE7
,UPPER(NULLIF(TRIM(ATTRIBUTE8::string),'')) AS ATTRIBUTE8
,UPPER(NULLIF(TRIM(ATTRIBUTE9::string),'')) AS ATTRIBUTE9
,UPPER(NULLIF(TRIM(ATTRIBUTE10::string),'')) AS ATTRIBUTE10
/*Columns entirely null
,COST_IND_RATE_SCH_ID::string AS COST_IND_RATE_SCH_ID
,REV_IND_RATE_SCH_ID::string AS REV_IND_RATE_SCH_ID
,INV_IND_RATE_SCH_ID::string AS INV_IND_RATE_SCH_ID
,COST_IND_SCH_FIXED_DATE::string AS COST_IND_SCH_FIXED_DATE
,REV_IND_SCH_FIXED_DATE::string AS REV_IND_SCH_FIXED_DATE
,INV_IND_SCH_FIXED_DATE::string AS INV_IND_SCH_FIXED_DATE
*/
,UPPER(NULLIF(TRIM(LABOR_SCH_TYPE::string),'')) AS LABOR_SCH_TYPE
,UPPER(NULLIF(TRIM(NON_LABOR_SCH_TYPE::string),'')) AS NON_LABOR_SCH_TYPE
--,OVR_COST_IND_RATE_SCH_ID::string AS OVR_COST_IND_RATE_SCH_ID                                                 --column entirely NULL
--,OVR_REV_IND_RATE_SCH_ID::string AS OVR_REV_IND_RATE_SCH_ID                                                   --column entirely NULL
--,OVR_INV_IND_RATE_SCH_ID::string AS OVR_INV_IND_RATE_SCH_ID                                                   --column entirely NULL
,ORG_ID::number(15,0) AS ORG_ID
,PM_PRODUCT_CODE::string AS PM_PRODUCT_CODE
,UPPER(NULLIF(TRIM(PM_PROJECT_REFERENCE::string),'')) AS PM_PROJECT_REFERENCE
/*Columns entirfvely null
,ACTUAL_START_DATE::string AS ACTUAL_START_DATE
,ACTUAL_FINISH_DATE::string AS ACTUAL_FINISH_DATE
,EARLY_START_DATE::string AS EARLY_START_DATE
,EARLY_FINISH_DATE::string AS EARLY_FINISH_DATE
,LATE_START_DATE::string AS LATE_START_DATE
,LATE_FINISH_DATE::string AS LATE_FINISH_DATE
*/
,TO_TIMESTAMP_NTZ(SCHEDULED_START_DATE::string) AS SCHEDULED_START_DATE
,TO_TIMESTAMP_NTZ(SCHEDULED_FINISH_DATE::string) AS SCHEDULED_FINISH_DATE
--,ADW_NOTIFY_FLAG::string AS ADW_NOTIFY_FLAG                                                                   --column contains one distinct value 'Y'
,BILLING_CYCLE_ID::number(15,0) AS BILLING_CYCLE_ID
--,WF_STATUS_CODE::string AS WF_STATUS_CODE                                                                     --column entirely NULL
,UPPER(NULLIF(TRIM(OUTPUT_TAX_CODE::string),'')) AS OUTPUT_TAX_CODE
,UPPER(NULLIF(TRIM(RETENTION_TAX_CODE::string),'')) AS RETENTION_TAX_CODE
,UPPER(NULLIF(TRIM(PROJECT_CURRENCY_CODE::string),'')) AS PROJECT_CURRENCY_CODE
,UPPER(NULLIF(TRIM(ALLOW_CROSS_CHARGE_FLAG::string),'')) AS ALLOW_CROSS_CHARGE_FLAG
--,PROJECT_RATE_DATE::string AS PROJECT_RATE_DATE                                                               --column entirely NULL
,NULLIF(TRIM(PROJECT_RATE_TYPE::string),'') AS PROJECT_RATE_TYPE
--,CC_PROCESS_LABOR_FLAG::string AS CC_PROCESS_LABOR_FLAG                                                       --column contains one distinct value 'N'
--,LABOR_TP_SCHEDULE_ID::string AS LABOR_TP_SCHEDULE_ID                                                         --column entirely NULL
--,LABOR_TP_FIXED_DATE::string AS LABOR_TP_FIXED_DATE                                                           --column entirely NULL
--,CC_PROCESS_NL_FLAG::string AS CC_PROCESS_NL_FLAG                                                             --column contains one distinct value 'N'
--,NL_TP_SCHEDULE_ID::string AS NL_TP_SCHEDULE_ID                                                               --column entirely NULL
--,NL_TP_FIXED_DATE::string AS NL_TP_FIXED_DATE                                                                 --column entirely NULL
--,CC_TAX_TASK_ID::string AS CC_TAX_TASK_ID                                                                     --column entirely NULL
,BILL_JOB_GROUP_ID::number(15,0) AS BILL_JOB_GROUP_ID
,COST_JOB_GROUP_ID::number(15,0) AS COST_JOB_GROUP_ID
--,ROLE_LIST_ID::string AS ROLE_LIST_ID                                                                         --column entirely NULL
--,WORK_TYPE_ID::string AS WORK_TYPE_ID                                                                         --column entirely NULL
--,CALENDAR_ID::string AS CALENDAR_ID                                                                           --column entirely NULL
,LOCATION_ID::number(15,0) AS LOCATION_ID
--,PROBABILITY_MEMBER_ID::string AS PROBABILITY_MEMBER_ID                                                       --column entirely NULL
--,PROJECT_VALUE::string AS PROJECT_VALUE                                                                       --column entirely NULL
--,EXPECTED_APPROVAL_DATE::string AS EXPECTED_APPROVAL_DATE                                                     --column entirely NULL
,RECORD_VERSION_NUMBER::number(15,0) AS RECORD_VERSION_NUMBER
--,INITIAL_TEAM_TEMPLATE_ID::string AS INITIAL_TEAM_TEMPLATE_ID                                                 --column entirely NULL
,JOB_BILL_RATE_SCHEDULE_ID::number AS JOB_BILL_RATE_SCHEDULE_ID
,EMP_BILL_RATE_SCHEDULE_ID::number AS EMP_BILL_RATE_SCHEDULE_ID
--,COMPETENCE_MATCH_WT::string AS COMPETENCE_MATCH_WT                                                           --one distinct value 100
--,AVAILABILITY_MATCH_WT::string AS AVAILABILITY_MATCH_WT                                                       --one distinct value 100
--,JOB_LEVEL_MATCH_WT::string AS JOB_LEVEL_MATCH_WT                                                             --one distinct value 100
--,ENABLE_AUTOMATED_SEARCH::string AS ENABLE_AUTOMATED_SEARCH                                                   --one distinct value 'N'
--,SEARCH_MIN_AVAILABILITY::string AS SEARCH_MIN_AVAILABILITY                                                   --one distinct value 100
--,SEARCH_ORG_HIER_ID::string AS SEARCH_ORG_HIER_ID                                                             --one distinct value 1
,SEARCH_STARTING_ORG_ID::number(15,0) AS SEARCH_STARTING_ORG_ID
--,SEARCH_COUNTRY_CODE::string AS SEARCH_COUNTRY_CODE                                                           --column entirely NULL
--,MIN_CAND_SCORE_REQD_FOR_NOM::string AS MIN_CAND_SCORE_REQD_FOR_NOM                                           --one distinct value 100
,NON_LAB_STD_BILL_RT_SCH_ID::number(15,0) AS NON_LAB_STD_BILL_RT_SCH_ID
,NULLIF(TRIM(INVPROC_CURRENCY_TYPE::string),'') AS INVPROC_CURRENCY_TYPE
,NULLIF(TRIM(REVPROC_CURRENCY_CODE::string),'') AS REVPROC_CURRENCY_CODE
,NULLIF(TRIM(PROJECT_BIL_RATE_DATE_CODE::string),'') AS PROJECT_BIL_RATE_DATE_CODE
,NULLIF(TRIM(PROJECT_BIL_RATE_TYPE::string),'') AS PROJECT_BIL_RATE_TYPE
--,PROJECT_BIL_RATE_DATE::string AS PROJECT_BIL_RATE_DATE                                                       --column entirely NULL
,PROJECT_BIL_EXCHANGE_RATE::number AS PROJECT_BIL_EXCHANGE_RATE
,NULLIF(TRIM(PROJFUNC_CURRENCY_CODE::string),'') AS PROJFUNC_CURRENCY_CODE
,NULLIF(TRIM(PROJFUNC_BIL_RATE_DATE_CODE::string),'') AS PROJFUNC_BIL_RATE_DATE_CODE
,NULLIF(TRIM(PROJFUNC_BIL_RATE_TYPE::string),'') AS PROJFUNC_BIL_RATE_TYPE
--,PROJFUNC_BIL_RATE_DATE::string AS PROJFUNC_BIL_RATE_DATE                                                     --column entirely NULL
,PROJFUNC_BIL_EXCHANGE_RATE::number AS PROJFUNC_BIL_EXCHANGE_RATE
,NULLIF(TRIM(FUNDING_RATE_DATE_CODE::string),'') AS FUNDING_RATE_DATE_CODE
,NULLIF(TRIM(FUNDING_RATE_TYPE::string),'') AS FUNDING_RATE_TYPE
--,FUNDING_RATE_DATE::string AS FUNDING_RATE_DATE                                                               --column entirely NULL
,FUNDING_EXCHANGE_RATE::number AS FUNDING_EXCHANGE_RATE
,NULLIF(TRIM(BASELINE_FUNDING_FLAG::string),'') AS BASELINE_FUNDING_FLAG
,NULLIF(TRIM(PROJFUNC_COST_RATE_TYPE::string),'') AS PROJFUNC_COST_RATE_TYPE
--,PROJFUNC_COST_RATE_DATE::string AS PROJFUNC_COST_RATE_DATE                                                   --column entirely NULL
--,INV_BY_BILL_TRANS_CURR_FLAG::string AS INV_BY_BILL_TRANS_CURR_FLAG                                           --one distinct value 'N'
,NULLIF(TRIM(MULTI_CURRENCY_BILLING_FLAG::string),'') AS MULTI_CURRENCY_BILLING_FLAG
,NULLIF(TRIM(SPLIT_COST_FROM_WORKPLAN_FLAG::string),'') AS SPLIT_COST_FROM_WORKPLAN_FLAG
--,SPLIT_COST_FROM_BILL_FLAG::string AS SPLIT_COST_FROM_BILL_FLAG                                               --one distinct value 'N'
--,ASSIGN_PRECEDES_TASK::string AS ASSIGN_PRECEDES_TASK                                                         --one distinct value 'N'
--,PRIORITY_CODE::string AS PRIORITY_CODE                                                                       --column entirely NULL
,RETN_BILLING_INV_FORMAT_ID::number(15,0) AS RETN_BILLING_INV_FORMAT_ID
,NULLIF(TRIM(RETN_ACCOUNTING_FLAG::string),'') AS RETN_ACCOUNTING_FLAG
--,ADV_ACTION_SET_ID::string AS ADV_ACTION_SET_ID                                                               --one distinct value 1
--,START_ADV_ACTION_SET_FLAG::string AS START_ADV_ACTION_SET_FLAG                                               --one distinct value 'Y'
,NULLIF(TRIM(REVALUATE_FUNDING_FLAG::string),'') AS REVALUATE_FUNDING_FLAG
--,INCLUDE_GAINS_LOSSES_FLAG::string AS INCLUDE_GAINS_LOSSES_FLAG                                               --one distinct value 'N'
,TO_TIMESTAMP_NTZ(TARGET_START_DATE::string) AS TARGET_START_DATE
,TO_TIMESTAMP_NTZ(TARGET_FINISH_DATE::string) AS TARGET_FINISH_DATE
,TO_TIMESTAMP_NTZ(BASELINE_START_DATE::string) AS BASELINE_START_DATE
,TO_TIMESTAMP_NTZ(BASELINE_FINISH_DATE::string) AS BASELINE_FINISH_DATE
,TO_TIMESTAMP_NTZ(SCHEDULED_AS_OF_DATE::string) AS SCHEDULED_AS_OF_DATE
,TO_TIMESTAMP_NTZ(BASELINE_AS_OF_DATE::string) AS BASELINE_AS_OF_DATE
--,LABOR_DISC_REASON_CODE::string AS LABOR_DISC_REASON_CODE                                                     --column entirely NULL
--,NON_LABOR_DISC_REASON_CODE::string AS NON_LABOR_DISC_REASON_CODE                                             --column entirely NULL
--,SECURITY_LEVEL::string AS SECURITY_LEVEL                                                                     --one distinct value 1
--,ACTUAL_AS_OF_DATE::string AS ACTUAL_AS_OF_DATE                                                               --column entirely NULL
,SCHEDULED_DURATION::number AS SCHEDULED_DURATION
,BASELINE_DURATION::number AS BASELINE_DURATION
--,ACTUAL_DURATION::string AS ACTUAL_DURATION
,UPPER(NULLIF(TRIM(LONG_NAME::string),'')) AS LONG_NAME
,UPPER(NULLIF(TRIM(BTC_COST_BASE_REV_CODE::string),'')) AS BTC_COST_BASE_REV_CODE
--,ASSET_ALLOCATION_METHOD::string AS ASSET_ALLOCATION_METHOD                                                       --one distinct value 'N'
--,CAPITAL_EVENT_PROCESSING::string AS CAPITAL_EVENT_PROCESSING                                                     --one distinct value 'N'
--,CINT_RATE_SCH_ID::string AS CINT_RATE_SCH_ID                                                                     --column entirely NULL
--,CINT_ELIGIBLE_FLAG::string AS CINT_ELIGIBLE_FLAG                                                                 --one distinct value 'N'
--,CINT_STOP_DATE::string AS CINT_STOP_DATE                                                                         --column entirely NULL
,UPPER(NULLIF(TRIM(SYS_PROGRAM_FLAG::string),'')) AS SYS_PROGRAM_FLAG
,UPPER(NULLIF(TRIM(STRUCTURE_SHARING_CODE::string),'')) AS STRUCTURE_SHARING_CODE
--,ENABLE_TOP_TASK_CUSTOMER_FLAG::string AS ENABLE_TOP_TASK_CUSTOMER_FLAG                                           --one distinct value 'N'
--,ENABLE_TOP_TASK_INV_MTH_FLAG::string AS ENABLE_TOP_TASK_INV_MTH_FLAG                                             --one distinct value 'N'
,UPPER(NULLIF(TRIM(REVENUE_ACCRUAL_METHOD::string),'')) AS REVENUE_ACCRUAL_METHOD
,UPPER(NULLIF(TRIM(INVOICE_METHOD::string),'')) AS INVOICE_METHOD
--,PROJFUNC_ATTR_FOR_AR_FLAG::string AS PROJFUNC_ATTR_FOR_AR_FLAG                                                   --one distinct value 'N'
--,PJI_SOURCE_FLAG::string AS PJI_SOURCE_FLAG                                                                       --column entirely NULL
--,ALLOW_MULTI_PROGRAM_ROLLUP::string AS ALLOW_MULTI_PROGRAM_ROLLUP                                                 --one distinct value 'N'
--,PROJ_REQ_RES_FORMAT_ID::string AS PROJ_REQ_RES_FORMAT_ID                                                         --column entirely NULL
--,PROJ_ASGMT_RES_FORMAT_ID::string AS PROJ_ASGMT_RES_FORMAT_ID                                                     --column entirely NULL
--,FUNDING_APPROVAL_STATUS_CODE::string AS FUNDING_APPROVAL_STATUS_CODE                                             --column entirely NULL
FROM {{ref('prep_pa_projects_all')}}
QUALIFY ROW_NUMBER() OVER (PARTITION BY PROJECT_ID ORDER BY TO_TIMESTAMP_NTZ(LAST_UPDATE_DATE) DESC) = 1
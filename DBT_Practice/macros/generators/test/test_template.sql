{#
EXAMPLE DOCUMENTATION:

This test supports INTEGER, FLOAT and any value that can be wrapped between quotes in SQL such as STRING.

You can define this test in your .sql model file as follows.
The TABLE_KEY must be unique and will generally be the Surrogate Key (SK) of your DIMENSION or FACT table.
The tests value "unexpected_values" is mandatory to trigger this test.
You may define any number of columns and values to be tested.

This is the meta block example to be added to your model .sql file:

    meta = {
    'table_key': 'PROJECT_EVENT_UUID',
    'tests': {
      'unexpected_values':{
        'columns':{
            'NO_PROJET': "'1','2','3'",
            "NO_MEMO": "10,20,30"
          }
        }
      }    
    }

#}
{% macro generate_testname_ddl(warehouse,schedule,values,table,key,table_name,etl_event_detail_table,governance_db) %}
    {% set task_ddl_statements = [] %}
    {% for column, value in values.columns.items() %}
        {#
        Here the task name is being defined. This is not meant to be changed.
        All test tasks will be materialized in [ENV]_GOVERNANCE_DB.DATA_QUALITY schema.
        #}        
        {% set task_name = governance_db ~ '.DATA_QUALITY.TEST_' ~ table ~ '_UNEXPECTED_VALUES_' ~ column %}
        {#
        The merge_ddl_part_one macro is where the CREATE TASK and the beginning of the MERGE statement is defined.
        #}   
        {% set merge_ddl_part_one = generate_merge_part_one(task_name,schedule,warehouse,etl_event_detail_table)%}
        {% set create_task_sql %}
    {#
    This first part is the output of your source query that are considered as ACTIVE errors.
    #}    
    SELECT 
         md5(cast(CONCAT(CAST(OBJECT_CONSTRUCT(*) AS TEXT),CAST(NO_PROJET as TEXT)) as TEXT)) as ETL_EVENT_DETAIL_SK
        ,md5(cast(OBJECT_CONSTRUCT(*) AS TEXT)) as ETL_EVENT_KEY
        ,TEST_ENTERPRISE_SCHEMATIZE.PUBLIC.format_date_key(sysdate(),'YYYY-MM-DD HH24:MI:SS.FF') as EVENT_DATE_KEY
        {# This is where you should set an error code value, do not forget to define it in models/governance/data_quality/etl_event_description.sql as well #}
        ,-1 AS ETL_EVENT_DESCRIPTION_CODE
        ,sysdate() as EVENT_TIMESTAMP
        ,'{{table}}' as TABLE_KEY
        ,'{{column}}' as FIELD_KEY
        ,'{{key}}' as RECORD_SK_KEY
        ,{{key}} as RECORD_SK
        ,OBJECT_CONSTRUCT(table_name.*) as RECORD_CONTENT
        ,'ACTIVE' as ETL_EVENT_STATUS
        ,sysdate() as EFFECTIVE_START_TIMESTAMP
        ,null as EFFECTIVE_END_TIMESTAMP
    FROM {{table_name}}  table_name
    WHERE 
    {#
    This is where you set your condition.
    For example: {{column}} IN ('{{value}}')
    #}
UNION ALL
    {#
    This second part is to find the previously ACTIVE errors that are now resolved and should be marked as INACTIVE. 
    It does query in the ERROR table and look for records that are not in the first part of the query.
    It does flag these records as INACTIVE.
    #}   
        SELECT 
         T1.ETL_EVENT_DETAIL_SK AS ETL_EVENT_DETAIL_SK
        ,T1.ETL_EVENT_KEY AS ETL_EVENT_KEY
        ,TEST_ENTERPRISE_SCHEMATIZE.PUBLIC.format_date_key(sysdate(),'YYYY-MM-DD HH24:MI:SS.FF') as EVENT_DATE_KEY
        ,T1.ETL_EVENT_DESCRIPTION_CODE
        ,sysdate() as EVENT_TIMESTAMP
        ,T1.TABLE_KEY AS TABLE_KEY
        ,T1.FIELD_KEY AS FIELD_KEY
        ,T1.RECORD_SK_KEY as RECORD_SK_KEY
        ,T1.RECORD_SK AS RECORD_SK
        ,T1.RECORD_CONTENT AS RECORD_CONTENT
        ,'INACTIVE' AS ETL_EVENT_STATUS
        ,T1.EFFECTIVE_START_TIMESTAMP AS EFFECTIVE_START_TIMESTAMP
        ,sysdate() AS EFFECTIVE_END_TIMESTAMP
    FROM
        {{etl_event_detail_table}} T1
    LEFT JOIN 
    (
        SELECT 
            md5(cast(CONCAT(CAST(OBJECT_CONSTRUCT(*) AS TEXT),CAST(NO_PROJET as TEXT)) as TEXT)) as ETL_EVENT_DETAIL_SK
        FROM {{table_name}}  table_name
        WHERE {{column}} IN ('{{value}}')
    ) S1
    ON 
        T1.ETL_EVENT_DETAIL_SK = S1.ETL_EVENT_DETAIL_SK
    WHERE 
        S1.ETL_EVENT_DETAIL_SK is null AND T1.ETL_EVENT_STATUS <> 'INACTIVE' AND UPPER(T1.TABLE_KEY) = UPPER('{{table}}') AND UPPER(T1.FIELD_KEY) = UPPER('{{key}}') AND T1.ETL_EVENT_DESCRIPTION_CODE = 0 -- To replace 0 by code

        {% endset %}
        {#
        The merge_ddl_part_two macro is where all the merge boilerplate is defined.
        #}   
        {% set merge_ddl_part_two = generate_merge_part_two() %}
        {% set final_sql = merge_ddl_part_one ~ create_task_sql ~ merge_ddl_part_two %}
        {# You may uncomment the log statement to the ddl or your test task #}
        {#
        {{log(final_sql, info=True)}}
        #}
      {% do task_ddl_statements.append(final_sql) %}
      {#
      This append a statement to resume the task since if is suspended upon creation.
      #}  
      {% set resume_task_sql = "ALTER TASK IF EXISTS " ~ task_name ~ " RESUME;" %}
      {% do task_ddl_statements.append(resume_task_sql) %}
      {#
      This execute the task right away since tests are triggered once a day.
      This allows to have the first results right away.  
      {% set resume_task_sql = "EXECUTE TASK " ~ task_name ~ ";" %}
      #}
      {% do task_ddl_statements.append(resume_task_sql) %}
    {% endfor %}
{% endmacro %}
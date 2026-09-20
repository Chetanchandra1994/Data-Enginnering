{#
THIS TEST IS MEANT TO THE UNICITY OF A TABLE KEY (Surrogate Key) IN A TABLE
This test supports any value that can be wrapped between quotes in SQL such as STRING or INTEGER.

You can define this test in your .sql model file as follows.
The TABLE_KEY must be unique and will generally be the Surrogate Key (SK) of your DIMENSION or FACT table.
The tests value "unique_sk" is mandatory to trigger this test.
You may define any number of columns and values to be tested.

This is the meta block example to be added to your model .sql file:

    meta = {
    'table_key': 'PROJECT_EVENT_UUID',
    'tests': {
      'unique_sk':{}    
    }
  }

Additional comments and details on the logic can be found in test_template.sql
#}
{% macro generate_unique_sk_test_ddl(warehouse,schedule,table,key,table_name,etl_event_detail_table,governance_db) %}
    {% set task_ddl_statements = [] %}      
    {% set task_name = governance_db ~ '.DATA_QUALITY.TEST_' ~ table ~ '_UNIQUE_' ~ key %}
    {% set merge_ddl_part_one = generate_merge_part_one(task_name,schedule,warehouse,etl_event_detail_table)%}
    {% set create_task_sql %}
    (SELECT 
         md5(cast(CONCAT(CAST(UPPER('{{table}}') AS TEXT),CAST(table_name.{{key}} as TEXT)) as TEXT)) as ETL_EVENT_DETAIL_SK
        ,md5(cast(UPPER('{{table}}') AS TEXT)) as ETL_EVENT_KEY
        ,{{ target.name }}_ENTERPRISE_SCHEMATIZE.PUBLIC.format_date_key(sysdate(),'YYYY-MM-DD HH24:MI:SS.FF') as EVENT_DATE_KEY
        ,1000 AS ETL_EVENT_DESCRIPTION_CODE
        ,sysdate() as EVENT_TIMESTAMP
        ,UPPER('{{table}}') as TABLE_KEY
        ,UPPER('{{key}}') as FIELD_KEY
        ,UPPER('{{key}}') as RECORD_SK_KEY
        ,table_name.{{key}} as RECORD_SK
        ,null as RECORD_CONTENT
        ,'ACTIVE' as ETL_EVENT_STATUS
        ,sysdate() as EFFECTIVE_START_TIMESTAMP
        ,null as EFFECTIVE_END_TIMESTAMP
    FROM {{table_name}} table_name
    INNER JOIN
        (
            SELECT 
                {{key}}
                ,count(*) as count
            FROM {{table_name}}
            GROUP BY 1
            HAVING COUNT(*) > 1
        ) table_name_dupplicates
    ON table_name.{{key}} = table_name_dupplicates.{{key}}
    LIMIT 1)
UNION ALL
        (SELECT
         T1.ETL_EVENT_DETAIL_SK AS ETL_EVENT_DETAIL_SK
        ,T1.ETL_EVENT_KEY AS ETL_EVENT_KEY
        ,{{ target.name }}_ENTERPRISE_SCHEMATIZE.PUBLIC.format_date_key(sysdate(),'YYYY-MM-DD HH24:MI:SS.FF') as EVENT_DATE_KEY
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
    FROM {{etl_event_detail_table}} T1
    LEFT JOIN 
    (
        SELECT
             {{key}}
            ,count(*) as count
        FROM {{table_name}}
        GROUP BY 1
        HAVING COUNT > 1
    ) S1
    ON 
        T1.RECORD_SK = S1.{{key}}
    WHERE 
        S1.{{key}} is null AND T1.ETL_EVENT_STATUS <> 'INACTIVE' AND UPPER(T1.TABLE_KEY) = UPPER('{{table}}') AND UPPER(T1.FIELD_KEY) = UPPER('{{key}}') AND T1.ETL_EVENT_DESCRIPTION_CODE = 1000)     

    {% endset %}
    {% set merge_ddl_part_two = generate_merge_part_two() %}
    {% set final_sql = merge_ddl_part_one ~ create_task_sql ~ merge_ddl_part_two %}
    {# Remove comment to log the final SQL for debugging
    {{log(final_sql, info=True)}}
    #}
    {% do task_ddl_statements.append(final_sql) %}
    {% set resume_task_sql = "ALTER TASK IF EXISTS " ~ task_name ~ " RESUME;" %}
    {% do task_ddl_statements.append(resume_task_sql) %}
    {# If we want to run tests at deployment
    {% set resume_task_sql = "EXECUTE TASK " ~ task_name ~ ";" %}
    #}
    {% do task_ddl_statements.append(resume_task_sql) %} 

    {{ return(task_ddl_statements) }}
{% endmacro %}
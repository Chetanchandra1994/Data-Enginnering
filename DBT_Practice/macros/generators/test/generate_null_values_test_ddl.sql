{#
This test checks whether specified columns contain null values.

You can define this test in your .sql model file as follows.
The TABLE_KEY must be unique.
The tests value "null_values" is mandatory to trigger this test.
You may define any number of columns and values to be tested.

This is the meta block example to be added to your model .sql file:

    meta = {
        'table_key': 'PROJECT_EVENT_UUID',
        'tests': {
            'null_values':{
                'columns':[
                    'NO_PROJET',
                    'NO_MEMO'
                ]
            }
        }    
    }

Additional comments and details on the logic can be found in test_template.sql
#}
{% macro generate_null_values_test_ddl(warehouse,schedule,values,table,key,table_name,etl_event_detail_table,governance_db) %}
    {% set task_ddl_statements = [] %}

    {% for column in values['columns'] %}        
        {% set task_name = governance_db ~ '.DATA_QUALITY.TEST_' ~ table ~ '_NULL_VALUES_' ~ column %}
        {% set merge_ddl_part_one = generate_merge_part_one(task_name,schedule,warehouse,etl_event_detail_table)%}
        {% set create_task_sql %}
    SELECT 
         --md5(cast(CONCAT(CAST(OBJECT_CONSTRUCT(*) AS TEXT),CAST({{key}} as TEXT),CAST('NULL' as TEXT)) as TEXT)) as ETL_EVENT_DETAIL_SK
         md5(cast(CONCAT(CAST(UPPER('{{table}}') AS TEXT), CAST(UPPER('{{column}}') AS TEXT), CAST(UPPER({{key}}) as TEXT),CAST('NULL' as TEXT), CAST('3000' AS TEXT)) as TEXT)) as ETL_EVENT_DETAIL_SK
        ,md5(cast(OBJECT_CONSTRUCT(*) AS TEXT)) as ETL_EVENT_KEY
        ,{{ target.name }}_ENTERPRISE_SCHEMATIZE.PUBLIC.format_date_key(sysdate(),'YYYY-MM-DD HH24:MI:SS.FF') as EVENT_DATE_KEY
        ,3000 AS ETL_EVENT_DESCRIPTION_CODE
        ,sysdate() as EVENT_TIMESTAMP
        ,UPPER('{{table}}') as TABLE_KEY
        ,UPPER('{{column}}') as FIELD_KEY
        ,UPPER('{{key}}') as RECORD_SK_KEY
        ,{{key}}::string as RECORD_SK
        ,OBJECT_CONSTRUCT(table_name.*) as RECORD_CONTENT
        ,'ACTIVE' as ETL_EVENT_STATUS
        ,sysdate() as EFFECTIVE_START_TIMESTAMP
        ,null as EFFECTIVE_END_TIMESTAMP
    FROM {{table_name}}  table_name
    WHERE {{column}} IS NULL
UNION ALL
        SELECT 
         T1.ETL_EVENT_DETAIL_SK AS ETL_EVENT_DETAIL_SK
        ,T1.ETL_EVENT_KEY AS ETL_EVENT_KEY
        ,{{ target.name }}_ENTERPRISE_SCHEMATIZE.PUBLIC.format_date_key(sysdate(),'YYYY-MM-DD HH24:MI:SS.FF') as EVENT_DATE_KEY
        ,T1.ETL_EVENT_DESCRIPTION_CODE
        ,sysdate() as EVENT_TIMESTAMP
        ,T1.TABLE_KEY AS TABLE_KEY
        ,T1.FIELD_KEY AS FIELD_KEY
        ,T1.RECORD_SK_KEY as RECORD_SK_KEY
        ,T1.RECORD_SK::string AS RECORD_SK
        ,T1.RECORD_CONTENT AS RECORD_CONTENT
        ,'INACTIVE' AS ETL_EVENT_STATUS
        ,T1.EFFECTIVE_START_TIMESTAMP AS EFFECTIVE_START_TIMESTAMP
        ,sysdate() AS EFFECTIVE_END_TIMESTAMP
    FROM
        {{etl_event_detail_table}} T1
    LEFT JOIN 
    (
        SELECT 
            md5(cast(CONCAT(CAST(UPPER('{{table}}') AS TEXT), CAST(UPPER('{{column}}') AS TEXT), CAST(UPPER('{{key}}') as TEXT),CAST('NULL' as TEXT), CAST('3000' AS TEXT)) as TEXT)) as ETL_EVENT_DETAIL_SK
        FROM {{table_name}}  table_name
        WHERE {{column}} IS NULL
    ) S1
    ON 
        T1.ETL_EVENT_DETAIL_SK = S1.ETL_EVENT_DETAIL_SK
    WHERE 
        S1.ETL_EVENT_DETAIL_SK is null AND T1.ETL_EVENT_STATUS <> 'INACTIVE' AND UPPER(T1.TABLE_KEY) = UPPER('{{table}}') AND UPPER(T1.FIELD_KEY) = UPPER('{{key}}') AND T1.ETL_EVENT_DESCRIPTION_CODE = 3000

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
    {% endfor %}
    {{ return(task_ddl_statements) }}
{% endmacro %}
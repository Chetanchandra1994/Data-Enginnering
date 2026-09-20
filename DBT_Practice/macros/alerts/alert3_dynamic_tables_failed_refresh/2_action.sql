{% macro alert3_dynamic_tables_failed_refresh__action() %}
{% set environment = target.name %}
{% set prefix_email_integration = ('test' if target.name == 'local' else target.name) | upper %}
    {% set sql %}
    CALL SYSTEM$SEND_EMAIL(
        '{{ prefix_email_integration }}_ALERTS_EMAIL_INTEGRATION',
        '{{ var('alert_email_address') }}',
        'Dynamic tables are failing to refresh --- in environment {{environment}}',
        (SELECT coalesce(nullif(ARRAY_TO_STRING(ARRAY_AGG(name)::ARRAY, ','),''),'dynamic tables(s) not refreshing but not identified --- check INFORMATION_SCHEMA.ALERT_HISTORY in governance db') 
        FROM (
          SELECT concat(value:"state"::VARCHAR
                        , ' '
                        , resource_attributes:"snow.executable.type"::VARCHAR
                        , ' '
                        , resource_attributes:"snow.database.name"::VARCHAR 
                        , '.'
                        , resource_attributes:"snow.schema.name"::VARCHAR 
                        , '.'
                        ,  resource_attributes:"snow.executable.name"::VARCHAR
                        , ' at '
                        , timestamp::VARCHAR
                        ) as name
            FROM TABLE(RESULT_SCAN(SNOWFLAKE.ALERT.GET_CONDITION_QUERY_UUID()))
        )
        )
      )
    {% endset %}
    {{ return(sql) }}
{% endmacro %}
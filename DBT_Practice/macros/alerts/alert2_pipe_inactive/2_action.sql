{% macro alert2_pipe_inactive__action() %}
{% set environment = target.name %}
{% set prefix_email_integration = ('test' if target.name == 'local' else target.name) | upper %}
    {% set sql %}
     
      CALL SYSTEM$SEND_EMAIL(
        '{{ prefix_email_integration }}_ALERTS_EMAIL_INTEGRATION',
        '{{ var('alert_email_address') }}',
        'Pipe inactive --- in environment {{environment}}',
        (SELECT coalesce(nullif(ARRAY_TO_STRING(ARRAY_AGG(msg)::ARRAY, ','),''),'inactive pipes but not identified --- check INFORMATION_SCHEMA.ALERT_HISTORY in governance db') 
            FROM (SELECT concat(PIPE_NAME::VARCHAR, ' is in state ', DATA:"executionState"::VARCHAR, ' at ', CURRENT_TIMESTAMP()::VARCHAR) as msg
                  FROM TABLE(RESULT_SCAN(SNOWFLAKE.ALERT.GET_CONDITION_QUERY_UUID()))
                  )
        )
        )
    {% endset %}
    {{ return(sql) }}
{% endmacro %}
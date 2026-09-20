{% macro alert1_pipe_load_fail__action() %}
{% set environment = target.name %}
{% set prefix_email_integration = ('test' if target.name == 'local' else target.name) | upper %}
    {% set sql %}        
        
    CALL SYSTEM$SEND_EMAIL(
        '{{ prefix_email_integration }}_ALERTS_EMAIL_INTEGRATION',
        '{{ var('alert_email_address') }}',
        'Pipe Error - failed to load file(s) --- in {{ environment }}',
        (
            select
                coalesce(nullif(listagg(distinct(PIPE_CATALOG_NAME||'.'||PIPE_SCHEMA_NAME||'.'||PIPE_NAME||' @ '||PIPE_RECEIVED_TIME),'\n '),''),'failing pipe(s) not identified --- check INFORMATION_SCHEMA.ALERT_HISTORY in governance db') as FAILED_PIPES
            from 
                table(result_scan(SNOWFLAKE.ALERT.GET_CONDITION_QUERY_UUID()))
        )
        )
    
    {% endset %}
    {{ return(sql) }}
{% endmacro %}
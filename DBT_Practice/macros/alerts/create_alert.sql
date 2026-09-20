{% macro create_alert(condition_macro, action_macro, alert_name) %}
    {% set condition_sql = condition_macro() %}
    {% set action_sql = action_macro() %}
    {% set governance_db = get_governance_database() %}
    {% set environment = target.name | upper %}

    {% set sql %}
    CREATE OR REPLACE ALERT {{ governance_db }}.ALERTS.{{ environment }}_{{ alert_name }}
    WAREHOUSE = {{ var('task_warehouse') }}
    SCHEDULE = '60 minutes'
    IF (EXISTS(
        {{ condition_sql }}
        ))
    THEN
        {{ action_sql }}
    ;
    ALTER ALERT {{ governance_db }}.ALERTS.{{ environment }}_{{ alert_name }} RESUME;
    {% endset %}

    {% do return(sql) %}
{% endmacro %}

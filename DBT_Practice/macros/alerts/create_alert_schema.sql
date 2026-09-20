{% macro create_alert_schema() %}
    {% set governance_db = get_governance_database() %}
    {% set sql %}

    CREATE SCHEMA IF NOT EXISTS {{ governance_db }}.ALERTS;
   
    {% endset %}
    {{ return(sql) }}
{% endmacro %}
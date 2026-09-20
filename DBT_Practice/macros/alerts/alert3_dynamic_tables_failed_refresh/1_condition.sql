{% macro alert3_dynamic_tables_failed_refresh__condition() %}
{% if target.name == 'local' %}
  {% set environment = 'SANDBOX' %}
{% else %}
  {% set environment = target.name %}
{% endif %}  
  {% set sql %}
     SELECT * FROM SNOWFLAKE.TELEMETRY.EVENTS_VIEW
     WHERE resource_attributes:"snow.executable.type" = 'DYNAMIC_TABLE' 
     AND record_type='EVENT' 
     AND timestamp>= DATEADD(hours, -2, CURRENT_TIMESTAMP())
     AND resource_attributes:"snow.database.name" ilike '{{environment}}%'
     AND value:"state" not in ('SUCCEEDED')
  {% endset %}

  {{ return(sql) }}
{% endmacro %}
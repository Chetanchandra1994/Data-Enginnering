{% macro get_governance_database() %}
    {% if target.name == 'local' %}
        {{ return('SANDBOX_GOVERNANCE') }}
    {% elif target.name == 'test' %}
        {{ return('TEST_GOVERNANCE') }}
    {% elif target.name == 'preprod' %}
        {{ return('PREPROD_GOVERNANCE') }}
    {% elif target.name == 'prod' %}
        {{ return('PROD_GOVERNANCE') }}
    {% else %}
        {{ exceptions.raise_compiler_error("Unknown target name: " ~ target.name) }}
    {% endif %}
{% endmacro %}

{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}

        {{ default_schema }}

    {%- else -%}

        {{ custom_schema_name | trim }}

    {%- endif -%}
{%- endmacro %}

{% macro increment_cron_minute(cron_str) %}
  {# Split the cron string into parts (assuming standard 5-part cron) #}
  {% set parts = cron_str.split(' ') %}
  
  {% set current_min = parts[0] | int %}
  {% set current_hour = parts[1] | int %}
  
  {# Calculate new minute and determine if we need to carry over to the hour #}
  {% set new_min = (current_min + 1) % 60 %}
  
  {# If new_min is 0, it means we rolled over from 59, so increment hour #}
  {% if new_min == 0 %}
    {% set new_hour = (current_hour + 1) % 24 %}
  {% else %}
    {% set new_hour = current_hour %}
  {% endif %}

  {# Reconstruct the cron string (keeping Day, Month, and DOW the same) #}
  {% set new_cron = [new_min|string, new_hour|string, parts[2], parts[3], parts[4]] | join(' ') %}
  
  {{ return(new_cron) }}
{% endmacro %}
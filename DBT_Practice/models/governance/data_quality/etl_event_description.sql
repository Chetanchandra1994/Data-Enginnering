{{
  config(
    materialized="table",
    snowflake_warehouse= var('task_warehouse'),
    alias = "etl_event_description",
    schema= "data_quality"
  )
}}

SELECT * FROM (
  VALUES
    (1000, 'La valeur doit être unique', 'The value must be unique'),
    (2000, 'Valeur non attendue', 'Unexpected value'),
    (3000, 'Valeur null trouvée', 'Null value found')
) AS t (ETL_EVENT_DESCRIPTION_CODE, DESCRIPTION_FR, DESCRIPTION_EN)
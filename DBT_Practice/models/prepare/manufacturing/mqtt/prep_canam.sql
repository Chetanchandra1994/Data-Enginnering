{{
  config(
    materialized = "view",
    alias = "enterprise",
    schema='mqtt'
  )
}}

SELECT 
    DATA:routing_key::STRING as routing_key,
    DATA AS raw_body
FROM 
    {{('TEST_MANUFACTURING_LANDING' if target.name == 'test' else 'PROD_MANUFACTURING_LANDING' if target.name == 'prod')}}.MQTT.AMQ_TOPIC
WHERE UPPER(DATA:routing_key::STRING) LIKE 'enterprise%'
QUALIFY ROW_NUMBER() OVER ( PARTITION BY DATA ORDER BY file_last_modified DESC) = 1
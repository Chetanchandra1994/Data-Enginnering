{{
  config(
    materialized = "view",
    alias = "spbv1",
    schema='mqtt'
  )
}}

SELECT 
    DATA:routing_key::STRING as routing_key,
    DATA:spb_message_type::STRING as spb_message_type,
    DATA:spb_seq::INT as spb_seq,
    TO_TIMESTAMP(DATA:spb_timestamp::NUMBER, 3) as spb_timestamp,
    DATA:metric_name::STRING as metric_name,
    DATA:metric_datatype::INT as metric_datatype,
    TO_TIMESTAMP(DATA:metric_timestamp::NUMBER, 3) as metric_timestamp,
    DATA:metric_value::STRING as metric_value,
    DATA:is_decoded::BOOLEAN as is_decoded,
    DATA:raw_payload::STRING as raw_payload
FROM 
    {{('TEST_MANUFACTURING_LANDING' if target.name == 'test' else 'PROD_MANUFACTURING_LANDING' if target.name == 'prod')}}.MQTT.AMQ_TOPIC
WHERE UPPER(DATA:routing_key::STRING) LIKE 'SPBV1%'
QUALIFY ROW_NUMBER() OVER ( PARTITION BY
    DATA:routing_key::STRING,
    DATA:spb_message_type::STRING,
    DATA:spb_seq::INT,
    TO_TIMESTAMP(DATA:spb_timestamp::NUMBER, 3),
    DATA:metric_name::STRING,
    DATA:metric_datatype::INT,
    TO_TIMESTAMP(DATA:metric_timestamp::NUMBER, 3),
    DATA:metric_value::STRING,
    DATA:is_decoded:BOOLEAN
     ORDER BY file_last_modified DESC) = 1
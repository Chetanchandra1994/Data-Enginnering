{{
  config(
    materialized = "view",
    alias = "spbv1",
    schema='mqtt'
  )
}}

SELECT 
  routing_key,
  spb_message_type,
  spb_seq,
  spb_timestamp,
  metric_name,
  metric_datatype,
  metric_timestamp,
  metric_value,
  is_decoded,
  raw_payload
FROM 
  {{ ref ('prep_spBv1') }}
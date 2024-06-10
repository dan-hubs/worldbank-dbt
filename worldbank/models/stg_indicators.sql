{{ config(materialized='table') }}

SELECT * 
FROM {{ source('worldbank', 'raw_indicators') }}
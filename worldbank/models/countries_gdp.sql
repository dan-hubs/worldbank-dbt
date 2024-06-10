{{ config(materialized='table') }}

WITH cte AS (
    SELECT 
        "country.value" AS country	
        ,CAST(date AS INT) AS year
        ,value AS gdp
        -- ,LAG(value, 1) OVER (PARTITION BY "country.value" ORDER BY date) AS gdp_previous
        ,(value - LAG(value, 1) OVER (PARTITION BY "country.value" ORDER BY date)) 
            / LAG(value, 1) OVER (PARTITION BY "country.value" ORDER BY date) AS gdp_growth

    FROM {{ ref('stg_indicators') }}
)

SELECT 
	country
	,year
	,gdp
	,gdp_growth
	,MIN(gdp_growth) OVER (PARTITION BY country ORDER BY year ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS min_gdp_growth_since_2000
	,MAX(gdp_growth) OVER (PARTITION BY country ORDER BY year ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS max_gdp_growth_since_2000
FROM cte
WHERE year >= 2000
AND gdp IS NOT NULL 
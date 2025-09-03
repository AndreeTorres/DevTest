-- Part 3 of the challenge
-- KPIs with parametrizable date window [:start, :end]
WITH params AS (
  SELECT
    :'start'::date AS start_date,
    :'end'::date   AS end_date
),
win AS (
  SELECT r.*
  FROM public.raw_ads_spend r
  CROSS JOIN params p
  WHERE r.date >= p.start_date
    AND r.date <= p.end_date
),
agg_total AS (
  SELECT
    SUM(spend)::numeric(18,2)                AS spend,
    SUM(conversions)                          AS conversions,
    (SUM(conversions) * 100)::numeric(18,2)   AS revenue,
    CASE WHEN SUM(conversions) > 0
         THEN (SUM(spend)::numeric / NULLIF(SUM(conversions),0))
    END AS cac,
    CASE WHEN SUM(spend) > 0
         THEN ((SUM(conversions) * 100)::numeric / NULLIF(SUM(spend),0))
    END AS roas
  FROM win
),
agg_platform AS (
  SELECT
    platform,
    SUM(spend)::numeric(18,2)                AS spend,
    SUM(conversions)                          AS conversions,
    (SUM(conversions) * 100)::numeric(18,2)   AS revenue,
    CASE WHEN SUM(conversions) > 0
         THEN (SUM(spend)::numeric / NULLIF(SUM(conversions),0))
    END AS cac,
    CASE WHEN SUM(spend) > 0
         THEN ((SUM(conversions) * 100)::numeric / NULLIF(SUM(spend),0))
    END AS roas
  FROM win
  GROUP BY platform
)
-- 1) Period totals
SELECT
  'TOTAL'::text AS level,
  'ALL'::text   AS key,
  spend, conversions, revenue,
  ROUND(cac,2)  AS cac,
  ROUND(roas,2) AS roas
FROM agg_total

UNION ALL

-- 2) Breakdown by platform
SELECT
  'PLATFORM'::text AS level,
  platform         AS key,
  spend, conversions, revenue,
  ROUND(cac,2)  AS cac,
  ROUND(roas,2) AS roas
FROM agg_platform
ORDER BY level, key;

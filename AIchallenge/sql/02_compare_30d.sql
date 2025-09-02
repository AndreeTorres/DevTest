-- sql/02_compare_30d.sql

-- Define dates based on max date in dataset
WITH bounds AS (
  SELECT
    MAX(date) AS max_date,
    (MAX(date) - interval '30 days')::date AS cur_start,
    (MAX(date) - interval '60 days')::date AS prev_start
  FROM public.raw_ads_spend
),
-- Current 30 days
cur AS (
  SELECT
    ROUND(SUM(spend)::numeric,2)        AS spend,
    SUM(conversions)                    AS conversions
  FROM public.raw_ads_spend, bounds
  WHERE date > bounds.cur_start
    AND date <= bounds.max_date
),
-- Previous 30 days
prev AS (
  SELECT
    ROUND(SUM(spend)::numeric,2)        AS spend,
    SUM(conversions)                    AS conversions
  FROM public.raw_ads_spend, bounds
  WHERE date > bounds.prev_start
    AND date <= bounds.cur_start
),
-- Main metrics calculation
metrics AS (
  SELECT
    'cur_30d'::text AS period,
    spend,
    conversions,
    (conversions * 100)::numeric AS revenue,
    CASE WHEN conversions > 0 THEN spend / NULLIF(conversions,0) END AS cac,
    CASE WHEN spend > 0 THEN (conversions * 100)::numeric / NULLIF(spend,0) END AS roas
  FROM cur
  UNION ALL
  SELECT
    'prev_30d',
    spend,
    conversions,
    (conversions * 100)::numeric AS revenue,
    CASE WHEN conversions > 0 THEN spend / NULLIF(conversions,0) END AS cac,
    CASE WHEN spend > 0 THEN (conversions * 100)::numeric / NULLIF(spend,0) END AS roas
  FROM prev
)
SELECT
  m1.period,
  m1.spend,
  m1.conversions,
  ROUND(m1.cac,2)  AS cac,
  ROUND(m1.roas,2) AS roas,
  CASE WHEN m2.cac > 0 THEN ROUND(((m1.cac - m2.cac)/m2.cac*100)::numeric,2) END  AS delta_cac_pct,
  CASE WHEN m2.roas > 0 THEN ROUND(((m1.roas - m2.roas)/m2.roas*100)::numeric,2) END AS delta_roas_pct
FROM metrics m1
LEFT JOIN metrics m2
  ON (m1.period='cur_30d' AND m2.period='prev_30d')
ORDER BY m1.period;

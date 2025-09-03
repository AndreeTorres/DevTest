--Part 1

-- Base schema for the challenge: raw table + KPIs view

-- 1) Raw table with metadata and unique index for idempotency
CREATE TABLE IF NOT EXISTS public.raw_ads_spend (
  date         date        NOT NULL,
  platform     text        NOT NULL,
  account      text        NOT NULL,
  campaign     text        NOT NULL,
  country      text        NOT NULL,
  device       text        NOT NULL,
  spend        numeric(18,2) NOT NULL,
  clicks       integer     NOT NULL,
  impressions  bigint      NOT NULL,
  conversions  integer     NOT NULL,
  -- Metadata for data lineage
  load_date    timestamptz NOT NULL DEFAULT now(),
  source_file  text        NOT NULL,
  -- Natural key for idempotency
  CONSTRAINT raw_ads_spend_pk UNIQUE (date, platform, account, campaign, country, device)
);

-- Useful query indexes (optional but recommended)
CREATE INDEX IF NOT EXISTS idx_raw_ads_spend_date     ON public.raw_ads_spend(date);
CREATE INDEX IF NOT EXISTS idx_raw_ads_spend_platform ON public.raw_ads_spend(platform);
CREATE INDEX IF NOT EXISTS idx_raw_ads_spend_campaign ON public.raw_ads_spend(campaign);

-- 2) KPIs view (per row/dimension)
-- CAC = spend / conversions
-- ROAS = (revenue / spend) with revenue = conversions * 100
CREATE OR REPLACE VIEW public.core_ads_kpis AS
SELECT
  date,
  platform,
  account,
  campaign,
  country,
  device,
  spend,
  clicks,
  impressions,
  conversions,
  (conversions * 100)::numeric(18,2) AS revenue,
  CASE WHEN conversions > 0 THEN (spend::numeric / NULLIF(conversions,0)) ELSE NULL END AS cac,
  CASE WHEN spend > 0 THEN ((conversions * 100)::numeric / NULLIF(spend,0)) ELSE NULL END AS roas,
  load_date,
  source_file
FROM public.raw_ads_spend;



--Part 2

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


-- Part 3
-- KPIs with params 
-- Change here the start_date and end_date:
WITH params AS (
  SELECT
    DATE '1900-01-01' AS start_date,
    DATE '2100-12-31' AS end_date
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
    SUM(spend)::numeric(18,2)              AS spend,
    SUM(conversions)                        AS conversions,
    (SUM(conversions) * 100)::numeric(18,2) AS revenue,
    CASE WHEN SUM(conversions) > 0
      THEN (SUM(spend)::numeric / NULLIF(SUM(conversions),0)) END AS cac,
    CASE WHEN SUM(spend) > 0
      THEN ((SUM(conversions) * 100)::numeric / NULLIF(SUM(spend),0)) END AS roas
  FROM win
),
agg_platform AS (
  SELECT
    platform,
    SUM(spend)::numeric(18,2)              AS spend,
    SUM(conversions)                        AS conversions,
    (SUM(conversions) * 100)::numeric(18,2) AS revenue,
    CASE WHEN SUM(conversions) > 0
      THEN (SUM(spend)::numeric / NULLIF(SUM(conversions),0)) END AS cac,
    CASE WHEN SUM(spend) > 0
      THEN ((SUM(conversions) * 100)::numeric / NULLIF(SUM(spend),0)) END AS roas
  FROM win
  GROUP BY platform
)
-- 1) Totales + 2) Desglose
SELECT 'TOTAL' AS level, 'ALL' AS key, spend, conversions, revenue,
       ROUND(cac,2) AS cac, ROUND(roas,2) AS roas
FROM agg_total
UNION ALL
SELECT 'PLATFORM', platform, spend, conversions, revenue,
       ROUND(cac,2), ROUND(roas,2)
FROM agg_platform
ORDER BY level, key;



SELECT MIN(date), MAX(date), COUNT(*) FROM public.raw_ads_spend

WITH params AS (
  SELECT DATE '2025-01-01' AS start_date, DATE '2025-06-30' AS end_date
),
win AS (
  SELECT r.*
  FROM public.raw_ads_spend r
  CROSS JOIN params p
  WHERE r.date >= p.start_date AND r.date <= p.end_date
),
agg_total AS (
  SELECT
    SUM(spend)::numeric(18,2)              AS spend,
    SUM(conversions)                        AS conversions,
    (SUM(conversions) * 100)::numeric(18,2) AS revenue,
    CASE WHEN SUM(conversions) > 0 THEN (SUM(spend)::numeric / NULLIF(SUM(conversions),0)) END AS cac,
    CASE WHEN SUM(spend) > 0 THEN ((SUM(conversions) * 100)::numeric / NULLIF(SUM(spend),0)) END AS roas
  FROM win
),
agg_platform AS (
  SELECT
    platform,
    SUM(spend)::numeric(18,2)              AS spend,
    SUM(conversions)                        AS conversions,
    (SUM(conversions) * 100)::numeric(18,2) AS revenue,
    CASE WHEN SUM(conversions) > 0 THEN (SUM(spend)::numeric / NULLIF(SUM(conversions),0)) END AS cac,
    CASE WHEN SUM(spend) > 0 THEN ((SUM(conversions) * 100)::numeric / NULLIF(SUM(spend),0)) END AS roas
  FROM win
  GROUP BY platform
)
SELECT 'TOTAL' AS level, 'ALL' AS key, spend, conversions, revenue,
       ROUND(cac,2) AS cac, ROUND(roas,2) AS roas
FROM agg_total
UNION ALL
SELECT 'PLATFORM', platform, spend, conversions, revenue,
       ROUND(cac,2), ROUND(roas,2)
FROM agg_platform
ORDER BY level, key;



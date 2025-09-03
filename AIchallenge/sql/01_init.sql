
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

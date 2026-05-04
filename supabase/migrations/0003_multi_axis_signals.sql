-- ============================================================================
-- v3 — store the 3 AI-derived signal lists alongside each check.
--
-- Run after 0002_normalized_input.sql in Supabase dashboard → SQL Editor.
-- ============================================================================

alter table public.scam_checks
  add column if not exists linguistic_signals jsonb not null default '[]'::jsonb,
  add column if not exists cyber_signals      jsonb not null default '[]'::jsonb,
  add column if not exists social_tactics     jsonb not null default '[]'::jsonb;

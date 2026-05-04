-- ============================================================================
-- v4 — accept the new "content" target type (free-text scam analysis).
--
-- Run after 0003_multi_axis_signals.sql in Supabase dashboard → SQL Editor.
-- ============================================================================

alter table public.scam_checks
  drop constraint if exists scam_checks_target_check;

alter table public.scam_checks
  add constraint scam_checks_target_check
  check (target in ('phone', 'bankAccount', 'url', 'content'));

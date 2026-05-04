-- ============================================================================
-- Add normalized_input column for cross-format lookup.
-- Run after 0001_scam_checks.sql in Supabase dashboard → SQL Editor.
--
-- Normalization rules (kept in sync with LocalRiskService.normalize in Dart):
--   * phone / bankAccount  →  strip whitespace, dashes, parentheses, plus.
--   * url                  →  drop scheme + www + path, lowercased host only.
-- ============================================================================

alter table public.scam_checks
  add column if not exists normalized_input text;

-- Backfill existing rows with a best-effort lowercase + stripped value.
update public.scam_checks
set normalized_input = lower(regexp_replace(input, '[\s\-\(\)\+]', '', 'g'))
where normalized_input is null;

alter table public.scam_checks
  alter column normalized_input set not null;

create index if not exists scam_checks_norm_input_idx
  on public.scam_checks (target, normalized_input);

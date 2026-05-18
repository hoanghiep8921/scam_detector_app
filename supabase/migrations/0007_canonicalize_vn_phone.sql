-- Migration 0007: Canonicalize Vietnamese phone numbers to domestic 0-form.
-- Aligns both known_risks.normalized_value and scam_checks.normalized_input
-- with the Dart normalization in LocalRiskService._normalize:
--
--   +84 XX…  →  0XX…  (11 digits total: 84 + 9-digit subscriber)
--   +84 0XX… →  0XX…  (12 digits total: 84 + extra 0 + 9-digit subscriber)
--
-- Run AFTER 0006. Idempotent — safe to re-run.

-- ── Helper: normalize a raw phone string to canonical 0-form ──────────────
create or replace function public.normalize_phone_vn(raw text)
returns text
language sql
immutable
as $$
  select
    case
      when stripped ~ '^84[0-9]{9}$' then '0' || substr(stripped, 3)
      when stripped ~ '^840[0-9]{9}$' then '0' || substr(stripped, 4)
      else stripped
    end
  from (select regexp_replace(raw, '[^0-9]', '', 'g') as stripped) s;
$$;

-- ── Backfill known_risks: fix rows whose normalized_value is stale ───────
update public.known_risks
set normalized_value = normalize_phone_vn(value)
where type = 'phone'
  and normalized_value != normalize_phone_vn(value);

-- ── Backfill scam_checks: normalize existing rows ────────────────────────
update public.scam_checks
set normalized_input = normalize_phone_vn(input)
where target = 'phone'
  and normalized_input != normalize_phone_vn(input);

-- ── Trigger helper: auto-normalize on INSERT / UPDATE for future rows ────
create or replace function public.trigger_normalize_known_risks_phone()
returns trigger
language plpgsql
as $$
begin
  if new.type = 'phone' then
    new.normalized_value := public.normalize_phone_vn(new.value);
  end if;
  return new;
end;
$$;

-- Attach trigger if not already present (idempotent).
drop trigger if exists trg_normalize_known_risks_phone on public.known_risks;

create trigger trg_normalize_known_risks_phone
  before insert or update of value on public.known_risks
  for each row
  execute function public.trigger_normalize_known_risks_phone();

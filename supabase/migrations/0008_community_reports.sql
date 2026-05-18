-- Migration 0008: Community scam reports table.
-- Allows any user to report a phone number / URL / bank account as scam.
-- Run AFTER 0007. Idempotent — safe to re-run.

create table if not exists public.community_reports (
  id uuid primary key default gen_random_uuid(),
  device_id text not null,              -- reporter device (anonymous UUID)
  target text not null,                 -- 'phone' | 'url' | 'bankAccount'
  reported_value text not null,         -- the reported phone / URL / account
  normalized_value text not null,       -- canonical form for dedupe
  description text,                     -- user's free-text explanation
  created_at timestamptz not null default now(),
  -- Prevent exact duplicate reports from same device.
  unique (device_id, normalized_value)
);

-- RLS: allow anonymous read + insert (demo mode — tighten before prod).
alter table public.community_reports enable row level security;

create policy "anon read community reports"
  on public.community_reports for select
  using (true);

create policy "anon insert community reports"
  on public.community_reports for insert
  with check (true);

-- Index for lookup by normalized value (used in scam_check_provider).
create index if not exists idx_community_reports_normalized
  on public.community_reports (normalized_value);

-- Phone normalization helper: strip non-digits, canonicalize VN form.
create or replace function public.normalize_report_value(raw text, target text)
returns text
language sql
immutable
as $$
  select
    case
      when target = 'phone' then
        case
          when stripped ~ '^84[0-9]{9}$' then '0' || substr(stripped, 3)
          when stripped ~ '^840[0-9]{9}$' then '0' || substr(stripped, 4)
          else stripped
        end
      when target = 'url' then
        lower(regexp_replace(regexp_replace(raw, '^https?://', ''), '^www\.', ''))
      else
        regexp_replace(raw, '[\s\-()]', '', 'g')
    end
  from (select regexp_replace(raw, '[^0-9]', '', 'g') as stripped) s;
$$;

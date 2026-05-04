-- ============================================================================
-- Scam Detector — schema for cloud-synced check history.
--
-- Run once in Supabase dashboard → SQL Editor.
-- ============================================================================

create table if not exists public.scam_checks (
  id            uuid          primary key,
  device_id     text          not null,
  target        text          not null check (target in ('phone', 'bankAccount', 'url')),
  input         text          not null,
  risk_level    text          not null check (risk_level in ('safe', 'suspicious', 'scam', 'unknown')),
  risk_score    int           not null check (risk_score between 0 and 100),
  summary       text          not null default '',
  reasons       jsonb         not null default '[]'::jsonb,
  psychological jsonb         not null default '{}'::jsonb,
  checked_at    timestamptz   not null default now()
);

create index if not exists scam_checks_device_idx
  on public.scam_checks (device_id, checked_at desc);

create index if not exists scam_checks_input_idx
  on public.scam_checks (input);

-- ----------------------------------------------------------------------------
-- Row Level Security
--
-- Demo policies (anonymous app, no Supabase Auth). Acceptable trade-off:
--   * Anyone with the anon key can read all rows. This is fine for the demo
--     but you should add Auth + per-user policies before going to production.
--   * Insert / delete are open. Client filters its own rows by device_id.
-- ----------------------------------------------------------------------------
alter table public.scam_checks enable row level security;

drop policy if exists "anon read"   on public.scam_checks;
drop policy if exists "anon insert" on public.scam_checks;
drop policy if exists "anon delete" on public.scam_checks;

create policy "anon read"
  on public.scam_checks for select
  to anon
  using (true);

create policy "anon insert"
  on public.scam_checks for insert
  to anon
  with check (true);

create policy "anon delete"
  on public.scam_checks for delete
  to anon
  using (true);

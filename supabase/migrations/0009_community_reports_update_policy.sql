-- Migration 0009: Add UPDATE RLS policy for community_reports upsert.
-- UPSERT (INSERT ... ON CONFLICT DO UPDATE) requires both INSERT and UPDATE
-- privileges under RLS. Migration 0008 only granted INSERT — causing all
-- upserts to silently fail. Run AFTER 0008.

create policy "anon update community reports"
  on public.community_reports for update
  using (true)
  with check (true);

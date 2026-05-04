-- Allow the demo (anon) role to delete rows from public.known_risks so the
-- in-app database browser can offer a "Xoá" action. Tighten to authenticated
-- moderators only before going live.

drop policy if exists "anon delete known_risks" on public.known_risks;
create policy "anon delete known_risks" on public.known_risks
  for delete to anon using (true);

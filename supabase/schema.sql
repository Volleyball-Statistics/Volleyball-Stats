-- Volleyball Stats: shared data for a small, fixed group (the owner + assistants).
--
-- Run once in the Supabase dashboard: SQL Editor -> New query -> paste -> Run.
-- Safe to re-run: every statement is idempotent.
--
-- Access is gated twice:
--   1. Sign-ups are disabled in Authentication settings, so only accounts the
--      owner creates by hand can sign in at all.
--   2. Every read and write below also requires the signed-in email to be on
--      public.allowed_emails. Removing an email takes effect on the next request,
--      even before that person's sign-in token expires.
--
-- The publishable key in the app is public by design; it grants nothing on its
-- own. Never put the secret / service_role key in the app.

-- ---------------------------------------------------------------- allowlist
create table if not exists public.allowed_emails (
  email text primary key check (email = lower(email))
);
alter table public.allowed_emails enable row level security;
revoke all on public.allowed_emails from anon, authenticated;
-- No policies and no grants on purpose: the app can neither read nor change
-- this list.
-- Edit it here in the SQL Editor or in Table Editor.

-- >>> EDIT THESE THREE LINES, then run. Lower-case emails. <<<
insert into public.allowed_emails (email) values
  ('you@example.com'),
  ('assistant1@example.com'),
  ('assistant2@example.com')
on conflict do nothing;

create or replace function public.is_member()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.allowed_emails a
    where a.email = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;
revoke all on function public.is_member() from public, anon;
grant execute on function public.is_member() to authenticated;

-- ---------------------------------------------------------------- records
-- One row per team, player, match or stat event. `data` mirrors the app's own
-- object for that thing. Deletes are tombstones (deleted = true) so a device
-- that was offline learns about them instead of re-uploading the row.
create table if not exists public.records (
  kind       text        not null check (kind in ('team', 'player', 'match', 'event')),
  id         text        not null,
  data       jsonb       not null,
  deleted    boolean     not null default false,
  updated_at timestamptz not null default now(),
  updated_by uuid        default auth.uid(),
  primary key (kind, id)
);
create index if not exists records_updated_at on public.records (updated_at);

-- The server stamps every write, so "what changed since I last looked" never
-- depends on a phone's clock.
create or replace function public.records_touch()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  new.updated_by := auth.uid();
  return new;
end;
$$;
drop trigger if exists records_touch on public.records;
create trigger records_touch before insert or update on public.records
  for each row execute function public.records_touch();

alter table public.records enable row level security;

drop policy if exists "members read"   on public.records;
drop policy if exists "members insert" on public.records;
drop policy if exists "members update" on public.records;
create policy "members read"   on public.records for select to authenticated using (public.is_member());
create policy "members insert" on public.records for insert to authenticated with check (public.is_member());
create policy "members update" on public.records for update to authenticated
  using (public.is_member()) with check (public.is_member());
-- No delete policy: rows are only ever tombstoned.

revoke all on public.records from anon;
grant select, insert, update on public.records to authenticated;

-- ---------------------------------------------------------------- realtime
-- Live updates between phones. Realtime applies the same "members read" policy,
-- so only allowlisted accounts receive changes.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'records'
  ) then
    alter publication supabase_realtime add table public.records;
  end if;
end;
$$;

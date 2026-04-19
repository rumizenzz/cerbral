-- Cerbral minimal account schema.
-- Stores only what Cerbral Cloud needs to route the user back to their
-- own brain repo after sign-in. Sessions, messages, embeddings, and
-- anything the AI learns live in the user's GitHub repo, never here.

create table if not exists public.profiles (
  user_id        uuid primary key references auth.users(id) on delete cascade,
  email          text not null,
  github_handle  text,
  brain_repo_url text,
  created_at     timestamptz default now(),
  updated_at     timestamptz default now()
);

alter table public.profiles enable row level security;

drop policy if exists "self-read"   on public.profiles;
drop policy if exists "self-upsert" on public.profiles;
drop policy if exists "self-update" on public.profiles;

create policy "self-read"   on public.profiles
  for select using (auth.uid() = user_id);

create policy "self-upsert" on public.profiles
  for insert with check (auth.uid() = user_id);

create policy "self-update" on public.profiles
  for update using (auth.uid() = user_id);

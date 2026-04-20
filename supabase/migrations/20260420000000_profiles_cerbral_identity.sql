-- Cerbral identity columns on profiles.
--
-- Written when the user completes the OS1-style first-boot onboarding
-- in Cerbral OS (the desktop app). These six fields are the
-- *account-linked metadata* that restores the user's Cerbral across
-- devices — install Cerbral OS on a second Mac, sign in, and your
-- Cerbral's name / pronouns / voice come back.
--
-- The INTIMATE bits of the onboarding (the diagnostic Q&A answers)
-- do NOT go here. Those live in the user's own GitHub cerbral-brain
-- repo as a markdown note in `knowledge/learned/`. Galactuz never
-- stores the answers — only the labels.
--
-- `cerbral_name`            — chosen display name for the user's AI
-- `cerbral_pronouns`        — "she/her" or "he/him" (v1 is binary,
--                             faithful to the movie per product direction)
-- `cerbral_voice_gender`    — "female" or "male" (drives voice pool)
-- `cerbral_voice_id`        — Kokoro voice id (e.g. "af_bella")
-- `cerbral_narrator_voice_id` — Kokoro voice id used for the setup
--                               narrator; same for all users, stored
--                               so we can change the default without
--                               retroactively rewriting existing rows
-- `cerbral_onboarded_at`    — when the ceremony completed; the
--                             presence of this timestamp is what
--                             tells a fresh install "don't re-run
--                             the ceremony"
--
-- RLS: no new policies needed. The existing self-read + self-update
-- policies from 20260419010000_profiles.sql cover these columns via
-- RLS inheritance (policies are row-level, not column-level).

alter table public.profiles
  add column if not exists cerbral_name              text,
  add column if not exists cerbral_pronouns          text,
  add column if not exists cerbral_voice_gender      text,
  add column if not exists cerbral_voice_id          text,
  add column if not exists cerbral_narrator_voice_id text,
  add column if not exists cerbral_onboarded_at      timestamptz;

-- Handy index for any future "how many users have completed
-- onboarding" admin query, and for ordering rows by freshness.
create index if not exists profiles_cerbral_onboarded_idx
  on public.profiles (cerbral_onboarded_at desc nulls last);

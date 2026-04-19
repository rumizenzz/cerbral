-- Cerbral tunnel columns.
--
-- Cerbral Web (browser at cerbral.com) needs to reach the user's local
-- Ollama to actually run their AI. Cerbral Desktop runs a small auth
-- proxy on localhost:11435 and tunnels it out with cloudflared; on
-- start, it writes the public URL + shared Bearer secret here so
-- Cerbral Web can pick them up from the user's own profile.
--
-- Nothing the AI generates passes through Cerbral Cloud — these
-- columns are metadata only. RLS already scopes read/write to the
-- owning user via the self-read/self-update policies defined in
-- 20260419010000_profiles.sql.
--
-- The public URL rotates every time cloudflared reconnects (free
-- tier), so the desktop app overwrites ollama_tunnel_url on every
-- tunnel_start. The secret is generated once per install and persists.

alter table public.profiles
  add column if not exists ollama_tunnel_url        text,
  add column if not exists ollama_tunnel_secret     text,
  add column if not exists ollama_tunnel_updated_at timestamptz;

-- Handy index for any future admin/audit reads that filter by freshness.
create index if not exists profiles_tunnel_updated_idx
  on public.profiles (ollama_tunnel_updated_at desc nulls last);

#!/usr/bin/env bash
# Build-time generator for site/config.js.
# Runs during Netlify builds (see netlify.toml `[build].command`) and
# pulls secrets from Netlify's environment variable store into the
# single client-side config file the static site reads on load.
#
# Why not commit site/config.js? It's .gitignored to keep public keys
# out of the open-source repo. The SUPABASE_ANON_KEY is technically
# safe to expose (RLS gates access), but we still don't ship it via
# git — that way Cerbral's deployed config belongs to Netlify, and
# anyone forking the repo can drop their own.

set -euo pipefail

: "${SUPABASE_URL:?SUPABASE_URL not set on Netlify}"
: "${SUPABASE_ANON_KEY:?SUPABASE_ANON_KEY not set on Netlify}"

OUT="site/config.js"

cat > "$OUT" <<EOF
// Auto-generated at Netlify build time by scripts/build-config.sh.
// Real values come from Netlify env vars — don't commit this file.
window.CERBRAL_CONFIG = {
  SUPABASE_URL: '${SUPABASE_URL}',
  SUPABASE_ANON_KEY: '${SUPABASE_ANON_KEY}',
};
EOF

echo "Wrote $OUT (SUPABASE_URL=${SUPABASE_URL})"

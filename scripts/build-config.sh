#!/usr/bin/env bash
# Build-time generator for site/config.js.
# Runs during Netlify builds (see netlify.toml `[build].command`) and
# pulls secrets from Netlify's environment variable store into the
# single client-side config file the static site reads on load.
#
# Why not commit site/config.js? It's .gitignored so the Supabase keys
# aren't hard-coded into the cerbral-public repo (which holds the
# marketing site). The SUPABASE_ANON_KEY is technically safe to expose
# since RLS gates access, but keeping it out of git means our deployed
# config belongs to Netlify, rotations don't require a code push, and
# anyone else running their own fork drops their own.

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

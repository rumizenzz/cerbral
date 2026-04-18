#!/usr/bin/env bash
# cerbral-mirror.sh
# Mirrors ~/.hermes/ state (skills, memory, SOUL, sanitized config) into the
# Cerbral brain repo, commits any changes, and pushes.
#
# Called by:
#   - the Hermes post-session hook (~/.hermes/hooks/post-session.sh)
#   - the hourly launchd safety-net (~/Library/LaunchAgents/com.cerbral.mirror.plist)
#   - manually (bash ~/cerbral/scripts/cerbral-mirror.sh)
#
# Never versioned: secrets, lockfiles, live state, caches, source clones.

set -euo pipefail

CERBRAL_HOME="${CERBRAL_HOME:-$HOME/cerbral}"
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
LOG_FILE="$CERBRAL_HOME/scripts/mirror.log"

mkdir -p "$CERBRAL_HOME/brain" "$(dirname "$LOG_FILE")"

ts() { date -Iseconds; }
log() { echo "[$(ts)] $*" >> "$LOG_FILE"; }

log "mirror start"

rsync -a --delete \
  --exclude='audio_cache/' \
  --exclude='image_cache/' \
  --exclude='sandboxes/' \
  --exclude='hermes-agent/' \
  --exclude='bin/' \
  --exclude='sessions/' \
  --exclude='checkpoints/' \
  --exclude='logs/' \
  --exclude='images/' \
  --exclude='cron/' \
  --exclude='pairing/' \
  --exclude='whatsapp/' \
  --exclude='state.db' \
  --exclude='state.db-shm' \
  --exclude='state.db-wal' \
  --exclude='*.lock' \
  --exclude='*.tmp' \
  --exclude='*.bak' \
  --exclude='.env' \
  --exclude='.env.bak' \
  --exclude='auth.json' \
  --exclude='auth.lock' \
  --exclude='processes.json' \
  --exclude='.DS_Store' \
  --exclude='.update_check' \
  --exclude='.hermes_history' \
  --exclude='.skills_prompt_snapshot.json' \
  --exclude='interrupt_debug.log' \
  --exclude='config.yaml' \
  "$HERMES_HOME/" "$CERBRAL_HOME/brain/"

if [ -f "$HERMES_HOME/config.yaml" ]; then
  python3 - "$HERMES_HOME/config.yaml" "$CERBRAL_HOME/brain/config.yaml" <<'PY'
import re, sys, pathlib
src, dst = sys.argv[1], sys.argv[2]
text = pathlib.Path(src).read_text()
patterns = [
    (r'(["\']?(?:api_key|token|secret|password|auth|bearer)["\']?\s*:\s*["\']?)([A-Za-z0-9_\-.]{12,})(["\']?)', r'\1${REDACTED}\3'),
    (r'(sk-[A-Za-z0-9_\-]{20,})',                 r'${REDACTED_OPENAI_KEY}'),
    (r'(ghp_[A-Za-z0-9]{30,})',                   r'${REDACTED_GH_PAT}'),
    (r'(xox[baprs]-[A-Za-z0-9\-]{10,})',          r'${REDACTED_SLACK_TOKEN}'),
    (r'(AKIA[0-9A-Z]{16})',                       r'${REDACTED_AWS_KEY}'),
    (r'(\d{9,10}:[A-Za-z0-9_\-]{35})',            r'${REDACTED_TG_BOT_TOKEN}'),
]
for pat, repl in patterns:
    text = re.sub(pat, repl, text)
pathlib.Path(dst).write_text(text)
PY
fi

cd "$CERBRAL_HOME"

# Regenerate the always-current INDEX.md summary before committing, so the
# index always reflects the post-sync state of the brain.
if [ -x "$CERBRAL_HOME/scripts/cerbral-index.sh" ]; then
  "$CERBRAL_HOME/scripts/cerbral-index.sh" >> "$LOG_FILE" 2>&1 || \
    log "WARN: cerbral-index.sh failed (non-fatal)"
fi

git add -A

if git diff --cached --quiet; then
  log "no changes, skipping commit"
  exit 0
fi

SUMMARY="$(git diff --cached --stat | tail -1 | sed 's/^ *//')"
COMMIT_MSG="brain: sync $(ts) — $SUMMARY"
git commit -m "$COMMIT_MSG" >> "$LOG_FILE" 2>&1
log "committed: $COMMIT_MSG"

if git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' >/dev/null 2>&1; then
  if git push >> "$LOG_FILE" 2>&1; then
    log "pushed"
  else
    log "push failed (non-fatal; will retry next cycle)"
  fi
else
  log "no upstream tracking set; skipping push"
fi

log "mirror done"

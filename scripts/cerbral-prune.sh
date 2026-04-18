#!/usr/bin/env bash
# cerbral-prune.sh
# Solves the "agent files make my disk full" problem.
#
# The brain (skills, memory, knowledge) is already safely mirrored to your
# private Git repo by cerbral-mirror.sh. Session transcripts, sandbox
# workspaces, checkpoints, and caches are runtime debris — they're the
# bulk of agent-generated local disk usage, and they don't need to live on
# your disk forever.
#
# This script deletes that debris when your disk gets full.
#
# Safe defaults (all configurable via env):
#   - Runs only when free disk space drops below threshold (default 20 GB)
#   - Requires the mirror to be up to date (no uncommitted brain changes)
#   - Dry-run by default; requires --apply to actually delete
#   - Deletes sessions/ older than $CERBRAL_PRUNE_SESSION_DAYS (default 30)
#   - Deletes checkpoints/ older than $CERBRAL_PRUNE_CKPT_DAYS (default 7)
#   - Deletes sandboxes/ inactive for > $CERBRAL_PRUNE_SANDBOX_DAYS (default 14)
#   - Deletes audio_cache/, image_cache/, logs/, interrupt_debug.log unconditionally
#
# Usage:
#   cerbral-prune.sh                     # report only
#   cerbral-prune.sh --apply             # actually delete
#   CERBRAL_PRUNE_THRESHOLD_GB=50 ./cerbral-prune.sh --apply
#   cerbral-prune.sh --force --apply     # skip free-space check, always prune

set -euo pipefail

CERBRAL_HOME="${CERBRAL_HOME:-$HOME/cerbral}"
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
THRESHOLD_GB="${CERBRAL_PRUNE_THRESHOLD_GB:-20}"
SESSION_DAYS="${CERBRAL_PRUNE_SESSION_DAYS:-30}"
CKPT_DAYS="${CERBRAL_PRUNE_CKPT_DAYS:-7}"
SANDBOX_DAYS="${CERBRAL_PRUNE_SANDBOX_DAYS:-14}"
LOG_FILE="$CERBRAL_HOME/scripts/prune.log"

APPLY=0
FORCE=0
for arg in "$@"; do
  case "$arg" in
    --apply) APPLY=1 ;;
    --force) FORCE=1 ;;
    -h|--help)
      sed -n '2,30p' "$0"
      exit 0
      ;;
  esac
done

mkdir -p "$(dirname "$LOG_FILE")"
ts() { date -Iseconds; }
log() { echo "[$(ts)] $*" | tee -a "$LOG_FILE"; }

# --- 1. Check free disk space on the volume containing $HOME ------------------
FREE_KB="$(df -Pk "$HOME" | awk 'NR==2 {print $4}')"
FREE_GB=$(( FREE_KB / 1024 / 1024 ))
log "free space on $(df -P "$HOME" | awk 'NR==2 {print $6}'): ${FREE_GB} GB"

if [ "$FORCE" -eq 0 ] && [ "$FREE_GB" -ge "$THRESHOLD_GB" ]; then
  log "above threshold (${THRESHOLD_GB} GB), nothing to do"
  exit 0
fi

if [ "$FORCE" -eq 0 ]; then
  log "below threshold — pruning"
fi

# --- 2. Require mirror up-to-date before deleting anything --------------------
if [ -d "$CERBRAL_HOME/.git" ]; then
  cd "$CERBRAL_HOME"
  if ! git diff --quiet || ! git diff --cached --quiet; then
    log "ABORT: brain repo has uncommitted changes. Run cerbral-mirror.sh first."
    exit 1
  fi
  if git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' >/dev/null 2>&1; then
    AHEAD="$(git rev-list --count '@{upstream}..HEAD' 2>/dev/null || echo 0)"
    if [ "$AHEAD" -gt 0 ]; then
      log "WARN: brain repo has $AHEAD unpushed commits; pushing before prune."
      git push || { log "push failed; aborting prune"; exit 1; }
    fi
  fi
else
  log "WARN: $CERBRAL_HOME is not a git repo; skipping safety check (not recommended)."
fi

# --- 3. Prune --------------------------------------------------------------
prune_dir() {
  local path="$1" desc="$2"
  if [ ! -d "$path" ]; then return 0; fi
  local size
  size="$(du -sh "$path" 2>/dev/null | awk '{print $1}')"
  if [ "$APPLY" -eq 1 ]; then
    log "DELETE $desc ($path, $size)"
    rm -rf "$path"
    mkdir -p "$path"
  else
    log "would delete $desc ($path, $size)"
  fi
}

prune_older_than() {
  local path="$1" days="$2" desc="$3"
  if [ ! -d "$path" ]; then return 0; fi
  local files
  files="$(find "$path" -mindepth 1 -maxdepth 1 -mtime "+${days}" 2>/dev/null)"
  if [ -z "$files" ]; then
    log "nothing in $desc older than ${days} days"
    return 0
  fi
  local count
  count="$(echo "$files" | wc -l | tr -d ' ')"
  if [ "$APPLY" -eq 1 ]; then
    log "DELETE $count items in $desc older than ${days} days"
    echo "$files" | xargs -I{} rm -rf "{}"
  else
    log "would delete $count items in $desc older than ${days} days"
  fi
}

prune_older_than "$HERMES_HOME/sessions"    "$SESSION_DAYS" "sessions/"
prune_older_than "$HERMES_HOME/checkpoints" "$CKPT_DAYS"   "checkpoints/"
prune_older_than "$HERMES_HOME/sandboxes"   "$SANDBOX_DAYS" "sandboxes/"

prune_dir "$HERMES_HOME/audio_cache" "audio_cache"
prune_dir "$HERMES_HOME/image_cache" "image_cache"

if [ -f "$HERMES_HOME/interrupt_debug.log" ]; then
  if [ "$APPLY" -eq 1 ]; then
    : > "$HERMES_HOME/interrupt_debug.log"
    log "truncated interrupt_debug.log"
  else
    log "would truncate interrupt_debug.log"
  fi
fi

# Trim large logs instead of deleting (keep last 1MB)
if [ -d "$HERMES_HOME/logs" ]; then
  find "$HERMES_HOME/logs" -name "*.log" -size +10M 2>/dev/null | while read -r logf; do
    if [ "$APPLY" -eq 1 ]; then
      tail -c 1048576 "$logf" > "$logf.tmp" && mv "$logf.tmp" "$logf"
      log "trimmed $logf to 1MB"
    else
      log "would trim $logf to 1MB"
    fi
  done
fi

# Report new free space
FREE_KB_NEW="$(df -Pk "$HOME" | awk 'NR==2 {print $4}')"
FREE_GB_NEW=$(( FREE_KB_NEW / 1024 / 1024 ))
log "free space after prune: ${FREE_GB_NEW} GB (was ${FREE_GB} GB)"

if [ "$APPLY" -eq 0 ]; then
  log "DRY RUN complete. Re-run with --apply to actually delete."
fi

#!/usr/bin/env bash
# cerbral-restore.sh
# Disaster recovery: given a clone of your cerbral-brain repo, reconstruct
# ~/.hermes/ state (skills, memory, SOUL.md, config.yaml with placeholders
# rendered from environment/.cerbral-secrets.env). Default is --dry-run.
#
# Usage:
#   cerbral-restore.sh                 # dry run, lists what would change
#   cerbral-restore.sh --apply         # actually write to ~/.hermes/
#   CERBRAL_HOME=/path ./cerbral-restore.sh --apply

set -euo pipefail

CERBRAL_HOME="${CERBRAL_HOME:-$HOME/cerbral}"
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
SECRETS_FILE="${CERBRAL_SECRETS:-$HOME/.cerbral-secrets.env}"

APPLY=0
if [ "${1:-}" = "--apply" ]; then APPLY=1; fi

if [ ! -d "$CERBRAL_HOME/brain" ]; then
  echo "ERROR: $CERBRAL_HOME/brain not found. Clone your cerbral-brain repo first." >&2
  exit 1
fi

if [ "$APPLY" -eq 1 ] && [ -d "$HERMES_HOME" ] && [ -n "$(ls -A "$HERMES_HOME" 2>/dev/null)" ]; then
  echo "WARNING: $HERMES_HOME already exists and is non-empty."
  echo "This will rsync brain/ contents over it, potentially overwriting files."
  read -p "Continue? (type YES to proceed): " CONFIRM
  if [ "$CONFIRM" != "YES" ]; then
    echo "Aborted."
    exit 1
  fi
fi

mkdir -p "$HERMES_HOME"

RSYNC_OPTS="-a"
if [ "$APPLY" -eq 0 ]; then
  RSYNC_OPTS="$RSYNC_OPTS --dry-run -v"
  echo "=== DRY RUN (no changes will be made). Re-run with --apply to write. ==="
fi

rsync $RSYNC_OPTS "$CERBRAL_HOME/brain/" "$HERMES_HOME/"

if [ "$APPLY" -eq 1 ] && [ -f "$CERBRAL_HOME/brain/config.yaml" ]; then
  if [ -f "$SECRETS_FILE" ]; then
    set -a
    # shellcheck source=/dev/null
    source "$SECRETS_FILE"
    set +a
    envsubst < "$CERBRAL_HOME/brain/config.yaml" > "$HERMES_HOME/config.yaml"
    echo "Rendered config.yaml with secrets from $SECRETS_FILE"
  else
    echo "NOTE: $SECRETS_FILE not found — config.yaml still contains \${REDACTED_*} placeholders."
    echo "      Create that file with the real values before running hermes."
  fi
fi

if [ "$APPLY" -eq 1 ]; then
  echo "Restore complete. Start hermes to verify."
else
  echo "Dry run complete. Re-run with --apply to actually restore."
fi

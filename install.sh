#!/usr/bin/env bash
# Cerbral installer.
# One-command bootstrap: creates your private cerbral-brain repo on GitHub,
# installs Hermes Agent + Ollama if missing, pulls a local model, seeds your
# knowledge directory from a starter, wires the sync hooks.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/rumizenzz/cerbral/main/install.sh | bash
#   (or) ./install.sh
#
# Env vars (all optional):
#   CERBRAL_HOME        — where your brain lives locally. Default: $HOME/cerbral
#   CERBRAL_REPO_NAME   — GitHub repo name for your brain. Default: cerbral-brain
#   CERBRAL_MODEL       — Ollama model tag to pull as default. Default: hermes3:3b
#   CERBRAL_STARTER     — starter knowledge repo to clone. Default: (empty seed)
#   CERBRAL_NO_LAUNCHD  — if set, skip installing the hourly launchd plist.

set -euo pipefail

CERBRAL_HOME="${CERBRAL_HOME:-$HOME/cerbral}"
CERBRAL_REPO_NAME="${CERBRAL_REPO_NAME:-cerbral-brain}"
CERBRAL_MODEL="${CERBRAL_MODEL:-hermes3:3b}"
CERBRAL_STARTER="${CERBRAL_STARTER:-}"
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"

# Source URLs for scripts (to be pinned to a release tag in v1.0).
CERBRAL_RAW="https://raw.githubusercontent.com/rumizenzz/cerbral/main"

say()  { printf '\033[1;36m[cerbral]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[cerbral]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m[cerbral]\033[0m %s\n' "$*" >&2; exit 1; }

need() { command -v "$1" >/dev/null 2>&1 || die "missing required tool: $1"; }

say "Cerbral installer"
say "------------------"

# --- 1. Check prerequisites ----------------------------------------------------
say "Checking prerequisites..."
need git
need curl
need python3
need rsync

if ! command -v gh >/dev/null 2>&1; then
  die "GitHub CLI (gh) not found. Install: https://cli.github.com — then re-run."
fi
if ! gh auth status >/dev/null 2>&1; then
  say "GitHub CLI not authenticated. Running 'gh auth login'..."
  gh auth login
fi

# --- 2. Install Ollama if missing ---------------------------------------------
if ! command -v ollama >/dev/null 2>&1; then
  say "Ollama not found. Install from https://ollama.com (brew install ollama, or download the .dmg), then re-run."
  die "Ollama required."
fi

# Make sure Ollama is up.
if ! curl -sSf http://localhost:11434/api/version >/dev/null 2>&1; then
  warn "Ollama server not responding at 11434. Start Ollama, then re-run."
  die "Ollama server unreachable."
fi

# --- 3. Install Hermes Agent if missing ----------------------------------------
if ! command -v hermes >/dev/null 2>&1; then
  say "Hermes Agent not found. Installing via Nous Research install script..."
  curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
fi
command -v hermes >/dev/null 2>&1 || die "Hermes install failed."

# --- 4. Pull the default model -------------------------------------------------
say "Pulling model: $CERBRAL_MODEL (this can take a few minutes)..."
ollama pull "$CERBRAL_MODEL"

# --- 5. Create the local brain directory ---------------------------------------
if [ -d "$CERBRAL_HOME" ] && [ -n "$(ls -A "$CERBRAL_HOME" 2>/dev/null)" ]; then
  warn "$CERBRAL_HOME already exists and is non-empty. Skipping scaffold to avoid overwriting."
else
  say "Creating brain directory at $CERBRAL_HOME"
  mkdir -p "$CERBRAL_HOME"/{brain,knowledge,scripts}
fi

# --- 6. Seed knowledge/ from a starter (optional) ------------------------------
if [ -n "$CERBRAL_STARTER" ]; then
  say "Seeding knowledge from starter: $CERBRAL_STARTER"
  git clone --depth 1 "$CERBRAL_STARTER" "$CERBRAL_HOME/knowledge-seed"
  cp -R "$CERBRAL_HOME/knowledge-seed/"* "$CERBRAL_HOME/knowledge/" 2>/dev/null || true
  rm -rf "$CERBRAL_HOME/knowledge-seed"
else
  say "No starter specified; creating empty knowledge/ with domain subdirs."
  mkdir -p "$CERBRAL_HOME/knowledge"/{general,projects,personal}
  cat > "$CERBRAL_HOME/knowledge/README.md" <<'MD'
# Your knowledge

Drop markdown files in here organized by domain. The agent finds and uses
them via the `knowledge-router` skill in your brain.

For example:
- `projects/project-name.md` — anything about a specific project
- `general/preferences.md` — how you like things done
- `personal/bio.md` — facts about you the agent should know
MD
fi

# --- 7. Download scripts -------------------------------------------------------
say "Downloading scripts..."
curl -fsSL "$CERBRAL_RAW/scripts/cerbral-mirror.sh"  -o "$CERBRAL_HOME/scripts/cerbral-mirror.sh"
curl -fsSL "$CERBRAL_RAW/scripts/cerbral-restore.sh" -o "$CERBRAL_HOME/scripts/cerbral-restore.sh"
curl -fsSL "$CERBRAL_RAW/PRINCIPLES.md" -o "$CERBRAL_HOME/PRINCIPLES.md"
chmod +x "$CERBRAL_HOME/scripts"/*.sh

# Simple README in the user's brain repo.
if [ ! -f "$CERBRAL_HOME/README.md" ]; then
  cat > "$CERBRAL_HOME/README.md" <<'MD'
# My Cerbral brain

This is my private Cerbral brain. It contains my agent's accumulated skills,
memory, and knowledge — everything my personal AI has learned about my world,
growing over time.

Installed via https://github.com/rumizenzz/cerbral.

## Restore on a new machine

```bash
git clone git@github.com:<me>/cerbral-brain.git ~/cerbral
~/cerbral/scripts/cerbral-restore.sh             # dry run
~/cerbral/scripts/cerbral-restore.sh --apply     # actually restore
```
MD
fi

# --- 8. Download .gitignore ---------------------------------------------------
if [ ! -f "$CERBRAL_HOME/.gitignore" ]; then
  curl -fsSL "$CERBRAL_RAW/templates/.gitignore" -o "$CERBRAL_HOME/.gitignore" || \
    cat > "$CERBRAL_HOME/.gitignore" <<'GI'
brain/state.db*
brain/sessions/
brain/sandboxes/
brain/audio_cache/
brain/image_cache/
brain/*.lock
brain/auth.json
brain/.env
brain/.env.*
**/.DS_Store
scripts/*.log
.cerbral-secrets*
GI
fi

# --- 9. Init local git + create remote private repo ---------------------------
cd "$CERBRAL_HOME"
if [ ! -d .git ]; then
  git init -b main
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  say "Creating private GitHub repo: $CERBRAL_REPO_NAME"
  gh repo create "$CERBRAL_REPO_NAME" --private --source . --remote origin --push=false
fi

# --- 10. Configure Hermes to use local Ollama ---------------------------------
say "Configuring Hermes to use local Ollama (model: $CERBRAL_MODEL)..."
if [ -f "$HERMES_HOME/config.yaml" ]; then
  cp "$HERMES_HOME/config.yaml" "$HERMES_HOME/config.yaml.pre-cerbral.bak"
fi
python3 - "$HERMES_HOME/config.yaml" "$CERBRAL_MODEL" <<'PY'
import sys, pathlib
try:
    import yaml
except ImportError:
    print("PyYAML not available; falling back to raw edit (may miss nested keys).", file=sys.stderr)
    yaml = None

cfg_path = pathlib.Path(sys.argv[1])
model = sys.argv[2]
cfg_path.parent.mkdir(parents=True, exist_ok=True)
if yaml and cfg_path.exists():
    data = yaml.safe_load(cfg_path.read_text()) or {}
    data.setdefault("model", {})
    data["model"]["default"]  = model
    data["model"]["provider"] = "openai"
    data["model"]["base_url"] = "http://localhost:11434/v1"
    cfg_path.write_text(yaml.safe_dump(data, sort_keys=False))
else:
    # Minimal config if none existed or yaml not installed.
    cfg_path.write_text(f"""model:
  default: {model}
  provider: openai
  base_url: http://localhost:11434/v1
""")
PY

# --- 11. Install post-session hook --------------------------------------------
mkdir -p "$HERMES_HOME/hooks"
cat > "$HERMES_HOME/hooks/post-session.sh" <<HOOK
#!/usr/bin/env bash
exec "$CERBRAL_HOME/scripts/cerbral-mirror.sh"
HOOK
chmod +x "$HERMES_HOME/hooks/post-session.sh"

# --- 12. Install launchd safety-net (macOS only, opt-out via CERBRAL_NO_LAUNCHD)
if [ "$(uname)" = "Darwin" ] && [ -z "${CERBRAL_NO_LAUNCHD:-}" ]; then
  PLIST="$HOME/Library/LaunchAgents/com.cerbral.mirror.plist"
  cat > "$PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>com.cerbral.mirror</string>
  <key>ProgramArguments</key>
  <array>
    <string>$CERBRAL_HOME/scripts/cerbral-mirror.sh</string>
  </array>
  <key>StartInterval</key><integer>3600</integer>
  <key>StandardOutPath</key><string>$CERBRAL_HOME/scripts/mirror.log</string>
  <key>StandardErrorPath</key><string>$CERBRAL_HOME/scripts/mirror.log</string>
  <key>RunAtLoad</key><false/>
</dict>
</plist>
PLIST
  launchctl unload "$PLIST" 2>/dev/null || true
  launchctl load   "$PLIST"
fi

# --- 13. First mirror + push --------------------------------------------------
say "Running first mirror..."
"$CERBRAL_HOME/scripts/cerbral-mirror.sh" || warn "first mirror reported non-zero (often fine for a fresh repo)."

cd "$CERBRAL_HOME"
if git rev-parse --quiet --verify HEAD >/dev/null 2>&1; then
  git push -u origin main 2>&1 || warn "push failed (non-fatal — run 'cd $CERBRAL_HOME && git push' manually to retry)."
else
  # No commits yet (nothing changed). Create a scaffold commit so the repo isn't empty.
  git add -A
  git commit -m "Initial Cerbral brain scaffold" --allow-empty
  git push -u origin main
fi

say "Done."
say "Your private brain repo: https://github.com/$(gh api user -q .login)/$CERBRAL_REPO_NAME"
say "Start Hermes: 'hermes' — sessions will commit to your brain automatically."

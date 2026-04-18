# Cerbral architecture

## The core idea

**Separate reasoning from knowledge.** A small local model does the
reasoning. Your knowledge, skills, and memory — the things that make an AI
"yours" — live in a Git repo you own. Over time the repo grows; the model
stays small. Intelligence is orchestrated, not stored.

## Layers

### 1. Inference (your choice)

- **Local runtime** — Ollama (recommended), llama.cpp, LM Studio, MLX.
  Runs on your machine. Private. Offline-capable.
- **Hosted API** — OpenAI, Anthropic, OpenRouter, any OpenAI-compatible
  endpoint Hermes supports. Use if you want frontier capability or your
  hardware is weak.

Cerbral doesn't care which. The brain repo is identical either way.

### 2. Agent loop (Hermes Agent)

Hermes Agent provides:

- Skill system — reusable procedures the agent loads on demand.
- Memory system — cross-session persistent memory (`MEMORY.md`, `USER.md`).
- MCP tool support — standard protocol for tools the agent can call.
- Hook system — scripts that run on session start/end.
- Persona (SOUL.md) — personality calibration.

Cerbral does not replace Hermes. It adds a layer on top: the idea that
Hermes's entire state should live in a Git repo instead of an opaque app
folder.

### 3. Persistence (Cerbral's contribution)

- **`cerbral-mirror.sh`** — after every session (via Hermes post-session
  hook) and hourly (via launchd/systemd), rsyncs relevant parts of
  `~/.hermes/` into `$CERBRAL_HOME/brain/`, sanitizes config.yaml (strips
  secrets), commits any changes, and pushes to your private
  `cerbral-brain` repo on GitHub.
- **`cerbral-restore.sh`** — on a new machine, clones your brain repo,
  rsyncs `brain/` back into `~/.hermes/`, renders config.yaml placeholders
  from a local secrets file. Your agent picks up exactly where it left off.
- **`cerbral-prune.sh`** — when local disk drops below a threshold,
  deletes session transcripts, sandbox directories, and caches that are
  already safely mirrored. Prevents the "agent files filled my disk" bug.

### 4. Knowledge (yours to seed)

`$CERBRAL_HOME/knowledge/` is a folder of markdown files you write about
your domains. A skill called `knowledge-router` tells the agent when and
where to read them. Pick a starter at install time, or start empty.

Hermes does not RAG over markdown automatically; knowledge is discovered
via the skill system. A skill's `SKILL.md` describes when to invoke (by
keyword match on the prompt) and how (by reading specific files).

## Why Git as the backend

- **Versioning for free.** Every state is committed, rollback-able.
- **Portable.** Clone to any machine; tooling is already there.
- **Distributable.** Push to GitHub, GitLab, Gitea, or self-host. Same
  semantics everywhere.
- **Inspectable.** `git log` shows your agent's learning history.
- **Forkable.** Want to branch an experimental persona? `git branch`.
- **Secure enough.** Private repos, SSH auth, familiar security model.

## Why NOT Git (honest)

- Not designed for terabytes of binary files. Large files need Git LFS or
  git-annex. Cerbral v0.1 is designed around small-file workloads
  (markdown, skill files, memory files — kilobytes to megabytes).
- Sync isn't real-time. The hook fires on session end; worst case, an
  hour elapses before the launchd safety-net runs. Acceptable for the
  "agent learnings" workload; not acceptable for "live collaborative
  editing," which isn't Cerbral's use case.
- Concurrent write conflicts. Two machines writing to the same brain repo
  will merge-conflict. v0.1 assumes a single-writer model; v1.0 may add
  explicit multi-machine strategies.

## File layout

```
$CERBRAL_HOME/
├── brain/                  ← mirror of ~/.hermes/ (skills, memory, SOUL, sanitized config)
│   ├── skills/
│   ├── memories/
│   ├── SOUL.md
│   ├── config.yaml         ← with ${REDACTED_*} placeholders
│   └── hooks/
├── knowledge/              ← your markdown, organized by domain
│   ├── pcc/
│   ├── kdp/
│   └── ...
├── scripts/
│   ├── cerbral-mirror.sh
│   ├── cerbral-restore.sh
│   └── cerbral-prune.sh
├── bin/
│   └── cerbral             ← CLI wrapper (usually symlinked into PATH)
├── .gitignore
├── PRINCIPLES.md
└── README.md

$HOME/.hermes/              ← Hermes's canonical runtime dir (unchanged by Cerbral)
├── hooks/post-session.sh   ← calls cerbral-mirror.sh
└── ...

$HOME/.cerbral-secrets.env  ← local-only; never versioned; rendered into config.yaml on restore
```

## Flow: a typical session

1. You run `hermes`.
2. Hermes loads config from `~/.hermes/config.yaml` (which points at your
   chosen backend — Ollama on localhost, an API key, etc.).
3. You have a conversation. Hermes uses skills, updates memory, writes to
   `state.db`, creates sandboxes for code execution.
4. You exit. Hermes fires its `post-session.sh` hook.
5. The hook calls `cerbral-mirror.sh`, which rsyncs the important parts of
   `~/.hermes/` to `$CERBRAL_HOME/brain/`, sanitizes config, commits, and
   pushes.
6. Hourly, the launchd job runs the mirror again as a safety net.
7. Nightly (or whenever you choose), `cerbral prune` sweeps session
   transcripts, sandboxes, and caches older than their thresholds —
   only after confirming the mirror is up to date.

## Restore on a new machine

```bash
git clone git@github.com:<you>/cerbral-brain.git ~/cerbral
cp ~/.cerbral-secrets.env.template ~/.cerbral-secrets.env
# edit ~/.cerbral-secrets.env with your real tokens
~/cerbral/scripts/cerbral-restore.sh --apply
hermes   # agent picks up with all your skills, memory, and knowledge intact
```

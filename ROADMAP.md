# Cerbral AI Roadmap

A realistic, honest path from today's v0.1 through the desktop app and
beyond. Timelines are "once someone is working on this focused." Nothing
here is a guarantee; everything here is directional.

## v0.1 — shipped (April 2026)

What's live today:

- [x] One-command installer (`install.sh`) — creates user's private
  `cerbral-brain` repo, wires Hermes + Ollama, installs hooks.
- [x] `cerbral-mirror.sh` — session-end + hourly sync of the brain to
  GitHub. Sanitizes secrets, regenerates `INDEX.md`, commits, pushes.
- [x] `cerbral-restore.sh` — disaster recovery, `--dry-run` default.
- [x] `cerbral-prune.sh` — deletes ephemeral local state when disk is
  full. Requires up-to-date mirror before deleting.
- [x] `cerbral-index.sh` — always-current summary of the full brain,
  local even when content is pruned.
- [x] `cerbral` CLI — sync / push / restore / prune / index / status /
  logs / upgrade.
- [x] Two skills shipped: `knowledge-router` (domain routing) and
  `self-awareness` (Cerbral AI knows its own architecture) plus
  `netlify-deploy` (Cerbral AI can publish static sites).
- [x] Disk-space watchdog launchd job (`com.cerbral.prune-watchdog`) —
  auto-prunes every 10 minutes when free space drops below threshold.
- [x] MIT license, PRINCIPLES.md, CONTRIBUTING.md, docs/architecture.md.
- [x] Landing page deployed at https://cerbral.netlify.app.
- [x] `manifest.json` — recommended-models-per-hardware-tier catalog.

## v0.2 — polish + correctness (2–4 weeks)

- [ ] **Debounced mid-session mirror** — sync every 5 minutes during
  long sessions OR every N tool calls, whichever comes first. Not
  per-call (too slow, noisy git history), not only session-end (loses
  state on crash).
- [ ] **Hardware-tier auto-detection** in installer — pick default
  model based on detected RAM / GPU / platform.
- [ ] **Starter-repo picker** in installer — user chooses from a
  curated list at install time.
- [ ] **Signed git commits** via GPG or SSH — optional but recommended
  default for trust.
- [ ] **`cerbral-index.sh` upgrade** — include git commit hashes so
  Cerbral AI can cite specific versions.
- [ ] **Cross-platform parity** — Linux systemd unit equivalent of the
  launchd plists, Windows WSL notes.
- [ ] **Better sanitization** — deeper scan for secrets in skill files,
  not just `config.yaml`.
- [ ] **Telegraphed failure modes** — when GitHub is unreachable,
  queue commits locally and flush on next online cycle.

## v0.3 — starter ecosystem (4–6 weeks)

- [ ] **`cerbral-starters` GitHub org** with curated starter repos:
  `starter-general`, `starter-developer`, `starter-researcher`,
  `starter-writer`, `starter-firearms-pcc`, etc.
- [ ] **Starter contribution flow** — clear CONTRIBUTING per starter,
  PR template, quality gate ("why this starter is worth shipping").
- [ ] **Starter browser** — `cerbral starter list` / `cerbral starter
  install <name>` in the CLI.
- [ ] **`cerbral-skills` registry** — community-contributed skills that
  understand Cerbral's Git-backed architecture.

## v1.0 — desktop app foundation (4–8 weeks)

See [cerbral-desktop](https://github.com/rumizenzz/cerbral-desktop).

- [x] Tauri v2 scaffold (shipped).
- [ ] **Menu bar app** with status + quick actions (sync, prune,
  index, open brain).
- [ ] **Onboarding wizard** — GitHub auth, model picker, starter
  picker, first-run tutorial.
- [ ] **Native chat UI** — markdown rendering, streaming tokens,
  attachments.
- [ ] **Auto-updater** via Tauri's updater (opt-in only — Principle #3).
- [ ] **Signed, notarized macOS `.dmg`** — requires Apple Developer
  cert ($99/yr). First distributable build.
- [ ] **Homebrew cask** — `brew install --cask cerbral-ai`.

## v1.1+ — cross-platform (2–4 weeks after v1.0)

- [ ] Windows installer (MSI or NSIS) via Tauri's bundler.
- [ ] Linux AppImage + `.deb` + `.rpm`.
- [ ] Flathub submission.

## v2.0+ — ecosystem depth (open-ended)

- [ ] **In-app starter marketplace** — browse and install starter repos
  without leaving the app.
- [ ] **Skill installer with preview** — review a skill's `SKILL.md`
  before adding it to your brain.
- [ ] **Backup browser** — navigate your brain repo's git history
  visually, restore specific skills/memories from past commits.
- [ ] **Multi-device coherence** — explicit merge/conflict UX when a
  user runs Cerbral on multiple machines against the same brain.
- [ ] **Integrations** — Obsidian sync, Readwise import, Apple Notes
  export. Each optional, each preserving local-first ownership.

## "Storage-aware local cache, remote truth" layer (v2.0+ design)

The hardest, most valuable feature on the horizon. Builds on top of
`cerbral-prune.sh` + INDEX.md to let users have:

- Every file they own (documents, media, project notes that are safe to
  include) indexed as part of their Cerbral AI.
- Local disk footprint bounded by their configured threshold (e.g.,
  "never exceed 30GB on this machine").
- Files still appear to exist locally; Cerbral AI fetches them on
  demand from the remote Git repo when opened.

Candidate implementations: Git LFS, git-annex, or a custom File Provider
extension on macOS. This is weeks-to-months of design + build work. Not
in the critical path for v1.0; explicitly flagged as a future milestone
so it doesn't get forgotten.

## What won't happen

Some things are explicitly out of scope per `PRINCIPLES.md`:

- **Hosted Cerbral-as-a-service.** We don't run any servers. Your
  brain lives on your machine + your GitHub. That's the whole pitch.
- **Telemetry / analytics.** Zero. Not even anonymous. Period.
- **Subscription model.** Cerbral AI is MIT. Free forever. If someone
  wants to sell a hosted alternative or a premium skin, they can fork.
- **License changes.** No BUSL, no commercial add-ons in this repo.

## Contribution priorities

If you want to help and don't know where to start:

1. **Test the installer on a non-macOS platform** and file issues.
2. **Write a starter repo** for a domain you know well (firearms,
   cooking, homesteading, academic research, trading, fiction writing —
   anything specific enough to be useful).
3. **Write a skill** that understands `$CERBRAL_HOME/knowledge/` and
   makes Cerbral AI smarter in a specific domain.
4. **Audit the sanitization code** in `cerbral-mirror.sh` for missing
   secret patterns.
5. **Write cross-platform equivalents** of the launchd plists.

Open an issue before starting anything non-trivial.

## Status beacon

- Public repo: https://github.com/rumizenzz/cerbral
- Private brain (example): https://github.com/rumizenzz/cerbral-brain
- Desktop app: https://github.com/rumizenzz/cerbral-desktop
- Landing page: https://cerbral.netlify.app
- Principles: [PRINCIPLES.md](./PRINCIPLES.md)

Updated 2026-04-18.

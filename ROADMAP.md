# Cerbral Roadmap

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
  `self-awareness` (Cerbral knows its own architecture) plus
  `netlify-deploy` (Cerbral can publish static sites).
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
  Cerbral can cite specific versions.
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

Desktop app source is closed — Cerbral OS is proprietary by Galactuz.
Public distributions (.dmg) live at
[cerbral-releases](https://github.com/rumizenzz/cerbral-releases).

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

## v0.4–v1.0 — the "truly personal AI" layer

Everything that makes Cerbral feel like *your* AI specifically, as
opposed to a generic chat assistant. Most of this is skills + hooks +
memory structure on top of what's already shipped — no new engine
required.

- [ ] **Personalized session-start greeting.** `session_start` hook
  reads `brain/memories/USER.md` + time-of-day + last-session summary.
  Drops a greeting like "Good morning, Rumi. Yesterday you were
  debugging the sync hook; the hourly mirror pushed 14 commits while
  you slept."
- [ ] **Time-aware context.** Detect morning / afternoon / evening /
  late night from local clock. Infer "just woke up" from session-gap
  heuristics (>6h since last turn + it's now 6–10am). Adjust tone
  accordingly — crisp in the morning, warmer in the evening.
- [ ] **Task recommendations on login.** A skill that reads recent
  activity across your projects (git log of your repos,
  `brain/memories/MEMORY.md` recent entries, pending TODOs in your
  files) and proposes "what's next" at session start. Not pushy — a
  collapsible suggestion block the user can ignore.
- [ ] **Morning briefs (Routine).** Hermes supports scheduled routines.
  At your configured wake time, Cerbral assembles: overnight agent
  work summary, calendar snapshot (if integrated), unreplied
  messages (if integrated), top 3 priorities distilled from MEMORY.md.
  Delivered via notification, session, or email depending on
  preference.
- [ ] **Overnight agent mode (`cerbral agent daemon`).** User queues
  tasks before bed ("draft these 3 emails, analyze this CSV, read
  these arXiv papers and extract the methodology sections"). The
  daemon runs Hermes in Auto mode with a task queue, reports results
  in the morning brief. Built on the same `run_cerbral` subprocess
  pattern the desktop app already uses.
- [ ] **Sub-agent swarming (already spec'd, this milestone activates
  it).** Cerbral Agent learns when to spawn Explore / Plan / Review
  sub-agents based on task decomposition signals. Same pattern Claude
  Code uses via its Agent tool, backed by Hermes's native
  `delegation` toolset.
- [ ] **Rich personal facts.** USER.md evolves a structured section:
  name, pronouns, where they live, what they eat (dietary
  restrictions, favorite cuisines), clothing preferences, media
  taste, work rhythm. Agent asks gentle clarifying questions over
  time rather than a big upfront form. Never pushed to the internet.
- [ ] **Proactive recognition.** "Noticed you opened the PCC book
  repo — want me to pick up where you left off yesterday?" Triggered
  by file-system / git events the agent subscribes to via a watcher
  skill.

The architecture for all of this already exists. Hermes has skills,
memory, hooks, routines, delegation. The brain repo has memories and
USER.md. What's missing is a **well-curated set of skills that
synthesize these primitives** into the experience of a truly personal
AI. That's the v0.4→v1.0 work.

## v0.5 — Memory Import (from other AI providers)

One of the highest-leverage features for adoption: let users **import
their past conversations from ChatGPT / Claude / Gemini / Grok** into
their Cerbral brain, so day-one Cerbral already knows them from their
prior AI usage.

Modeled on Google Gemini's "Import memory" feature, but the imported
data goes to the user's own `cerbral-brain` repo — not to any Cerbral
server (because there isn't one).

- [ ] **"Import memory" tab** in the desktop app, accessible from
  Settings or the left sidebar. Two paths:
  1. **Paste a summary response** — user runs a preset prompt in
     ChatGPT / Claude / Gemini / Grok ("go through our past
     conversations and sum up what you know about me…"), pastes the
     response; we commit it to `brain/memories/imported-from-<provider>.md`.
  2. **Upload a `.zip` export** — user drops their full conversation
     export (up to 5 GB, or whatever local disk allows). Pre-flight
     check: verify disk space available. We extract, parse the
     provider-specific format (OpenAI data export JSON / Anthropic
     export JSON / etc.), and commit conversations as indexed
     markdown under `brain/imports/<provider>/<YYYY-MM>/`.
- [ ] **Required "which provider?" field** — user must pick from
  ChatGPT / Claude / Gemini / Grok / other before importing, so
  future context knows the origin.
- [ ] **INDEX.md summarizes the imports** — always-current summary
  includes "Imported 1,200 ChatGPT conversations (2023–2026), 340
  Claude conversations, 12 Gemini…" so Cerbral knows what it has.
  Agent doesn't volunteer the import origin unless explicitly asked
  (avoids "I see you came from ChatGPT" weirdness).
- [ ] **UI matches Claude Desktop's design** — clean, minimal, clear
  progress + confirmation states. Strictly better than Google's
  version because your data stays yours.

Scope honesty: supporting every provider's export format is a
multi-week effort (each has a different JSON schema). Start with
OpenAI + Anthropic exports (documented, stable schemas), add others
as contributors submit parsers.

## v0.6 — Cerbral Account (email + GitHub OAuth, nothing else)

Goal: a **signup / login flow that onboards a user to the desktop
app** while still owning none of their data. The account is just a
row in Supabase (email + hashed password + GitHub OAuth link) —
exactly what you'd need for a newsletter list and nothing more. All
AI data lives in the user's own GitHub repo.

- [ ] **Supabase account store** — email, hashed password (Supabase
  handles this), linked GitHub account (via OAuth). NOTHING else.
  No conversation data, no memories, no files.
- [ ] **GitHub OAuth** — OAuth app with tight scopes (only `repo`
  for creating/pushing the user's own `cerbral-brain` repo). Cerbral
  team NEVER sees the user's repo contents — OAuth token stays on
  the user's machine after the initial handshake.
- [ ] **Cerbral account != data access.** The Cerbral company /
  maintainers can see: email, GitHub username. Nothing else. Same
  threat model as Signal or Proton: end-to-end where it matters.
- [ ] **Newsletter opt-in** via the email. Resend integration for
  transactional (password reset, account actions). No behavioral
  tracking.
- [ ] **This is the ONLY backend Cerbral runs.** Everything else
  stays on the user's machine + their own GitHub.

## v1.0 — Desktop onboarding + offline detection

- [ ] **First-run onboarding** — modeled on Claude Desktop's. Four
  screens:
  1. Welcome + "what is Cerbral" (30s overview)
  2. Cerbral account signup or login (Supabase — email + GitHub OAuth)
  3. Model picker (hardware-detected recommendation + manual override,
     including API-key option for users with weak hardware)
  4. Starter-repo picker (General / Developer / Researcher / Writer / etc.)
- [ ] **Offline detection with red banner** — exact pattern Claude
  uses when rate-limited. When the user is offline and Cerbral can't
  reach its brain repo:

  > *🔴 Offline — Cerbral's full brain is unreachable.*
  > *You need to be online to use Cerbral because it can't push to
  > or read from your private GitHub brain repo.*

  Blocks the input until the connection is back. Same visual weight
  as Claude's rate-limit banner.
- [ ] **Model / reasoning indicator** — current model name visible
  top-right; in Cerbral Agent mode, an Effort toggle (Low / Medium /
  High / Extra high / Max) controls reasoning depth (same as the
  Claude Code Effort menu).

## v1.1 — Memory Import parsers for all major providers

Ship parsers for OpenAI, Anthropic, Google, xAI, Microsoft, Meta
exports. Build a community repo `cerbral-importers` where contributors
submit new provider parsers.

## v1.2 — Chrome Extension

- [ ] **`cerbral-chrome`** — Chrome extension that lets Cerbral Agent
  use the user's browser (same pattern as Anthropic's Claude for
  Chrome extension). User installs from Chrome Web Store. The
  extension communicates with the local Cerbral desktop app via
  native messaging — all inference and reasoning still stays on the
  user's machine.
- [ ] **Use cases**: summarize the current tab, answer questions
  about what's on screen, fill forms the user describes, scrape
  structured data. All with explicit per-site permission grants.
- [ ] **Privacy**: the extension never sends page content to any
  third-party server. Everything goes to localhost → Cerbral desktop
  → local model or user-chosen API backend.

## v1.5 — Cerbral Web (cerbral.com/web)

An honest, principled web version. The trick is: **the Cerbral team
never sees user data, even in the web version.**

- [ ] **Architecture**: Cerbral Web is a static SPA deployed to the
  user's own Netlify (or whatever static host they pick). They fork
  `cerbral-web` from the public repo, point it at their private
  `cerbral-brain` GitHub repo (read-only token), and get a web
  interface to their AI. Inference happens via their chosen backend
  (local via a tunneled endpoint, or an API key they provide).
- [ ] **No hosted Cerbral server**. We do not host anyone's brain.
  The public cerbral.com/web is a landing page that says "here's how
  to deploy your own."
- [ ] **cerbral.com/web ≠ hosted AI for everyone**. That would
  violate Principle #2 (user owns their repo, no Cerbral server
  touches user data).
- [ ] **ultraplan mode** — deep, multi-phase planning that uses
  multiple sub-agents to research, decompose, and plan a complex
  goal before execution. Same pattern as Claude Code's /ultrathink.

## v2.0 — Cerbral Cloud (self-hosted by the user)

For users who want their Cerbral to run 24/7 without their laptop
being on. **Not a Cerbral-hosted service.**

- [ ] **One-click deploy to user's own cloud** — Fly.io, Railway,
  Google Cloud Run, Hetzner, whatever. Uses a Docker image from the
  public repo; user pays their own hosting bill; the instance runs
  with OAuth-connected access to their own `cerbral-brain` repo.
  Overnight tasks, scheduled routines, multi-agent runs all happen
  there.
- [ ] **Web chat interface** served from the user's cloud instance.
  Same UI as the desktop app, served as a PWA. They can talk to
  their Cerbral from any browser without carrying their laptop.
- [ ] **The Cerbral team operates zero servers in this model.** Every
  byte of user data stays in the user's cloud + their GitHub.

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
  include) indexed as part of their Cerbral.
- Local disk footprint bounded by their configured threshold (e.g.,
  "never exceed 30GB on this machine").
- Files still appear to exist locally; Cerbral fetches them on
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
- **Subscription model.** Cerbral is MIT. Free forever. If someone
  wants to sell a hosted alternative or a premium skin, they can fork.
- **License changes.** No BUSL, no commercial add-ons in this repo.

## Contribution priorities

If you want to help and don't know where to start:

1. **Test the installer on a non-macOS platform** and file issues.
2. **Write a starter repo** for a domain you know well (firearms,
   cooking, homesteading, academic research, trading, fiction writing —
   anything specific enough to be useful).
3. **Write a skill** that understands `$CERBRAL_HOME/knowledge/` and
   makes Cerbral smarter in a specific domain.
4. **Audit the sanitization code** in `cerbral-mirror.sh` for missing
   secret patterns.
5. **Write cross-platform equivalents** of the launchd plists.

Open an issue before starting anything non-trivial.

## Status beacon

- Public repo: https://github.com/rumizenzz/cerbral
- Private brain (example): https://github.com/rumizenzz/cerbral-brain
- Desktop app releases (public): https://github.com/rumizenzz/cerbral-releases — source is closed by Galactuz
- Landing page: https://cerbral.com
- Principles: [PRINCIPLES.md](./PRINCIPLES.md)

Updated 2026-04-20.

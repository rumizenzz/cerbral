# Cerbral

**Install and go. Now you have your own personal AI — specifically for you.**

A self-improving, always-growing, open-source AI that learns with you, on
*your* machine, using *your* data, all of which you fully own forever.
Already matured and ready to help you from the moment you install it — now
it becomes uniquely yours as you use it. Like a mind you can carry between
machines, never forgetting what it knows about your world.

**No more subscriptions. No more paywalls. No more rate limits. No more
being held hostage by the AI arms race.** Your personal AI runs on your
machine, your data lives in your own GitHub repo, and nobody — not OpenAI,
not Anthropic, not Google — owns any of it but you.

Built on top of [Hermes Agent](https://github.com/NousResearch/hermes-agent)
(the best open-source self-improving agent loop), powered by Git and
GitHub for the persistence layer, running whatever local model you choose
(or an API key if you want — your choice, the brain stays yours either way).

This is what AI was always meant to be: *your* AI, for *you*.

---

## What you get the second you run the installer

- **An AI that's already good.** Not a blank agent. Hermes Agent ships
  mature — skills, memory, tool use, MCP support — and Cerbral installs
  it fully wired up. You talk to it for the first time and it works.
- **An AI that grows with you.** Every session, it commits what it learned
  to your private GitHub repo. Skills refine. Memory accumulates. A model
  of who you are builds up over weeks and months. Like a child growing into
  an adult — except it starts as the adult, and becomes *your* adult.
- **Data ownership, not rental.** Your entire AI brain is files in a Git
  repo *on your GitHub*. Not their database. Not their servers. Not their
  terms of service. Yours. Clone it, fork it, hand it off in twenty years
  and it still works.
- **Free of the AI arms race.** OpenAI retires a model? Cerbral doesn't
  care. Anthropic changes its pricing? Cerbral doesn't care. The whole
  stack shuts down tomorrow? Cerbral still runs — it's just open weights
  on your machine and Git on your GitHub.
- **Never fills your disk.** `cerbral prune` deletes the ephemeral junk
  agents produce (session transcripts, sandboxes, caches) once the
  important stuff is safely mirrored to your brain repo.
- **Always sees its whole brain.** An always-current `INDEX.md` summarizes
  everything in your full Cerbral. Even if local content gets pruned,
  your AI knows what's in the repo and fetches it on demand.

Open-source · MIT licensed · Local-first · API-optional · Your data, forever.

---

## Quick install

```bash
curl -fsSL https://raw.githubusercontent.com/rumizenzz/cerbral/main/install.sh | bash
```

That's it. The installer will:

1. Check for (or install) Ollama and Hermes Agent.
2. Ask for your GitHub account.
3. Create a **private** `cerbral-brain` repo on *your* GitHub — this is
   your personal Cerbral's brain. Not ours. Yours. Forever.
4. Offer you a starter knowledge repo to seed it with.
5. Wire up the sync hooks so every session commits its learnings back to
   your private brain.
6. Pick a recommended local model for your hardware.

From that point on, your personal AI — your Cerbral — lives on your
machine, learns from your work, and the whole brain lives in a Git repo
you own. Walk away from the project, fork it, self-host it — none of
that affects your AI. It's just files.

If you'd rather read the script before piping it to bash (you should):

```bash
git clone https://github.com/rumizenzz/cerbral
cat cerbral/install.sh
./cerbral/install.sh
```

## Why now

The AI industry is racing to lock you in. Subscriptions stack up —
ChatGPT Plus, Claude Pro, Cursor, Copilot, Gemini Advanced — each a
recurring bill for the right to talk to a stranger who forgets you every
time. Every conversation you have is training data they own and you don't.
When a company pivots, raises prices, retires a model, or gets acquired,
you have no recourse. Your "AI" was never yours.

Open-source AI is how that gets inverted. Open weights have made the
models freely runnable. Hermes Agent has made the agent loop freely
usable. What was missing was the persistence layer — the part that makes
an AI actually *yours* over time. Cerbral is that layer: a thin,
principled, install-and-go piece of infrastructure that turns the existing
open-source pieces into a personal AI you own.

Open-source AI is the future. Cerbral is what it looks like when you
own the whole stack.

## Two modes: Chat and Cerbral Agent. Plus Projects.

Cerbral runs in two modes — pick from a toggle at the top of the
desktop window (or pass a flag to the CLI):

- **Chat** — conversational. No filesystem writes, no code execution,
  no agent tools. Just talk with your personal AI. Equivalent to
  Claude's chat UI, but yours and private. Your memory, skills, and
  knowledge still personalize every answer.
- **Cerbral Agent** — full agent mode. File read/write, terminal,
  code execution, web, MCP tools, deploy skills. This is where Cerbral
  AI acts like Claude Code — it reads your repo, edits files, runs
  commands, ships things. Scoped to a **Project**.

**Projects** are folders on your machine you designate (a code repo, a
research directory, a book draft, anything). Cerbral Agent operates
*inside* a selected Project — its working directory and file
permissions are bounded there. Each Project gets its own context file
at `~/cerbral/knowledge/projects/<slug>.md` (see the `TEMPLATE.md` in
[starter-general](https://github.com/rumizenzz/cerbral-starters-general/blob/main/projects/TEMPLATE.md)).
Switch Projects, and the agent swaps context with you.

## CLI

After install, the `cerbral` CLI wraps everything:

| Command            | What it does                                                      |
|--------------------|-------------------------------------------------------------------|
| `cerbral sync`     | Mirror ~/.hermes/ → brain repo, commit, push                     |
| `cerbral push`     | Alias for `sync`                                                  |
| `cerbral restore`  | Restore brain to ~/.hermes/ from the repo (dry-run by default)    |
| `cerbral prune`    | Delete ephemeral local state to free disk                         |
| `cerbral index`    | Regenerate INDEX.md, the always-current summary                   |
| `cerbral status`   | Show brain repo status + local disk posture                       |
| `cerbral logs`     | Tail mirror + prune logs                                          |
| `cerbral upgrade`  | Pull the latest scripts from the public cerbral repo              |

## Why Cerbral exists

Cloud AI is general. It knows a little about everyone and nothing specific
about you. Every conversation starts from zero. When the company changes
the terms, retires a model, or disappears, you lose everything.

Cerbral is the opposite. A small, efficient model paired with a knowledge
base that belongs to you and grows with you. Your projects, your work, your
history, your way of thinking — it accumulates all of it, locally, privately,
on your terms.

For the things you actually use AI for every day — your writing, your code,
your research, your life — a system that knows *you* beats a system that
knows everyone.

## What Cerbral is — and isn't

Cerbral wins on the things AI is most often actually for: your projects,
your writing, your code, your research, your ongoing work. On those, a
system that knows *you* beats a system that knows everyone.

It is not trying to out-reason a frontier cloud model on a hard novel
problem outside your world. If you need a research-grade reasoning engine
for something Cerbral has no context for, reach for GPT / Claude. Cerbral
AI is built for the 80–90% of everyday AI tasks that are about your world.

## Architecture

```
┌──────────────┐       ┌──────────────┐       ┌────────────────────┐
│  Local LLM   │◄─────►│  Hermes      │◄─────►│  Your private      │
│  (Ollama /   │       │  Agent       │       │  cerbral-brain     │
│  llama.cpp / │       │  (skills,    │       │  repo on GitHub    │
│  API key)    │       │  memory,     │       │  (skills, memory,  │
└──────────────┘       │  MCP tools)  │       │  knowledge, SOUL,  │
                       └──────────────┘       │  INDEX.md)         │
                              │                └────────────────────┘
                              ▼                         ▲
                       ┌──────────────┐                 │
                       │  cerbral     │─────────────────┘
                       │  mirror +    │   (auto-sync after every session,
                       │  index +     │    hourly safety net, INDEX.md
                       │  prune       │    regenerates on every change)
                       └──────────────┘
```

Small local kernel (the model) + self-improving agent (Hermes) + personal
Git-backed persistence (your brain repo) = personal AI that belongs to you
and compounds over time. See `docs/architecture.md` for detail.

## The disk-fill problem, solved

AI agents generate tons of local files: session transcripts, sandboxes,
caches, logs, checkpoints. On a busy machine this piles up — the kind of
"my disk is full and I don't know why" problem many people using local AI
hit.

Cerbral addresses it directly:

1. The important stuff (skills, memory, knowledge, SOUL) always syncs to
   your GitHub brain repo.
2. `cerbral prune` deletes ephemeral runtime bloat when free space drops
   below a threshold — but only after verifying the mirror is up to date.
3. Even after pruning, `INDEX.md` still shows what's in your full brain,
   and Cerbral fetches anything it needs from the remote on demand.

Your local machine stays lean. Your AI's brain stays complete. Both are
true at the same time.

## What's open, what's yours

- **Open (this repo):** the tool, the installer, the scripts, `PRINCIPLES`,
  the starter-repo index. MIT licensed. Contribute freely.
- **Yours (the private repo the installer creates on *your* GitHub):** your
  brain. Skills, memories, knowledge, SOUL, INDEX. Never touches this
  project's infrastructure. You own it. Fork, delete, migrate, whatever.

## What open source is for

AI shouldn't require a data center. Your knowledge shouldn't live on
someone else's servers. The intelligence that works with you every day
shouldn't be rented from a private company that can change the terms, lose
your history, or disappear tomorrow.

Cerbral inverts those assumptions. A local model, an open ecosystem, a
personal knowledge base you own. No account. No permission. No one in the
middle.

**Your brain. Your repo. Your machine. Forever.**

---

## Project status

**Alpha, actively developed.** v0.1 works today (install, running Hermes
locally, brain mirroring to your repo, index generation, prune script,
disaster recovery). v1.0 polish — richer installer UX, hardware-tier
auto-detection, starter-repo ecosystem, update notifications — is in
progress.

Co-maintainers welcome. Starter knowledge repos, skills, and
`manifest.json` PRs especially wanted.

## Credits

Cerbral is a synthesis. The real heavy lifting lives upstream:

- **[Hermes Agent](https://github.com/NousResearch/hermes-agent)** — Nous
  Research, MIT licensed. The self-improving agent loop, skill system,
  memory, MCP. Cerbral is a layer on top of this, not a replacement.
- **[Ollama](https://ollama.com)** — local model inference with an
  OpenAI-compatible endpoint.
- **Open-weight model teams** — Nous Research, Qwen, Meta, Mistral, and
  everyone else shipping open weights we can run on our own machines.

## License

MIT. See `LICENSE`.

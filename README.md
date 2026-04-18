# Cerbral AI

**Your own personal AI. Yours. Forever. Never locked into a data center.**

Cerbral AI is a local, open-source personal AI that grows its own knowledge
about you — in your own private GitHub repo, on your own machine, under
your own control. It learns who you are, what you work on, and how you
like things done. It never forgets you between sessions. It never lives
on someone else's servers. It never gets rug-pulled by a company changing
the terms.

This is what AI was always meant to be: *your* AI, specifically for *you*.

- **Runs locally by default.** Any open-weight model, any device with the
  hardware for it. No cloud required, no API keys required, no data leaves
  your machine. API keys supported as a first-class option if you want
  frontier capability or weak hardware — the brain stays yours either way.
- **Grows in your own private GitHub repo.** Every session, your AI commits
  what it learned about you and your world to a private repo on *your*
  GitHub. Versioned, portable, yours forever.
- **Gets smarter about you over time.** Skills refine through use. Memory
  persists across sessions. Knowledge accumulates. The longer you use it,
  the more it knows your world.
- **Never locked into data centers, ever.** No OpenAI rug-pulls. No
  Anthropic subscription changes. No cloud outage breaks your AI. If the
  Cerbral project shuts down tomorrow, your AI still works — it's just
  files on your machine and a repo you own.
- **Never fills your disk.** `cerbral prune` keeps your local storage
  lean by deleting ephemeral runtime bloat (session transcripts, sandboxes,
  caches) once the important stuff is safely mirrored to your brain repo.
- **Always summarized.** An always-current `INDEX.md` lives on your machine
  — Cerbral AI can see what's in its full brain even when individual files
  have been pruned locally, and fetches them from GitHub on demand.

Open-source · MIT licensed · Built on [Hermes Agent](https://github.com/NousResearch/hermes-agent) + [Ollama](https://ollama.com)

---

## Quick install

```bash
curl -fsSL https://raw.githubusercontent.com/rumizenzz/cerbral/main/install.sh | bash
```

The installer will:

1. Check for (or install) Ollama and Hermes Agent.
2. Ask for your GitHub account.
3. Create a **private** `cerbral-brain` repo on your GitHub — this is your
   personal Cerbral AI's brain.
4. Offer you a starter knowledge repo to seed it with.
5. Wire up the sync hooks so every session you have commits its learnings
   back to your private brain.
6. Pick a recommended model for your hardware.

From that point on, your personal AI — Cerbral AI — lives on your machine,
learns from your work, and the whole brain lives in a Git repo you own.

If you'd rather read the script before running it (you should):

```bash
git clone https://github.com/rumizenzz/cerbral
cat cerbral/install.sh
./cerbral/install.sh
```

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

## Why Cerbral AI exists

Cloud AI is general. It knows a little about everyone and nothing specific
about you. Every conversation starts from zero. When the company changes
the terms, retires a model, or disappears, you lose everything.

Cerbral AI is the opposite. A small, efficient model paired with a knowledge
base that belongs to you and grows with you. Your projects, your work, your
history, your way of thinking — it accumulates all of it, locally, privately,
on your terms.

For the things you actually use AI for every day — your writing, your code,
your research, your life — a system that knows *you* beats a system that
knows everyone.

## What Cerbral AI is — and isn't

Cerbral AI wins on the things AI is most often actually for: your projects,
your writing, your code, your research, your ongoing work. On those, a
system that knows *you* beats a system that knows everyone.

It is not trying to out-reason a frontier cloud model on a hard novel
problem outside your world. If you need a research-grade reasoning engine
for something Cerbral AI has no context for, reach for GPT / Claude. Cerbral
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

Cerbral AI addresses it directly:

1. The important stuff (skills, memory, knowledge, SOUL) always syncs to
   your GitHub brain repo.
2. `cerbral prune` deletes ephemeral runtime bloat when free space drops
   below a threshold — but only after verifying the mirror is up to date.
3. Even after pruning, `INDEX.md` still shows what's in your full brain,
   and Cerbral AI fetches anything it needs from the remote on demand.

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

Cerbral AI inverts those assumptions. A local model, an open ecosystem, a
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

Cerbral AI is a synthesis. The real heavy lifting lives upstream:

- **[Hermes Agent](https://github.com/NousResearch/hermes-agent)** — Nous
  Research, MIT licensed. The self-improving agent loop, skill system,
  memory, MCP. Cerbral AI is a layer on top of this, not a replacement.
- **[Ollama](https://ollama.com)** — local model inference with an
  OpenAI-compatible endpoint.
- **Open-weight model teams** — Nous Research, Qwen, Meta, Mistral, and
  everyone else shipping open weights we can run on our own machines.

## License

MIT. See `LICENSE`.

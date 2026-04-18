# Cerbral

**Your brain, externalized.**

Cerbral is a local, open-source AI that grows its own knowledge about you —
in your own private GitHub repo, on your own machine, under your own
control. It gets smarter about your world every time you use it.

- **Runs locally by default.** Any open-weight model, any device with the
  hardware for it. No cloud, no API keys required, no data leaves your
  machine. API keys supported as a first-class option if you want frontier
  capability or weak hardware — the brain stays yours either way.
- **Grows in your repo.** Every session, the agent commits what it learned
  to **your own private GitHub repo**. Versioned, portable, yours forever.
- **Gets smarter about you.** Skills refine through use. Memory persists
  across sessions. The longer you use it, the more it knows your world.

Open-source · MIT licensed · Built on [Hermes Agent](https://github.com/NousResearch/hermes-agent) + [Ollama](https://ollama.com)

---

## Quick install

```bash
curl -fsSL https://raw.githubusercontent.com/rumizenzz/cerbral/main/install.sh | bash
```

The installer will:

1. Check for (or install) Ollama + Hermes Agent.
2. Ask for your GitHub account.
3. Create a **private** `cerbral-brain` repo on your GitHub — this is your
   personal Cerbral.
4. Offer you a starter knowledge repo to seed it with.
5. Wire up the sync hooks so every session you have commits its learnings
   back to your private brain.
6. Pick a recommended local model for your hardware.

From that point on, your AI lives on your machine, learns from your work,
and the whole brain lives in a Git repo you own.

If you'd rather read the script before running it (you should):

```bash
git clone https://github.com/rumizenzz/cerbral
cat cerbral/install.sh
./cerbral/install.sh
```

## Why Cerbral exists

Cloud AI is general. It knows a little about everyone and nothing specific
about you. Every conversation starts from zero. When the company changes the
terms, loses your history, or disappears, you lose everything.

Cerbral is the opposite. A small, efficient model paired with a knowledge
base that belongs to you and grows with you. Your projects, your work, your
history, your way of thinking — it accumulates all of it, locally, privately,
on your terms.

For the things you actually use AI for every day — your writing, your code,
your research, your life — a system that knows you beats a system that knows
everyone.

## What Cerbral is — and isn't

Cerbral wins on the things AI is most often actually for: your projects,
your writing, your code, your research, your ongoing work. On those, a
system that knows *you* beats a system that knows everyone.

It is not trying to out-reason a frontier cloud model on a hard novel
problem outside your world. If you need a research-grade reasoning engine
for something Cerbral has no context for, reach for GPT / Claude / a hosted
model. Cerbral is built for the 80–90% of everyday AI tasks that are about
your world.

## Architecture

```
┌──────────────┐       ┌──────────────┐       ┌────────────────────┐
│  Local LLM   │◄─────►│  Hermes      │◄─────►│  Your private      │
│  (Ollama /   │       │  Agent       │       │  cerbral-brain     │
│  llama.cpp / │       │  (skills,    │       │  repo on GitHub    │
│  API key)    │       │  memory,     │       │  (skills, memory,  │
└──────────────┘       │  MCP tools)  │       │  knowledge, SOUL)  │
                       └──────────────┘       └────────────────────┘
                              │
                              ▼
                       ┌──────────────┐
                       │ cerbral-     │
                       │ mirror.sh    │
                       │ (rsync +     │
                       │  git push)   │
                       └──────────────┘
```

Small local kernel (the model) + self-improving agent (Hermes) + personal
Git-backed persistence (your brain repo) = personal AI that belongs to you
and compounds over time.

## What's open, what's yours

- **Open (this repo):** the tool, the scripts, the installer, PRINCIPLES,
  the starter-repo index. MIT licensed.
- **Yours (the private repo the installer creates on your GitHub):** your
  brain. Skills, memories, knowledge, SOUL. Never touches this project's
  infrastructure. You own it. Fork, delete, migrate, whatever.

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

**Alpha, actively developed.** The v0.1 scope works today (install, running
local Hermes agent, brain mirrored to your repo, basic disaster recovery).
v1.0 polish — a more complete installer, a `cerbral` CLI wrapping everything,
starter-repo ecosystem, update notifications, hardware-tier auto-detection
— is in progress.

If you're a potential co-maintainer, open an issue and say hi. Skills,
starter repos, and model-manifest PRs especially welcome.

## Credits

Cerbral is a synthesis. The real heavy lifting lives upstream:

- **[Hermes Agent](https://github.com/NousResearch/hermes-agent)** — Nous
  Research, MIT licensed. The self-improving agent loop, skill system,
  memory, MCP. Cerbral is a layer on top of this, not a replacement.
- **[Ollama](https://ollama.com)** — local model inference.
- **Open-weight model teams** — Nous Research, Qwen, Meta, Mistral, and
  everyone else shipping open weights we can run on our own machines.

## License

MIT. See `LICENSE`.

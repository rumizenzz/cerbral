# Cerbral Principles

These are the value commitments that define Cerbral, and they constrain
how the product evolves regardless of what Galactuz (the company
behind Cerbral) would otherwise be tempted to do. They aren't style
guidelines; they are the deal we're making with you.

## 1. Local-first. API keys supported as a first-class option. The brain is yours regardless of backend.

Cerbral's core is the persistence layer — your skills, memory, and knowledge,
growing in your own Git repo. The inference layer is your choice:

- **Local runtime** (Ollama, llama.cpp, MLX, LM Studio) — the recommended
  default. Private, offline-capable, free at runtime.
- **Hosted API** (OpenAI, Anthropic, OpenRouter, any OpenAI-compatible
  endpoint) — supported as a first-class option. More capability on hard
  tasks, works on any hardware, but inference data goes to the provider you
  chose.

Either way, the brain is yours. That is the thing that cannot change.

## 2. User owns their repo. Period.

The brain lives in the user's own private GitHub repo (or self-hosted Gitea,
or a local-only Git repo). Cerbral ships no hosted component, has no server,
runs no accounts. If the Cerbral project shuts down tomorrow, your brain
still works — it's just files in a Git repo on your machine.

## 3. No telemetry. No phone-home. No analytics.

The tool talks to the internet only for:

- User-initiated git push/pull to your own repo.
- User-initiated model downloads.
- User-initiated LLM API calls if you chose an API backend.
- Opt-in update manifest fetch (default: off).

Nothing else. No usage tracking. No crash reports. No "anonymous" stats.

## 4. The AI is free. Forever.

Cerbral the local AI — the desktop app, local inference, brain-repo
persistence to your own GitHub — is free to use and always will be.
Galactuz funds the business through **Cerbral Cloud** (optional paid
subscriptions for extra compute + storage) and the **Galactuz API**
(usage-based inference for developers), not by gating the core
product. No rug-pulls, no "we're moving the free tier behind a
paywall" email six months from now. What you install today is the
same deal next year and the year after.

Closed-source doesn't mean locked-in. Your brain-repo is yours in
your GitHub; if Galactuz disappears tomorrow, you still have every
conversation, memory, and skill Cerbral learned about you, in plain
Git-tracked files you can load into anything.

## 5. Honest marketing.

Cerbral wins on things that touch your world. It does not out-reason a
frontier cloud model on a hard novel problem outside your world. The
README and the landing page say this plainly. No "revolutionary," no
"breakthrough," no comparison charts claiming to beat GPT or Claude at
everything. Underclaim, overdeliver.

## 6. Transparent attribution.

Cerbral is a closed-source product built on top of open foundations.
The README credits them plainly:

- **Hermes Agent** (Nous Research, MIT) — the self-improving agent loop,
  skill system, memory system, MCP integration.
- **Ollama** — local model inference.
- **Open-weight model authors** (Nous Research, Qwen team, Meta, Mistral,
  etc.) — the actual models.

Galactuz (Cerbral's parent company) adds the Git-backed brain layer,
the install-and-go packaging, Cerbral Cloud infrastructure, and the
product UX. It does not pretend to have invented what it didn't
invent.

---

These principles are not a style guide — they are hard constraints. Any PR
that violates them is out of scope for this project, regardless of how
useful the feature might be. Fork if you want something different.

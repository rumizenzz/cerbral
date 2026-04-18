# Cerbral Principles

These are the value commitments that define Cerbral. They constrain how the
project evolves and what the tool is allowed to do.

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

## 4. MIT licensed.

Same as Hermes Agent. No rug-pulls, no license changes later, no BUSL
conversions. What you install today works the same way next year and the
year after.

## 5. Honest marketing.

Cerbral wins on things that touch your world. It does not out-reason a
frontier cloud model on a hard novel problem outside your world. The
README and the landing page say this plainly. No "revolutionary," no
"breakthrough," no comparison charts claiming to beat GPT or Claude at
everything. Underclaim, overdeliver.

## 6. Transparent attribution.

Cerbral is a synthesis on top of other people's work. The README credits:

- **Hermes Agent** (Nous Research, MIT) — the self-improving agent loop,
  skill system, memory system, MCP integration.
- **Ollama** — local model inference.
- **Open-weight model authors** (Nous Research, Qwen team, Meta, Mistral,
  etc.) — the actual models.

Cerbral adds the Git-backed brain layer and the install-and-go packaging.
It does not pretend to have invented what it didn't invent.

---

These principles are not a style guide — they are hard constraints. Any PR
that violates them is out of scope for this project, regardless of how
useful the feature might be. Fork if you want something different.

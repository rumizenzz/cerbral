# Contributing to Cerbral

Thanks for wanting to help. Cerbral's health depends on contributors.

## What contributions are most welcome

- **Starter knowledge repos.** Curated, MIT-licensed markdown seeds for a
  specific domain. See `cerbral-starters/*` org for examples (pending).
- **Skills.** Hermes Agent skills that understand the Cerbral architecture —
  especially skills that route knowledge queries, handle Git-sync gracefully,
  or bridge common tools.
- **Model recommendations.** PRs against `manifest.json` proposing new
  recommended models for hardware tiers. Include benchmark evidence.
- **Bug fixes** and **cross-platform support** (Linux systemd equivalent of
  the launchd plist, Windows WSL notes, etc.).
- **Documentation.** Especially install troubleshooting guides.

## What won't be merged

- Anything that violates `PRINCIPLES.md`. Specifically:
  - Telemetry, phone-home, or analytics.
  - Hosted components, accounts, or required cloud services.
  - License changes away from MIT.
  - Features that claim parity with frontier cloud models on generic
    reasoning benchmarks (Cerbral's pitch is personalization, not raw IQ —
    honest positioning is a hard constraint).
- Dependencies with restrictive licenses (GPL, proprietary).
- Features that work only on one OS without a graceful-degradation path
  for the others.

## Process

1. Open an issue describing what you want to do and why. For small fixes,
   skip to step 3.
2. Discuss scope in the issue — especially for features that might touch
   the principles.
3. PR with a clear title, a one-sentence description of the change, and a
   "why this is good enough to ship" section in the description. For
   manifest PRs, include benchmark / evidence links.
4. Maintainer review. We aim for responsiveness over bureaucracy; a small
   PR should get feedback within a week.

## Development

Cerbral is a shell-first project. Scripts live in `scripts/`, the CLI in
`bin/`, the installer in `install.sh`. No build step. Shellcheck is welcome
(we'll add a CI job for it once there's more code).

Testing changes against a real setup:

```bash
# Clone fresh into a scratch dir
git clone https://github.com/rumizenzz/cerbral ~/cerbral-dev
# Point an env var at your dev copy
CERBRAL_RAW=file://$HOME/cerbral-dev bash ~/cerbral-dev/install.sh
```

## Governance

MIT licensed, maintainer-led for the first year. If the project grows to
need a steering committee or formal governance, we'll stand one up then —
not before there are contributors to represent.

Maintainers:

- Rumi Zappalorti ([@rumizenzz](https://github.com/rumizenzz)) — founder.

## Code of conduct

Be decent. Disagree productively. Technical debates are welcome; personal
attacks are not. Specific infractions are handled by the maintainer on a
case-by-case basis until the project is large enough to warrant a formal CoC.

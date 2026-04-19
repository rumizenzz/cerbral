# Set up notifications from your Cerbral

Your Cerbral can let you know when it finishes long tasks, needs
approval, has a morning brief ready, or encounters something urgent.
This document explains how to set that up.

## TL;DR — which channel should I use?

| Your situation | Recommended channel | Setup time |
|---|---|---|
| "I just want notifications, keep it simple" | **Native desktop notifications** (default, already on) | 0 seconds |
| "I want email when my Cerbral finishes overnight work" | **Resend with your own key** (free, 3,000 emails/month) | 60 seconds |
| "I want push to my phone" | **ntfy.sh** (free, self-hostable) or Pushover ($5 one-time) | 2 minutes |
| "I want Discord/Slack pings" | **Webhook** to your server's incoming-webhook URL | 1 minute |

**Principle:** Cerbral-the-project **never** touches your notification
content. Everything here is user-controlled — your credentials, your
API keys, your endpoints. The Cerbral team cannot see what your AI
tells you.

---

## Option 1 — Native desktop notifications (default)

Already on. No setup needed. Works offline. Uses macOS Notification
Center / Linux `notify-send` / Windows toast.

Pros:
- Zero third party, zero cost, zero setup
- Works fully offline
- No email account needed

Cons:
- Only reaches you when the machine is awake and you're near it
- No history / searchable log
- No phone delivery

If native notifications are enough: stop reading, you're done.

---

## Option 2 — Email via your own Resend account

This is the recommended path if you want email. **Cerbral-the-project's
`hello@cerbral.com` sender is NOT used for this.** You get your own
Resend account (free), and your Cerbral sends email from your verified
address to your inbox.

### 1. Sign up at Resend

Go to https://resend.com/signup. Sign up with GitHub or email. It's
free — the free tier is 3,000 emails/month and 100 emails/day, which
is roughly 100× what any individual user needs.

### 2. Verify the address you want to send FROM

In Resend's dashboard → **Domains** → Add domain, or add a single
verified address (if Resend offers that tier). Verify via the email
Resend sends you.

You'll send FROM the same address you're sending TO — that's the
simplest setup and avoids DMARC issues. (Think of it as: your AI is
mailing you from your own address, which is exactly what this is.)

### 3. Create an API key

Resend dashboard → **API Keys** → Create API Key → give it a name
("Cerbral notifications") → copy the `re_...` value.

### 4. Add it to your local secrets file

Edit `~/.cerbral-secrets.env` and add:

```
# User-own Resend for Cerbral agent → user notifications.
# (Separate from any Cerbral-project Resend key.)
USER_RESEND_API_KEY=re_paste_your_key_here
NOTIFY_EMAIL=you@yourdomain.com
```

Make sure the file is mode 0600: `chmod 600 ~/.cerbral-secrets.env`.

### 5. Set channel preference

Edit `~/cerbral/settings.json`:

```json
{
  "notify": {
    "channels": ["email_user_own", "native_notification"],
    "email_address": "you@yourdomain.com",
    "cooldown_minutes": 30,
    "quiet_hours": { "start": "22:00", "end": "07:00" }
  }
}
```

First in the array wins. Native stays as fallback when email fails
or during quiet hours.

### 6. Test

```bash
source ~/.cerbral-secrets.env
curl -X POST https://api.resend.com/emails \
  -H "Authorization: Bearer $USER_RESEND_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"from\":\"Your Cerbral <$NOTIFY_EMAIL>\",\"to\":[\"$NOTIFY_EMAIL\"],\"subject\":\"Cerbral test\",\"text\":\"Setup works.\"}"
```

If you see an email ID back and the message lands in your inbox, you're done.

---

## Option 3 — Regular SMTP (Gmail / Fastmail / iCloud / self-hosted)

If you'd rather use your existing email provider's SMTP instead of
Resend, add these to `~/.cerbral-secrets.env`:

```
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=you@gmail.com
SMTP_PASS=app-password-not-your-real-password
NOTIFY_EMAIL=you@gmail.com
```

For Gmail, generate an **app password** at
https://myaccount.google.com/apppasswords (requires 2FA enabled).
iCloud works similarly.

Update settings.json:

```json
{ "notify": { "channels": ["email_user_own_smtp", "native_notification"] } }
```

Cerbral uses `msmtp` or Python's `smtplib` with STARTTLS under the
hood — no third-party mail service.

---

## Option 4 — Messaging apps (Telegram / Discord / Slack / WhatsApp / Signal / iMessage)

Your Cerbral is built on Hermes Agent, which **already has native
integrations** for the major messaging platforms. If you've set up
Telegram / Discord / Slack / WhatsApp / Signal with Hermes, Cerbral can
piggyback on those — no extra credentials, no extra setup.

Check what's active: `grep -A 2 platform_toolsets ~/.hermes/config.yaml`
(or open the file). If you see `telegram`, `discord`, `slack`,
`whatsapp`, `signal`, `homeassistant` — those channels are already
live. Set `notify.channels` in `~/cerbral/settings.json` to use them:

```json
{
  "notify": {
    "channels": ["telegram", "native_notification"],
    "telegram": { "chat_id": "123456789" },
    "discord":  { "channel_id": "9876543..." },
    "slack":    { "channel": "#cerbral-notifications" },
    "whatsapp": { "phone": "+1555..." },
    "signal":   { "recipient": "+1555..." }
  }
}
```

Cerbral reads the channel config, finds which of those Hermes knows
about, and dispatches to that platform.

### Setting up Hermes integrations (if not already done)

Hermes has its own `hermes telegram setup`, `hermes discord setup`,
etc. commands. Each walks you through the one-time credential flow:

- **Telegram** — create a bot via @BotFather, put the token in
  `~/.hermes/.env` as `TELEGRAM_BOT_TOKEN`, DM your bot once to
  register your chat ID.
- **Discord** — create a Discord application + bot at
  https://discord.com/developers/applications, add it to your server,
  token goes in `~/.hermes/.env` as `DISCORD_BOT_TOKEN`.
- **Slack** — create an incoming webhook at
  https://api.slack.com/apps (Incoming Webhooks → Add New), paste the
  `https://hooks.slack.com/...` URL. Or use the full Slack bot flow
  for richer interaction.
- **WhatsApp** — Hermes supports WhatsApp Business Cloud API or the
  free `whatsapp-web.js` bridge. Bridge is simpler for personal use.
- **Signal** — Hermes uses `signal-cli`. One-time pairing with your
  phone.
- **iMessage** (macOS only) — no Hermes integration yet. Workaround:
  `osascript` bridge to `Messages.app`.

### Webhook-only services (simpler than bot setup)

If you don't want to run a bot, these services accept simple HTTP
POST webhooks — set `webhook_url` in settings and Cerbral will POST
JSON to them:

| Service | Get a webhook URL at | Notes |
|---|---|---|
| **Discord** | Server settings → Integrations → Webhooks | Fastest way |
| **Slack** | https://api.slack.com/apps → Incoming Webhooks | Scoped to one channel |
| **ntfy.sh** | https://ntfy.sh (pick a topic) | Free, phone push |
| **Pushover** | https://pushover.net ($5 once) | Reliable phone push |
| **IFTTT** | https://ifttt.com/maker_webhooks | Bridge to anything IFTTT supports |

Pick the one that matches where you actually look.

## Option 5 — Push to your phone (ntfy.sh, Pushover)

### ntfy.sh (free, self-hostable)

Go to https://ntfy.sh, install their mobile app, subscribe to a
private topic (random string like `cerbral-rumi-7fq3x`):

```json
{ "notify": { "channels": ["webhook"], "webhook_url": "https://ntfy.sh/cerbral-rumi-7fq3x" } }
```

Your Cerbral will POST notifications to that URL, which ntfy pushes
to your phone. Free, reliable, the topic name is your only secret.

### Pushover ($5 one-time)

https://pushover.net — reliable, paid once-and-done. Same webhook
pattern, different URL.

### Discord / Slack webhook

Create an incoming webhook in your Discord server or Slack workspace,
paste the URL into `webhook_url`. Your Cerbral sends JSON; Discord/
Slack renders it.

---

## Troubleshooting

**Emails going to spam:** expected on first few sends until
reputation builds, especially if you're sending to Gmail. Mark as
"Not spam" once.

**"USER_RESEND_API_KEY not set" warning:** your shell hasn't sourced
`~/.cerbral-secrets.env`. Add this to `~/.zshrc`:

```bash
[ -f ~/.cerbral-secrets.env ] && set -a && source ~/.cerbral-secrets.env && set +a
```

**Notifications during quiet hours:** check `notify.quiet_hours` in
`settings.json`. Urgent notifications (where `urgency=="urgent"`)
override quiet hours by design — that's the escape hatch for
genuinely time-critical events.

**Cerbral is sending emails I didn't ask for:** your agent is
over-triggering notifications. Add explicit rules in your `USER.md`:
"only notify me for X, Y, Z." The agent reads that and calibrates.

---

## Security recap

- Your notification credentials live in `~/.cerbral-secrets.env` on
  your machine, mode 0600, never committed.
- Cerbral-the-project's servers (Resend, Supabase) never see your
  notification content.
- Your email subject and body stay between: you → your email
  provider → you. Same threat model as any email you send yourself.

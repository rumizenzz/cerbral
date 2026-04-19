#!/usr/bin/env bash
# cerbral-send-email.sh
# Send transactional email from *@cerbral.com via the Resend API.
#
# Purpose: Cerbral-the-project's outbound emails to people who signed up for
# Cerbral accounts — welcome, email-confirm, password reset, product updates,
# newsletter. Same role as Anthropic's "welcome to Claude" emails. Crucially
# this is the ONLY user data Cerbral-the-project ever sees (email + GitHub
# OAuth link); everything else stays in the user's own brain repo, which
# never touches any Cerbral-project server.
#
# This is NOT for end-user Cerbral agents to send personal email on behalf
# of the user. That's a separate capability (hook up to user's own
# Gmail/Fastmail/etc via their credentials).
#
# Usage:
#   cerbral-send-email.sh --to <addr> --subject "<subject>" --text "<body>"
#   cerbral-send-email.sh --to <addr> --subject "<subject>" --text-file path/to/body.txt
#   cerbral-send-email.sh --to <addr> --subject "<subject>" --html "<h1>…</h1>"
#   cerbral-send-email.sh --to <addr> --subject "<subject>" --text-file body.txt --html-file body.html
#
# Options:
#   --from <addr>       Sender address (default: Cerbral <hello@cerbral.com>)
#   --to <addr>         Recipient (required; repeat for multiple)
#   --cc <addr>         CC (optional; repeat)
#   --bcc <addr>        BCC (optional; repeat)
#   --subject <str>     Subject line (required)
#   --text <str>        Plain-text body
#   --text-file <path>  Read text body from file
#   --html <str>        HTML body
#   --html-file <path>  Read HTML body from file
#   --reply-to <addr>   Reply-To header (optional)
#   --tag <k=v>         Resend tag for analytics (optional; repeat)
#   --dry-run           Print the JSON payload without sending
#
# Env:
#   RESEND_API_KEY      Required. Usually sourced from ~/.cerbral-secrets.env.
#
# Example:
#   cerbral-send-email.sh \
#       --to friend@example.com \
#       --subject "hi from Cerbral" \
#       --text "just saying hi"

set -euo pipefail

# --- Defaults ----------------------------------------------------------------
FROM="Cerbral <hello@cerbral.com>"
SUBJECT=""
TEXT=""
HTML=""
DRY_RUN=0
TO_JSON="[]"
CC_JSON="[]"
BCC_JSON="[]"
TAGS_JSON="[]"
REPLY_TO=""

die() { echo "ERROR: $*" >&2; exit 1; }

# Push a string onto a JSON array string (using python to stay robust).
json_push() {
  python3 -c '
import json, sys
arr = json.loads(sys.argv[1])
arr.append(sys.argv[2])
print(json.dumps(arr))
' "$1" "$2"
}

# --- Parse args --------------------------------------------------------------
while [ $# -gt 0 ]; do
  case "$1" in
    --from)        FROM="$2"; shift 2 ;;
    --to)          TO_JSON="$(json_push "$TO_JSON" "$2")"; shift 2 ;;
    --cc)          CC_JSON="$(json_push "$CC_JSON" "$2")"; shift 2 ;;
    --bcc)         BCC_JSON="$(json_push "$BCC_JSON" "$2")"; shift 2 ;;
    --subject)     SUBJECT="$2"; shift 2 ;;
    --text)        TEXT="$2"; shift 2 ;;
    --text-file)   TEXT="$(cat "$2")"; shift 2 ;;
    --html)        HTML="$2"; shift 2 ;;
    --html-file)   HTML="$(cat "$2")"; shift 2 ;;
    --reply-to)    REPLY_TO="$2"; shift 2 ;;
    --tag)         TAGS_JSON="$(json_push "$TAGS_JSON" "$2")"; shift 2 ;;
    --dry-run)     DRY_RUN=1; shift ;;
    -h|--help)     sed -n '2,30p' "$0"; exit 0 ;;
    *) die "unknown option: $1" ;;
  esac
done

# --- Load secrets if not already in env --------------------------------------
if [ -z "${RESEND_API_KEY:-}" ] && [ -f "$HOME/.cerbral-secrets.env" ]; then
  # shellcheck source=/dev/null
  set -a
  source "$HOME/.cerbral-secrets.env"
  set +a
fi

# --- Validate ----------------------------------------------------------------
[ -n "${RESEND_API_KEY:-}" ] || die "RESEND_API_KEY not set. Add to ~/.cerbral-secrets.env."
[ -n "$SUBJECT" ] || die "--subject is required."
[ "$TO_JSON" != "[]" ] || die "at least one --to is required."
[ -n "$TEXT" ] || [ -n "$HTML" ] || die "--text or --html (or both) required."

# --- Build JSON payload ------------------------------------------------------
# Export so the python heredoc can read them via os.environ.
export FROM SUBJECT TEXT HTML REPLY_TO TO_JSON CC_JSON BCC_JSON TAGS_JSON
PAYLOAD="$(python3 <<'PY'
import json, os
from_addr = os.environ["FROM"]
subject = os.environ["SUBJECT"]
text = os.environ["TEXT"]
html = os.environ["HTML"]
reply_to = os.environ["REPLY_TO"]
to = json.loads(os.environ["TO_JSON"])
cc = json.loads(os.environ["CC_JSON"])
bcc = json.loads(os.environ["BCC_JSON"])
tags_raw = json.loads(os.environ["TAGS_JSON"])

body = {"from": from_addr, "to": to, "subject": subject}
if cc:  body["cc"]  = cc
if bcc: body["bcc"] = bcc
if text: body["text"] = text
if html: body["html"] = html
if reply_to: body["reply_to"] = reply_to
if tags_raw:
    tags = []
    for t in tags_raw:
        if "=" in t:
            k, v = t.split("=", 1)
            tags.append({"name": k.strip(), "value": v.strip()})
    if tags: body["tags"] = tags
print(json.dumps(body))
PY
)"

# --- Send or dry-run ---------------------------------------------------------
if [ "$DRY_RUN" -eq 1 ]; then
  echo "$PAYLOAD" | python3 -m json.tool
  exit 0
fi

RESP="$(curl -sS -X POST "https://api.resend.com/emails" \
  -H "Authorization: Bearer $RESEND_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")"

# Print pretty + exit non-zero if the API returned an error shape.
echo "$RESP" | python3 -c '
import json, sys
d = json.load(sys.stdin)
print(json.dumps(d, indent=2))
if isinstance(d, dict) and ("error" in d or "message" in d and "id" not in d):
    sys.exit(1)
'

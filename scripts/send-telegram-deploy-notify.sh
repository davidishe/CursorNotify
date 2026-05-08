#!/usr/bin/env bash
# Send a Telegram message with GitHub Actions deploy outcome (fail-open on network errors).
# Expects TELEGRAM_BOT_TOKEN_NOTIFY, TELEGRAM_CHAT_ID, DEPLOY_RESULT, and optional GH_* vars.

set -u

if [[ -z "${TELEGRAM_BOT_TOKEN_NOTIFY:-}" || -z "${TELEGRAM_CHAT_ID:-}" ]]; then
  exit 0
fi

SHORT_SHA="${GH_SHA:-}"
if [[ -n "${SHORT_SHA}" && ${#SHORT_SHA} -gt 7 ]]; then
  SHORT_SHA="${SHORT_SHA:0:7}"
fi

BASE_URL="${GH_SERVER_URL:-https://github.com}"
REPO="${GH_REPO:-}"
RUN_ID="${GH_RUN_ID:-}"
if [[ -n "${REPO}" && -n "${RUN_ID}" ]]; then
  RUN_URL="${BASE_URL}/${REPO}/actions/runs/${RUN_ID}"
else
  RUN_URL="${BASE_URL}"
fi

MESSAGE="$(printf 'GitHub Actions: deploy finished\nStatus: %s\nWorkflow: %s\nRepo: %s\nRef: %s\nSHA: %s\nRun: %s' \
  "${DEPLOY_RESULT:-unknown}" \
  "${GH_WORKFLOW:-}" \
  "${GH_REPO:-}" \
  "${GH_REF:-}" \
  "${SHORT_SHA}" \
  "${RUN_URL}")"

curl -fsS -m 8 -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN_NOTIFY}/sendMessage" \
  -d "chat_id=${TELEGRAM_CHAT_ID}" \
  --data-urlencode "text=${MESSAGE}" \
  -d "disable_web_page_preview=true" \
  >/dev/null 2>&1 || true

exit 0

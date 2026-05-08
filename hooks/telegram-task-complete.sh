#!/bin/bash

set -u

# Always read hook input to avoid pipe issues in some environments.
cat >/dev/null || true

CONFIG_FILE="${HOME}/.cursor/telegram-notify.env"

if [[ ! -f "${CONFIG_FILE}" ]]; then
  exit 0
fi

# shellcheck source=/dev/null
source "${CONFIG_FILE}"

if [[ -z "${TELEGRAM_BOT_TOKEN_NOTIFY:-}" || -z "${TELEGRAM_CHAT_ID:-}" ]]; then
  exit 0
fi

PROJECT_NAME="$(basename "$(pwd)")"
CURRENT_TIME="$(date '+%Y-%m-%d %H:%M:%S')"

MESSAGE="$(printf 'Cursor: task completed\nProject: %s\nTime: %s' "${PROJECT_NAME}" "${CURRENT_TIME}")"

curl -fsS -m 8 -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN_NOTIFY}/sendMessage" \
  -d "chat_id=${TELEGRAM_CHAT_ID}" \
  --data-urlencode "text=${MESSAGE}" \
  -d "disable_web_page_preview=true" \
  >/dev/null 2>&1 || true

exit 0

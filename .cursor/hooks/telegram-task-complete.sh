#!/bin/bash

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLOBAL_CONFIG_FILE="${HOME}/.cursor/telegram-notify.env"
LOCAL_CONFIG_FILE="${SCRIPT_DIR}/telegram-notify.env"

# Always read hook input to avoid pipe issues in some environments.
cat >/dev/null || true

if [[ -f "${GLOBAL_CONFIG_FILE}" ]]; then
  CONFIG_FILE="${GLOBAL_CONFIG_FILE}"
elif [[ -f "${LOCAL_CONFIG_FILE}" ]]; then
  # Fallback for project-local setup.
  CONFIG_FILE="${LOCAL_CONFIG_FILE}"
else
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

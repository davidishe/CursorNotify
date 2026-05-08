#!/usr/bin/env bash
# Load TELEGRAM_* from ~/.cursor/telegram-notify.env and set GitHub Actions secrets via gh.
# Usage: push-gh-telegram-secrets.sh OWNER/REPO [--force]
# --force overwrites existing secrets. Without --force, existing names are skipped.
# Authenticate gh first (gh auth login or GH_TOKEN in the same env file).

set -euo pipefail

REPO="${1:-}"
FORCE=0
if [[ "${2:-}" == "--force" ]]; then
  FORCE=1
fi

if [[ -z "${REPO}" || "${REPO}" == "--force" ]]; then
  echo "Usage: $0 OWNER/REPO [--force]" >&2
  exit 1
fi

ENV_FILE="${HOME}/.cursor/telegram-notify.env"
if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing ${ENV_FILE}" >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "gh is not installed (https://cli.github.com/)" >&2
  exit 1
fi

set -a
# shellcheck source=/dev/null
source "${ENV_FILE}"
set +a

secret_exists() {
  local name="$1"
  gh secret list --repo "${REPO}" --json name -q '.[].name' 2>/dev/null | grep -qx "${name}"
}

set_secret() {
  local name="$1"
  local value="$2"
  if [[ -z "${value}" ]]; then
    echo "Skip ${name}: empty value in ${ENV_FILE}" >&2
    return
  fi
  if [[ "${FORCE}" -eq 0 ]] && secret_exists "${name}"; then
    echo "Skip ${name}: already exists (use --force to overwrite)" >&2
    return
  fi
  printf '%s' "${value}" | gh secret set "${name}" --repo "${REPO}"
  echo "Set secret ${name}"
}

set_secret TELEGRAM_BOT_TOKEN_NOTIFY "${TELEGRAM_BOT_TOKEN_NOTIFY:-}"
set_secret TELEGRAM_CHAT_ID "${TELEGRAM_CHAT_ID:-}"

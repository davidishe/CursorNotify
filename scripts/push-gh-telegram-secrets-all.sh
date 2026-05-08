#!/usr/bin/env bash
# Push TELEGRAM_* secrets to many GitHub repos from ~/.cursor/telegram-notify.env
#
# Usage:
#   ./push-gh-telegram-secrets-all.sh [--force] OWNER/r1 OWNER/r2 ...
#   ./push-gh-telegram-secrets-all.sh [--force]   # reads ~/.cursor/telegram-notify-repos.txt
#
# List file: one OWNER/REPO per line, # starts a comment, blank lines ignored.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PUSH="${SCRIPT_DIR}/push-gh-telegram-secrets.sh"
LIST_FILE="${HOME}/.cursor/telegram-notify-repos.txt"
FORCE=()
REPOS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      FORCE=(--force)
      shift
      ;;
    *)
      REPOS+=("$1")
      shift
      ;;
  esac
done

load_list_file() {
  local f="$1"
  REPOS=()
  local line
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "$line" || "$line" == \#* ]] && continue
    REPOS+=("$line")
  done <"$f"
}

if [[ ${#REPOS[@]} -eq 0 ]]; then
  if [[ ! -f "${LIST_FILE}" ]]; then
    echo "Pass OWNER/repo arguments or create ${LIST_FILE} (one repo per line)." >&2
    exit 1
  fi
  load_list_file "${LIST_FILE}"
fi

if [[ ${#REPOS[@]} -eq 0 ]]; then
  echo "No repositories listed." >&2
  exit 1
fi

for r in "${REPOS[@]}"; do
  echo "=== ${r} ==="
  if [[ ${#FORCE[@]} -gt 0 ]]; then
    "${PUSH}" "${r}" "${FORCE[@]}"
  else
    "${PUSH}" "${r}"
  fi
done

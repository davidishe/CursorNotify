#!/usr/bin/env bash
# Install the reusable Telegram notify workflow into another project.
#
# Remote (CursorNotify published on GitHub):
#   install-reusable-telegram-notify.sh /path/to/my-app [UPSTREAM_REPO] [GIT_REF] [--force]
#
# Local (CursorNotify only on your machine — recommended when you do NOT publish CursorNotify):
#   install-reusable-telegram-notify.sh /path/to/my-app --local [--force]
#
# Remote UPSTREAM example: your-github-username/CursorNotify (must be public or caller must have access).
# Default UPSTREAM: env CURSOR_NOTIFY_GHA_REPO, otherwise required as 2nd argument (remote mode only).
# GIT_REF default: main
#
# Remote mode writes: TARGET/.github/workflows/deploy-telegram-notify.yml
# Local mode writes:
#   TARGET/.github/workflows/reusable-telegram-deploy-notify.yml  (copy from this checkout)
#   TARGET/.github/workflows/deploy-telegram-notify.yml           (caller using ./.github/...)

set -euo pipefail

POS=()
FORCE=0
LOCAL=0
for arg in "$@"; do
  case "$arg" in
    --force) FORCE=1 ;;
    --local) LOCAL=1 ;;
    *) POS+=("$arg") ;;
  esac
done

TARGET="${POS[0]:-}"
UPSTREAM="${POS[1]:-${CURSOR_NOTIFY_GHA_REPO:-}}"
REF="${POS[2]:-main}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${LOCAL}" -eq 1 ]]; then
  if [[ -z "${TARGET}" ]]; then
    echo "Usage: $0 /path/to/project --local [--force]" >&2
    exit 1
  fi

  ROOT="$(cd "${TARGET}" && pwd)"
  WF_DIR="${ROOT}/.github/workflows"
  REUSABLE_SRC="${SCRIPT_DIR}/../.github/workflows/reusable-telegram-deploy-notify.yml"
  TEMPLATE="${SCRIPT_DIR}/../templates/github-workflows/deploy-with-local-reusable-telegram-notify.yml"
  OUT_DEPLOY="${WF_DIR}/deploy-telegram-notify.yml"
  OUT_REUSABLE="${WF_DIR}/reusable-telegram-deploy-notify.yml"

  if [[ ! -f "${REUSABLE_SRC}" ]]; then
    echo "Missing reusable workflow source: ${REUSABLE_SRC}" >&2
    exit 1
  fi
  if [[ ! -f "${TEMPLATE}" ]]; then
    echo "Missing template: ${TEMPLATE}" >&2
    exit 1
  fi

  mkdir -p "${WF_DIR}"

  if [[ -f "${OUT_DEPLOY}" && "${FORCE}" -eq 0 ]]; then
    echo "Exists: ${OUT_DEPLOY} — add --force to overwrite." >&2
    exit 1
  fi

  cp "${REUSABLE_SRC}" "${OUT_REUSABLE}"
  echo "Wrote ${OUT_REUSABLE} (vendored copy from this CursorNotify checkout)"

  cp "${TEMPLATE}" "${OUT_DEPLOY}"
  echo "Wrote ${OUT_DEPLOY}"
  echo "Next: push secrets for that repo, then commit both workflow files:"
  echo "  ${SCRIPT_DIR}/push-gh-telegram-secrets.sh \$(cd \"${ROOT}\" && gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo OWNER/REPO)"
  exit 0
fi

if [[ -z "${TARGET}" ]]; then
  echo "Usage: $0 /path/to/project [OWNER/CursorNotify] [ref] [--force]" >&2
  echo "   or: $0 /path/to/project --local [--force]" >&2
  echo "  Or (remote): export CURSOR_NOTIFY_GHA_REPO=OWNER/CursorNotify" >&2
  exit 1
fi

if [[ -z "${UPSTREAM}" ]]; then
  echo "Set OWNER/CursorNotify as the 2nd argument or export CURSOR_NOTIFY_GHA_REPO." >&2
  echo "Or use --local to vendor the reusable workflow into the target repo (no GitHub upstream)." >&2
  exit 1
fi

ROOT="$(cd "${TARGET}" && pwd)"
WF_DIR="${ROOT}/.github/workflows"
OUT="${WF_DIR}/deploy-telegram-notify.yml"
TEMPLATE="${SCRIPT_DIR}/../templates/github-workflows/deploy-with-reusable-telegram-notify.yml"

if [[ ! -f "${TEMPLATE}" ]]; then
  echo "Missing template: ${TEMPLATE}" >&2
  exit 1
fi

mkdir -p "${WF_DIR}"

if [[ -f "${OUT}" && "${FORCE}" -eq 0 ]]; then
  echo "Exists: ${OUT} — add --force to overwrite." >&2
  exit 1
fi

sed -e "s|__UPSTREAM__|${UPSTREAM}|g" -e "s|__REF__|${REF}|g" "${TEMPLATE}" >"${OUT}"
echo "Wrote ${OUT}"
echo "Next: push secrets for that repo, then commit the workflow:"
echo "  ${SCRIPT_DIR}/push-gh-telegram-secrets.sh \$(cd \"${ROOT}\" && gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo OWNER/REPO)"

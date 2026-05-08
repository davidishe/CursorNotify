#!/usr/bin/env bash
# Copy workflow policy bundle from this repo to ~/.cursor (rules, skills, workflow-policy).
#
# Usage: ./scripts/install-workflow-policy-to-home.sh
# Run from a clone of CursorNotify (or set CURSOR_NOTIFY_REPO to repo root).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DEST_BASE="${HOME}/.cursor"
POLICY_SRC="${REPO_ROOT}/workflow-policy"
INSTALL_SRC="${REPO_ROOT}/install/user-cursor"

if [[ ! -d "${POLICY_SRC}" ]]; then
  echo "Missing ${POLICY_SRC}" >&2
  exit 1
fi

if [[ ! -d "${INSTALL_SRC}/rules" || ! -d "${INSTALL_SRC}/skills" ]]; then
  echo "Missing ${INSTALL_SRC}/rules or skills" >&2
  exit 1
fi

mkdir -p "${DEST_BASE}/workflow-policy"
cp -f "${POLICY_SRC}/REQUIREMENTS.md" "${POLICY_SRC}/policy.json" "${DEST_BASE}/workflow-policy/"
mkdir -p "${DEST_BASE}/workflow-policy/snippets"
cp -f "${POLICY_SRC}/snippets/"*.yml "${DEST_BASE}/workflow-policy/snippets/"

mkdir -p "${DEST_BASE}/rules"
cp -f "${INSTALL_SRC}/rules/github-actions-workflow-policy.mdc" "${DEST_BASE}/rules/"

mkdir -p "${DEST_BASE}/skills/github-actions-workflow-policy"
cp -f "${INSTALL_SRC}/skills/github-actions-workflow-policy/SKILL.md" "${DEST_BASE}/skills/github-actions-workflow-policy/"

echo "Installed to:"
echo "  ${DEST_BASE}/workflow-policy/"
echo "  ${DEST_BASE}/rules/github-actions-workflow-policy.mdc"
echo "  ${DEST_BASE}/skills/github-actions-workflow-policy/SKILL.md"

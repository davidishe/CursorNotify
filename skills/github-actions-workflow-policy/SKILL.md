---
name: github-actions-workflow-policy
description: Align GitHub Actions workflows with ~/.cursor/workflow-policy (deploy + reusable Telegram notify). Use when the user works on CI, deploy, workflows, or GitHub Actions.
---

# GitHub Actions workflow policy

Enforce the local contract in `~/.cursor/workflow-policy/` whenever workflows are created or edited.

## Before changing workflows

1. Read `~/.cursor/workflow-policy/REQUIREMENTS.md` and `~/.cursor/workflow-policy/policy.json`.
2. Open `~/.cursor/workflow-policy/snippets/notify-reusable-caller.yml` for the canonical notify job shape.

## Algorithm

1. List all workflow files under `.github/workflows/` in the project.
2. Identify the **deploy** job (or equivalent: the job whose success/failure should trigger Telegram). If there are several candidates, ask the user which job id to wire to `notify`.
3. Check for a **notify** job that:
   - lists `needs: [<deploy_job_id>]`;
   - sets `if: always()`;
   - calls `uses: .../reusable-telegram-deploy-notify.yml@...` (not inline Telegram `curl` in the app repo);
   - passes `with.deploy_result: ${{ needs.<deploy_job_id>.result }}`;
   - uses `secrets: inherit`.
4. If anything is missing, add or fix using the snippet. Substitute `OWNER/CursorNotify` and `@REF` from user context or env `CURSOR_NOTIFY_GHA_REPO`; default ref `main` if unspecified.
5. Remind the user: repository must define secrets `TELEGRAM_BOT_TOKEN_NOTIFY` and `TELEGRAM_CHAT_ID` (e.g. `scripts/push-gh-telegram-secrets.sh` from the CursorNotify repo). The upstream repo that hosts the reusable workflow must be accessible (typically public).

## Do not

- Commit secrets or paste token values into the repo.
- Duplicate long Telegram `curl` blocks in application repos; central logic stays in CursorNotify reusable workflow.

## Related automation

- Install workflow file into a project: `scripts/install-reusable-telegram-notify.sh` (CursorNotify repo).
- Copy this policy bundle to home: `scripts/install-workflow-policy-to-home.sh`.

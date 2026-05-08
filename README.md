# Telegram Completion Notify Plugin

Minimal Cursor plugin scaffold for Telegram task-completion notifications.

## What this plugin includes

- A reusable skill for Telegram completion notifications.
- A rule that always loads the skill.
- A hook script template and env template with placeholders only.
- No real bot token or chat id in repository files.

## Security model

- Store real secrets locally in `~/.cursor/telegram-notify.env`.
- Keep repository files secret-free.
- Use only `*.example` files for env templates.

## Local setup (user machine)

1. Copy `hooks/telegram-notify.env.example` to `~/.cursor/telegram-notify.env`.
2. Fill local values:
   - `TELEGRAM_BOT_TOKEN_NOTIFY=<your_bot_token>`
   - `TELEGRAM_CHAT_ID=<your_chat_or_group_id>`
3. Copy `hooks/telegram-task-complete.sh` to `~/.cursor/hooks/telegram-task-complete.sh`.
4. Make it executable:
   - `chmod +x ~/.cursor/hooks/telegram-task-complete.sh`
5. Add/update `~/.cursor/hooks.json` with a `stop` hook using `./hooks/telegram-task-complete.sh`.

## GitHub Actions: deploy + Telegram (all projects)

**What was confusing before:** the first version only added workflow files *inside this repo*. Your other repositories did not change by themselves.

**How it works:** the real notify logic lives in **one reusable workflow** — [.github/workflows/reusable-telegram-deploy-notify.yml](.github/workflows/reusable-telegram-deploy-notify.yml). Each application repo calls that workflow from a `notify` job.

You have two ways to wire it:

### A) Local vendored copy (recommended if CursorNotify is **not** on GitHub)

Copies `reusable-telegram-deploy-notify.yml` **into** the target repo. The caller uses `uses: ./.github/workflows/reusable-telegram-deploy-notify.yml`. No public `OWNER/CursorNotify` repo is required.

From your clone of this repo:

```bash
./scripts/install-reusable-telegram-notify.sh /path/to/your/app --local
./scripts/push-gh-telegram-secrets.sh OWNER/YOUR_APP
```

Then commit **both** `your/app/.github/workflows/reusable-telegram-deploy-notify.yml` and `deploy-telegram-notify.yml`, and edit the `deploy` job with real steps.

When you change notify behavior in CursorNotify, copy the updated reusable file into each app repo (or re-run the install script with `--local --force`).

### B) Remote reusable (CursorNotify **published** on GitHub)

Each application repo adds a short workflow that calls `OWNER/CursorNotify/.github/workflows/reusable-telegram-deploy-notify.yml@REF`. You update behavior once in the published repo; every caller gets the change after you bump `@REF`.

Requirements:

- The copy of `CursorNotify` you reference (`OWNER/CursorNotify`) must be **public**, unless you use GitHub’s rules for reusing private workflows.
- Each app repo still needs **its own** Actions secrets `TELEGRAM_BOT_TOKEN_NOTIFY` and `TELEGRAM_CHAT_ID` (same values as in `~/.cursor/telegram-notify.env`).

#### One-time setup (credentials)

1. Fill `~/.cursor/telegram-notify.env` (see Local setup above).
2. Install [GitHub CLI](https://cli.github.com/) and sign in (`gh auth login`, or `GH_TOKEN` in that same file).

#### Apply to one project (remote mode)

```bash
export CURSOR_NOTIFY_GHA_REPO=YOUR_GITHUB_USERNAME/CursorNotify   # or pass as 2nd arg
./scripts/install-reusable-telegram-notify.sh /path/to/your/app
./scripts/push-gh-telegram-secrets.sh OWNER/YOUR_APP
```

Then commit `your/app/.github/workflows/deploy-telegram-notify.yml` and edit the `deploy` job with real steps.

### Apply secrets to many repositories

1. Copy [hooks/telegram-notify-repos.txt.example](hooks/telegram-notify-repos.txt.example) to `~/.cursor/telegram-notify-repos.txt` and list every `OWNER/repo`.
2. Run:

   ```bash
   ./scripts/push-gh-telegram-secrets-all.sh
   ```

   Or: `./scripts/push-gh-telegram-secrets-all.sh owner/a owner/b`  
   Add `--force` to overwrite existing secret names.

### This repository (dogfooding)

[.github/workflows/deploy-telegram-notify.yml](.github/workflows/deploy-telegram-notify.yml) calls the reusable workflow via `uses: ./.github/workflows/reusable-telegram-deploy-notify.yml` (same pattern as **local vendored** installs above). Remote callers use `uses: OWNER/CursorNotify/.github/workflows/reusable-telegram-deploy-notify.yml@main` only when you actually publish CursorNotify.

[scripts/send-telegram-deploy-notify.sh](scripts/send-telegram-deploy-notify.sh) remains useful for **local** dry-runs after `source ~/.cursor/telegram-notify.env`.

### Verify notifications

- Run the workflow from **Actions** (or push to `main`) after secrets exist.
- Expect a Telegram message on success; temporarily `exit 1` in `deploy` on a branch to test failure.

## Local workflow policy (Cursor agent)

So that **every project** follows the same GitHub Actions rules while you work in Cursor:

| Location in repo | Role |
|------------------|------|
| [workflow-policy/REQUIREMENTS.md](workflow-policy/REQUIREMENTS.md) | Human + agent contract (secrets, reusable notify, `if: always`) |
| [workflow-policy/policy.json](workflow-policy/policy.json) | Machine-readable summary |
| [workflow-policy/snippets/](workflow-policy/snippets/) | Paste-ready YAML fragments |

Install into your home directory (rule with **globs** on `.github/workflows/**`, skill, and policy copy):

```bash
./scripts/install-workflow-policy-to-home.sh
```

After that, Cursor loads **`~/.cursor/rules/github-actions-workflow-policy.mdc`** when you touch workflow files, and the skill **`github-actions-workflow-policy`** under **`~/.cursor/skills/`** describes the merge checklist. Re-run the install script after pulling updates to this repo.

**Note:** the IDE does not rewrite workflows on save by itself; the agent applies the policy when you (or it) edit CI files.

## Publish readiness

Before publishing, run through `PUBLISH_CHECKLIST.md`.
# CursorNotify

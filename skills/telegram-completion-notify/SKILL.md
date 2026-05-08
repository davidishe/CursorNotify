---
name: telegram-completion-notify
description: Configure and maintain Telegram notifications when Cursor finishes a task. Use when the user asks for completion alerts, bot token/chat id setup, or cross-project Telegram notifications.
---

# Telegram Completion Notify

Set up notifications with one user-level config shared across all projects.

## Goal

- Send a Telegram message on agent completion (`stop` hook event).
- Store `TELEGRAM_BOT_TOKEN_NOTIFY` and `TELEGRAM_CHAT_ID` once.
- Let users change credentials anytime without touching project files.

## Required user-level files

- `~/.cursor/hooks.json`
- `~/.cursor/hooks/telegram-task-complete.sh`
- `~/.cursor/telegram-notify.env`

## Workflow

1. Check whether `~/.cursor/hooks.json` already exists.
2. If it exists, preserve unrelated hooks and merge this stop hook:
   - event: `stop`
   - command: `./hooks/telegram-task-complete.sh`
   - timeout: `10`
   - failClosed: `false`
3. Create/update `~/.cursor/hooks/telegram-task-complete.sh`.
4. Create `~/.cursor/telegram-notify.env` if missing with empty values:
   - `TELEGRAM_BOT_TOKEN_NOTIFY=`
   - `TELEGRAM_CHAT_ID=`
5. Make script executable.
6. Never commit real bot tokens to repository files.

## Script requirements

- Read hook payload from stdin and ignore it safely.
- Load `~/.cursor/telegram-notify.env`.
- Exit quietly if config/token/chat id is missing.
- Send message via Telegram Bot API:
  - endpoint: `https://api.telegram.org/bot<TOKEN>/sendMessage`
  - fields: `chat_id`, `text`
- Message must include:
  - static completion marker
  - project name from current working directory
  - current timestamp
- Fail open: if Telegram is unavailable, do not block the agent.

## GitHub Actions (many repositories)

Central notify logic lives in this plugin repo: `.github/workflows/reusable-telegram-deploy-notify.yml`. Other projects call it with `uses: OWNER/CursorNotify/.github/workflows/reusable-telegram-deploy-notify.yml@REF` and `secrets: inherit`.

- **Install workflow file into a project:** `scripts/install-reusable-telegram-notify.sh /path/to/repo OWNER/CursorNotify [ref]` (or set `CURSOR_NOTIFY_GHA_REPO`).
- **Push Telegram secrets to one repo:** `scripts/push-gh-telegram-secrets.sh OWNER/REPO` (reads `~/.cursor/telegram-notify.env`).
- **Push secrets to many repos:** create `~/.cursor/telegram-notify-repos.txt` (see `hooks/telegram-notify-repos.txt.example`), then `scripts/push-gh-telegram-secrets-all.sh`.

`OWNER/CursorNotify` must be **public** (or the caller repo must be allowed to reuse private workflows per GitHub rules). Pin `@ref` to a tag for stability.

## Verification checklist

- `bash -n ~/.cursor/hooks/telegram-task-complete.sh` passes.
- `~/.cursor/hooks/telegram-task-complete.sh` has executable bit.
- `~/.cursor/hooks.json` is valid JSON.
- User confirms bot is present in target chat/group and can post messages.

# Telegram completion notification hook

This hook sends a Telegram message whenever the agent finishes a task (`stop` event).
It supports one global config for all projects.

## Setup

1. Open `~/.cursor/telegram-notify.env` (create if missing).
2. Set values:
   - `TELEGRAM_BOT_TOKEN_NOTIFY=<your bot token>`
   - `TELEGRAM_CHAT_ID=<your group or chat id>`
3. Ensure the bot is added to your target group and has permission to send messages.

## Notes

- Active global hook config is in `~/.cursor/hooks.json`.
- Script is `.cursor/hooks/telegram-task-complete.sh`.
- Primary config location: `~/.cursor/telegram-notify.env`.
- Optional project-local fallback: `.cursor/hooks/telegram-notify.env` (ignored by git via `.cursor/hooks/.gitignore`).

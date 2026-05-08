# Publish Checklist

## Secrets and privacy

- [ ] No real `TELEGRAM_BOT_TOKEN_NOTIFY` in tracked files.
- [ ] No real `TELEGRAM_CHAT_ID` in tracked files.
- [ ] Only template env files are present (`*.example`).
- [ ] Local secret files are ignored by git (`telegram-notify.env`, `.env`, `*.local`).
- [ ] If token was exposed in chat/logs, rotate it before publishing.

## Plugin structure

- [ ] `.cursor-plugin/plugin.json` exists and has valid JSON.
- [ ] Plugin metadata (`name`, `version`, `description`, `license`) is filled.
- [ ] `skills/telegram-completion-notify/SKILL.md` has valid frontmatter.
- [ ] `rules/use-telegram-skill.mdc` has valid frontmatter.
- [ ] Hook templates are present under `hooks/`.

## Runtime validation

- [ ] Hook script syntax check passes (`bash -n hooks/telegram-task-complete.sh`).
- [ ] Hook script is executable when installed on user machine.
- [ ] User can send a Telegram test message with local env values.

## Distribution

- [ ] README explains local secret setup in `~/.cursor/telegram-notify.env`.
- [ ] README explains user-level `~/.cursor/hooks.json` wiring.
- [ ] No absolute machine-specific paths in plugin files.

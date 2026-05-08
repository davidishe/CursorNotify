# Workflow policy: deploy + Telegram notify

Единый контракт для локальных `.github/workflows` во всех проектах. Тело отправки в Telegram **не дублировать** в репозитории приложения — только вызов **reusable workflow** (локально в том же репо или с GitHub).

## Обязательные секреты (GitHub Actions)

В каждом репозитории, где нужны уведомления:

- `TELEGRAM_BOT_TOKEN_NOTIFY`
- `TELEGRAM_CHAT_ID`

Значения брать из `~/.cursor/telegram-notify.env`. Заливка: `scripts/push-gh-telegram-secrets.sh OWNER/REPO` или массово `scripts/push-gh-telegram-secrets-all.sh` (из репозитория CursorNotify).

## Reusable workflow

Исходник логики уведомлений: репозиторий **CursorNotify**, файл `.github/workflows/reusable-telegram-deploy-notify.yml`.

### Режим A — локальная копия в репо приложения (без публикации CursorNotify на GitHub)

Скопируйте этот файл в целевой репозиторий как `.github/workflows/reusable-telegram-deploy-notify.yml` (см. `scripts/install-reusable-telegram-notify.sh /path/to/app --local`).

Job уведомлений:

```yaml
uses: ./.github/workflows/reusable-telegram-deploy-notify.yml
with:
  deploy_result: ${{ needs.<deploy_job_id>.result }}
secrets: inherit
```

### Режим B — внешний reusable на GitHub (CursorNotify опубликован)

```yaml
uses: OWNER/CursorNotify/.github/workflows/reusable-telegram-deploy-notify.yml@REF
with:
  deploy_result: ${{ needs.<deploy_job_id>.result }}
secrets: inherit
```

- Замените `OWNER/CursorNotify` на ваш форк/апстрим (переменная окружения `CURSOR_NOTIFY_GHA_REPO` при генерации).
- Закрепите `REF` (например `main` или тег `v1`).
- Репозиторий с reusable workflow должен быть **доступен** GitHub для вызывающего репо (обычно public).

## Структура jobs

1. **Deploy (или ваш основной job деплоя)** — любое имя; в примерах используется `deploy`.
2. **Notify** — отдельный job:
   - `needs: [<deploy_job_id>]`
   - `if: always()` — чтобы уведомление ушло и при падении деплоя.
   - Шаг отправки не должен менять итоговый статус деплоя: `continue-on-error: true` на шаге **или** fail-open внутри reusable (уже заложено в reusable).

## Запреты

- Не коммитить токены и `.env` с секретами.
- Не копировать длинный `curl` к Telegram в каждый проект — только reusable `uses`.

## Машиночитаемый контракт

См. `policy.json` рядом с этим файлом.

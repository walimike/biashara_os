#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ ! -f .env.production ]]; then
  cp .env.production.example .env.production
  echo "Created .env.production — edit it, then run this script again."
  exit 1
fi

# shellcheck disable=SC1091
source .env.production

missing=()
[[ -z "${RAILS_MASTER_KEY:-}" ]] && missing+=("RAILS_MASTER_KEY")
[[ -z "${SECRET_KEY_BASE:-}" ]] && missing+=("SECRET_KEY_BASE")
[[ -z "${APP_DOMAIN:-}" || "${APP_DOMAIN}" == "app.example.com" ]] && missing+=("APP_DOMAIN")
[[ -z "${API_DOMAIN:-}" || "${API_DOMAIN}" == "api.example.com" ]] && missing+=("API_DOMAIN")

if ((${#missing[@]} > 0)); then
  echo "Set these in .env.production before deploying: ${missing[*]}"
  exit 1
fi

echo "Building and starting BiasharaOS on ${APP_DOMAIN} + ${API_DOMAIN}..."
docker compose -f docker-compose.prod.yml --env-file .env.production up --build -d

echo ""
echo "Deployed. After DNS propagates:"
echo "  App:  https://${APP_DOMAIN}"
echo "  API:  https://${API_DOMAIN}/up (health check)"
echo ""
echo "Logs: docker compose -f docker-compose.prod.yml logs -f"

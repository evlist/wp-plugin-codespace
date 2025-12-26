#!/usr/bin/env bash
# WP-CLI wrapper using docker compose with fixed project name and Codespaces forwarded URL on the configured port (default 8080).
set -euo pipefail

COMPOSE_FILE=".devcontainer/docker-compose.yml"
SERVICE="wordpress"
PROJECT="${COMPOSE_PROJECT_NAME:?COMPOSE_PROJECT_NAME must be set (devcontainer.json containerEnv)}"

WP_PATH="${WP_PATH:-/var/www/html}"
PORT="${WP_HOST_PORT:-8080}"

# Prefer Codespaces forwarded URL for the configured port; fallback to WP_SITE_URL or localhost
if [[ -n "${CODESPACE_NAME:-}" && -n "${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-}" ]]; then
  SITE_URL="https://${CODESPACE_NAME}-${PORT}.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
else
  SITE_URL="${WP_SITE_URL:-http://localhost:${PORT}}"
fi

HOST="$(echo "$SITE_URL" | sed -E 's~^[a-z]+://([^/]+).*~\1~')"

# Utility: print the detected site URL and exit (for use by wp-install.sh)
if [[ "${1:-}" == "__print-url" ]]; then
  echo "$SITE_URL"
  exit 0
fi

# Run wp directly; pass args as array to preserve quoting
docker compose -f "$COMPOSE_FILE" -p "$PROJECT" exec -u root \
  -e "HTTP_HOST=${HOST}" \
  -e "HTTPS=on" \
  -e "HTTP_X_FORWARDED_PROTO=https" \
  "$SERVICE" \
  wp --path="$WP_PATH" --allow-root --url="$SITE_URL" "$@"
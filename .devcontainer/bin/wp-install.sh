#!/usr/bin/env bash
# Idempotent WordPress installer that delegates to wp.sh for URL/env handling.
set -euo pipefail

COMPOSE_FILE=".devcontainer/docker-compose.yml"
DB_SERVICE="db"
PROJECT="${COMPOSE_PROJECT_NAME:?COMPOSE_PROJECT_NAME must be set (devcontainer.json containerEnv)}"

WP_PATH="${WP_PATH:-/var/www/html}"
SITE_TITLE="${WP_TITLE:-WP Dev}"
ADMIN_USER="${WP_ADMIN_USER:-admin}"
ADMIN_PASS="${WP_ADMIN_PASS:-admin}"
ADMIN_EMAIL="${WP_ADMIN_EMAIL:-admin@example.test}"
LOCALE="${WP_LOCALE:-en_US}"
PLUGIN_SLUG="${PLUGIN_SLUG:-hello-world}"
WP_PLUGINS="${WP_PLUGINS:-}"

wpcli() { .devcontainer/bin/wp.sh "$@"; }
detected_url() { .devcontainer/bin/wp.sh __print-url; }

echo "Waiting for DB to become healthy..."
for i in $(seq 1 60); do
  if docker compose -f "$COMPOSE_FILE" -p "$PROJECT" ps --services --filter "status=running" | grep -q "^${DB_SERVICE}$"; then
    if docker compose -f "$COMPOSE_FILE" -p "$PROJECT" exec "$DB_SERVICE" mysqladmin ping -uroot -p"${MYSQL_ROOT_PASSWORD:-root}" --silent >/dev/null 2>&1; then
      echo "DB is healthy."
      break
    fi
  fi
  echo "DB not ready yet (attempt $i/60)..."; sleep 2
done

TARGET_URL="$(detected_url)"
echo "Target site URL: ${TARGET_URL}"

echo "Checking if WordPress is installed..."
if wpcli core is-installed >/dev/null 2>&1; then
  echo "WordPress already installed."
else
  echo "Installing WordPress..."
  wpcli core install \
    --title="$SITE_TITLE" \
    --admin_user="$ADMIN_USER" \
    --admin_password="$ADMIN_PASS" \
    --admin_email="$ADMIN_EMAIL" \
    --skip-email
  if [[ -n "$LOCALE" && "$LOCALE" != "en_US" ]]; then
    wpcli language core install "$LOCALE"
    wpcli site switch-language "$LOCALE"
  fi
fi

# Force canonical URL via constants and keep DB options in sync
wpcli config set WP_HOME "$TARGET_URL" --type=constant
wpcli config set WP_SITEURL "$TARGET_URL" --type=constant
wpcli config set FORCE_SSL_ADMIN true --type=constant --raw || true

wpcli option update siteurl "$TARGET_URL"
wpcli option update home "$TARGET_URL"

# Pretty permalinks and flush
wpcli rewrite structure '/%postname%/'
wpcli rewrite flush

# Ensure admin user exists
wpcli user get "$ADMIN_USER" >/dev/null 2>&1 || wpcli user create "$ADMIN_USER" "$ADMIN_EMAIL" --user_pass="$ADMIN_PASS" --role=administrator

# Install & activate registry plugins (comma-separated)
if [[ -n "$WP_PLUGINS" ]]; then
  IFS=',' read -ra PLUGS <<< "$WP_PLUGINS"
  for p in "${PLUGS[@]}"; do
    wpcli plugin is-installed "$p" >/dev/null 2>&1 || wpcli plugin install "$p"
    wpcli plugin activate "$p"
  done
fi

# Activate local plugin if mounted
if wpcli plugin is-installed "$PLUGIN_SLUG" >/dev/null 2>&1; then
  wpcli plugin activate "$PLUGIN_SLUG"
  echo "Local plugin '${PLUGIN_SLUG}' activated."
else
  echo "Local plugin '${PLUGIN_SLUG}' not found under wp-content/plugins. Ensure plugins-src/${PLUGIN_SLUG} exists."
fi

# Fix ownership
docker compose -f "$COMPOSE_FILE" -p "$PROJECT" exec -u root wordpress bash -lc "chown -R www-data:www-data '${WP_PATH}' || true"

# Show final URL
wpcli option get siteurl
echo "Setup complete."
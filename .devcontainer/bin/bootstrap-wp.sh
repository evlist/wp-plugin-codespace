#!/usr/bin/env bash
set -euo pipefail

log() { printf "[bootstrap] %s\n" "$*"; }
die() { printf "[bootstrap:ERROR] %s\n" "$*" >&2; exit 1; }

DB_NAME="${WP_DB_NAME:-wordpress}"
DB_USER="${WP_DB_USER:-wordpress}"
DB_PASS="${WP_DB_PASS:-wordpress}"
DB_HOST="${WP_DB_HOST:-127.0.0.1}"

TITLE="${WP_TITLE:-Codespace Dev}"
ADMIN_USER="${WP_ADMIN_USER:-admin}"
ADMIN_PASS="${WP_ADMIN_PASS:-admin}"
ADMIN_EMAIL="${WP_ADMIN_EMAIL:-admin@example.com}"

PLUGIN_SLUG="${PLUGIN_SLUG:-hello-world}"
DOCROOT="/var/www/html"
WORKSPACE="/workspaces/wp-plugin-codespace"
WP_URL="http://localhost"  # forwardPorts: [80] in devcontainer.json

# --- MariaDB startup (robust) ---
log "Preparing MariaDB directories..."
# Ensure runtime socket dir exists with correct ownership
sudo install -o mysql -g mysql -m 0755 -d /run/mysqld

# Initialize data dir if missing
if [ ! -d /var/lib/mysql/mysql ]; then
  log "Initializing MariaDB data directory..."
  if command -v mariadb-install-db >/dev/null 2>&1; then
    sudo mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/dev/null
  else
    sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql >/dev/null
  fi
fi

log "Starting MariaDB via service..."
if ! sudo service mariadb start; then
  log "Service start failed, trying to launch mariadbd directly..."
  # Fallback to direct daemon start
  sudo /usr/sbin/mariadbd \
    --datadir=/var/lib/mysql \
    --socket=/run/mysqld/mysqld.sock \
    --bind-address=127.0.0.1 \
    --skip-networking=0 \
    >/var/log/mysql/error.log 2>&1 &
fi

log "Waiting for MariaDB to accept connections..."
# Bounded wait: up to ~30 seconds
WAIT_OK=0
for i in $(seq 1 60); do
  if sudo mariadb -e "SELECT 1" >/dev/null 2>&1; then
    WAIT_OK=1
    break
  fi
  sleep 0.5
done

if [ "$WAIT_OK" -ne 1 ]; then
  log "MariaDB did not become ready; collecting diagnostics..."
  ps aux | grep -E 'mariadb[d]?|mysqld' || true
  ls -la /run/mysqld || true
  [ -f /var/log/mysql/error.log ] && tail -n 200 /var/log/mysql/error.log || true
  die "MariaDB failed to start within the timeout."
fi

log "Ensuring database and user..."
sudo mariadb <<SQL
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
SQL

# Silence Apache ServerName notice
echo 'ServerName localhost' | sudo tee /etc/apache2/conf-available/servername.conf >/dev/null
sudo a2enconf servername >/dev/null 2>&1 || true

# Allow to sudo as www-data for wp cli
echo 'vscode ALL=(www-data) NOPASSWD: /usr/local/bin/wp *' | sudo tee /etc/sudoers.d/99-wp-cli

# Prefer WordPress at /
sudo rm -f /var/www/html/index.html || true
echo 'DirectoryIndex index.php index.html' | sudo tee /etc/apache2/conf-available/dev-index.conf >/dev/null
sudo a2enconf dev-index >/dev/null 2>&1 || true

# --- WordPress setup ---
log "Preparing WordPress docroot at ${DOCROOT}..."
sudo mkdir -p "$DOCROOT"
sudo chown -R www-data:www-data "$DOCROOT"

# WP-CLI cache in /tmp (writable)
export WP_CLI_VAR_DIR="/var/www/.wp-cli/"
sudo mkdir -p "$WP_CLI_VAR_DIR"
sudo chown -R www-data:www-data "$WP_CLI_VAR_DIR"

if [ ! -f "$DOCROOT/wp-load.php" ]; then
  log "Downloading WordPress core..."
  sudo -u www-data wp core download --path="$DOCROOT" --force
fi

if [ ! -f "$DOCROOT/wp-config.php" ]; then
  log "Creating wp-config.php..."
  sudo -u www-data wp config create \
    --path="$DOCROOT" \
    --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PASS" --dbhost="$DB_HOST" \
    --skip-check
fi

if ! sudo -u www-data wp core is-installed --path="$DOCROOT" >/dev/null 2>&1; then
  log "Installing WordPress..."
  sudo -u www-data wp core install \
    --path="$DOCROOT" \
    --url="$WP_URL" \
    --title="$TITLE" \
    --admin_user="$ADMIN_USER" --admin_password="$ADMIN_PASS" --admin_email="$ADMIN_EMAIL"
fi

log "Linking workspace plugin and mu-plugins..."
sudo mkdir -p "$DOCROOT/wp-content/plugins" "$DOCROOT/wp-content"
if [ -d "$WORKSPACE/plugins-src/$PLUGIN_SLUG" ]; then
  sudo ln -sfn "$WORKSPACE/plugins-src/$PLUGIN_SLUG" "$DOCROOT/wp-content/plugins/$PLUGIN_SLUG"
fi
if [ -d "$WORKSPACE/.devcontainer/wp-content/mu-plugins" ]; then
  sudo rm -rf "$DOCROOT/wp-content/mu-plugins" || true
  sudo ln -sfn "$WORKSPACE/.devcontainer/wp-content/mu-plugins" "$DOCROOT/wp-content/mu-plugins"
fi

# --- Apache startup ---
log "Starting Apache..."
sudo a2enmod rewrite >/dev/null 2>&1 || true
sudo service apache2 start || true

# Pretty permalinks best-effort
sudo -u www-data wp rewrite structure '/%postname%/' --path="$DOCROOT" >/dev/null 2>&1 || true
sudo -u www-data wp rewrite flush --path="$DOCROOT" >/dev/null 2>&1 || true

log "Done. Visit $WP_URL"
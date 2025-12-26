#!/bin/bash
# Idempotent WordPress installation script

set -e

echo "🚀 Starting WordPress installation..."

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Navigate to project root
cd "$PROJECT_ROOT"

# Load environment variables safely
if [ -f .devcontainer/.env ]; then
    set -a
    source .devcontainer/.env
    set +a
fi

# Set defaults
WP_SITE_URL="${WP_SITE_URL:-http://localhost:8080}"
WP_SITE_TITLE="${WP_SITE_TITLE:-WordPress Plugin Development}"
WP_ADMIN_USER="${WP_ADMIN_USER:-admin}"
WP_ADMIN_PASSWORD="${WP_ADMIN_PASSWORD:-admin}"
WP_ADMIN_EMAIL="${WP_ADMIN_EMAIL:-admin@example.com}"
WP_LOCALE="${WP_LOCALE:-en_US}"
PLUGIN_SLUG="${PLUGIN_SLUG:-hello-world}"

# Helper function to run wp-cli commands
wp_cli() {
    docker compose -f .devcontainer/docker-compose.yml exec -u www-data -T wordpress wp "$@"
}

# Wait for WordPress container to be ready
echo "⏳ Waiting for WordPress container..."
max_attempts=30
attempt=0
until docker compose -f .devcontainer/docker-compose.yml exec -T wordpress test -f /var/www/html/wp-config.php 2>/dev/null || [ $attempt -eq $max_attempts ]; do
    attempt=$((attempt + 1))
    echo "   Attempt $attempt/$max_attempts..."
    sleep 2
done

if [ $attempt -eq $max_attempts ]; then
    echo "❌ WordPress container did not become ready in time"
    exit 1
fi

echo "✅ WordPress container is ready"

# Wait for database to be ready
echo "⏳ Waiting for database connection..."
max_attempts=30
attempt=0
until wp_cli db check 2>/dev/null || [ $attempt -eq $max_attempts ]; do
    attempt=$((attempt + 1))
    echo "   Attempt $attempt/$max_attempts..."
    sleep 2
done

if [ $attempt -eq $max_attempts ]; then
    echo "❌ Database did not become ready in time"
    exit 1
fi

echo "✅ Database is ready"

# Check if WordPress is already installed
if wp_cli core is-installed 2>/dev/null; then
    echo "ℹ️  WordPress is already installed, skipping installation..."
else
    echo "📦 Installing WordPress..."
    wp_cli core install \
        --url="$WP_SITE_URL" \
        --title="$WP_SITE_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email
    echo "✅ WordPress installed successfully"
fi

# Set language
if [ "$WP_LOCALE" != "en_US" ]; then
    echo "🌍 Setting language to $WP_LOCALE..."
    wp_cli language core install "$WP_LOCALE" --activate || echo "⚠️  Language installation failed, continuing..."
fi

# Set permalinks
echo "🔗 Setting permalinks..."
wp_cli rewrite structure '/%postname%/' --hard

# Install and activate plugins from WordPress.org
if [ -n "$WP_PLUGINS" ]; then
    echo "🔌 Installing plugins: $WP_PLUGINS"
    IFS=',' read -ra PLUGINS_ARRAY <<< "$WP_PLUGINS"
    for plugin in "${PLUGINS_ARRAY[@]}"; do
        plugin=$(echo "$plugin" | xargs) # trim whitespace
        if [ -n "$plugin" ]; then
            echo "   Installing $plugin..."
            wp_cli plugin install "$plugin" --activate || echo "⚠️  Failed to install $plugin, continuing..."
        fi
    done
fi

# Activate local plugin if it exists
if [ -n "$PLUGIN_SLUG" ] && [ -d "plugins-src/$PLUGIN_SLUG" ]; then
    echo "🔌 Activating local plugin: $PLUGIN_SLUG"
    if wp_cli plugin is-installed "$PLUGIN_SLUG" 2>/dev/null; then
        wp_cli plugin activate "$PLUGIN_SLUG" || echo "⚠️  Failed to activate $PLUGIN_SLUG, continuing..."
    else
        echo "⚠️  Plugin $PLUGIN_SLUG not found in WordPress, it may not be properly mounted"
    fi
fi

# Fix ownership
echo "🔧 Fixing file permissions..."
docker compose -f .devcontainer/docker-compose.yml exec -T wordpress chown -R www-data:www-data /var/www/html

# Display site URL
echo ""
echo "✅ WordPress installation complete!"
echo "🌐 Site URL: $WP_SITE_URL"
echo "👤 Admin User: $WP_ADMIN_USER"
echo "🔑 Admin Password: $WP_ADMIN_PASSWORD"
echo ""
echo "You can access WordPress at: $WP_SITE_URL"
echo "Admin panel: $WP_SITE_URL/wp-admin"
echo ""

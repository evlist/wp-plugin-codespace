# wp-plugin-codespace

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=evlist/wp-plugin-codespace)

A complete GitHub Codespaces development environment for WordPress plugin debugging and development.

## 🚀 Quick Start

1. Click the "Open in GitHub Codespaces" badge above or go to the repository and click "Code" → "Codespaces" → "Create codespace on main"
2. Wait for the devcontainer to build and the WordPress installation to complete (this takes a few minutes on first run)
3. Once ready, you'll see a notification to open the WordPress site. Click it or navigate to the "Ports" tab and open port 8080
4. Access WordPress:
   - **Site URL**: Follow the link in the "PORTS" tab
   - **Admin URL**: `<Site URL>/wp-admin`
   - **Username**: `admin`
   - **Password**: `admin`

## ✨ Features

This devcontainer provides a complete WordPress development environment with:

- **WordPress & MySQL**: Latest versions
- **WP-CLI**: Pre-installed for command-line WordPress management
- **Automatic Setup**: Idempotent installer script completes WordPress configuration
- **Plugin Mounting**: Local plugin directory automatically symlinked and activated
- **Sample Plugin**: "Local Hello World" plugin demonstrating WordPress features
- **Port Forwarding**: WordPress accessible via Codespaces preview (port 80)

## 📁 Project Structure

```
.
├── .devcontainer/
│   ├── devcontainer.json       # VS Code devcontainer configuration
│   ├── docker-compose.yml      # Docker Compose services definition
│   ├── Dockerfile              # WordPress container with WP-CLI
│   ├── .env                    # Environment variables (customizable)
│   └── bin/
│       ├── bootstrap-wp.sh     # Bootstrap: DB, Apache, WP core, symlinks
│       ├── wp.sh               # WP-CLI wrapper script
│       ├── db.sh               # MySQL client wrapper script
│       └── wp-install.sh       # WordPress installation script
├── .vscode/
│   ├── launch.json             # Static PHP debug config (single mapping)
│   └── intelephense-stubs/
│       └── wp-cli.php          # Editor-only stub for WP-CLI
└── plugins-src/
    └── hello-world/            # Sample plugin directory
        ├── hello-world.php
        └── README.md
```

## 🔧 Configuration

All configuration is managed through `.devcontainer/.env`:

```bash
# WordPress database
WP_DB_NAME=wordpress
WP_DB_USER=wordpress
WP_DB_PASS=wordpress
WP_DB_HOST=127.0.0.1

# Site and admin
WP_TITLE=Codespace Dev
WP_ADMIN_USER=admin
WP_ADMIN_PASS=admin
WP_ADMIN_EMAIL=admin@example.com

# Local Plugin Configuration
PLUGIN_SLUG=local-hello-world
PLUGIN_DIR=plugins-src/hello-world

# Additional Plugins (comma-separated)
WP_PLUGINS=loco-translate
```

To customize your environment, edit these values before creating your codespace or rebuild after changes.

## 🛠️ Available Commands

### WP-CLI Commands
Execute WP-CLI commands in the WordPress container:

```bash
# Run any WP-CLI command
wp [command]

# Examples:
wp plugin list
wp user list
wp post create --post_title="Test Post" --post_status=publish
wp local-hello-world greet "Developer"
```

## 📝 Sample Plugin

The included "Local Hello World" plugin demonstrates:

- **Shortcode**: `[local_hello_world name="Developer"]`
- **REST API**: `/wp-json/hello/v1/ping`
- **Admin Notice**: Displayed on the dashboard
- **Admin Bar Node**: Custom toolbar item
- **Footer Marker**: HTML comment in page footer
- **WP-CLI Commands**: `wp local-hello-world greet`, `wp local-hello-world info`, `wp local-hello-world test-api`
- **Activation/Deactivation Hooks**: Proper plugin lifecycle management

See `plugins-src/local-hello-world/README.md` for detailed usage and validation steps.

## ⚙️ Server path alignment (Docroot symlink)

The bootstrap script symlinks `/var/www/html` to the workspace docroot so the debugger and WP-CLI operate on the same files:

- Workspace docroot: `${workspaceFolder}/.devcontainer/var/www/html`
- Symlink: `/var/www/html -> ${workspaceFolder}/.devcontainer/var/www/html`

This ensures Xdebug’s server paths match files in your workspace and WP-CLI installs WordPress under the workspace.

## 🐞 Debugging (Xdebug)

We ship a simple, static PHP debug configuration. One listener handles both HTTP and CLI.

```jsonc
{
  // Static VS Code PHP debug config.
  // /var/www/html is symlinked to the workspace docroot by bootstrap.
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Listen for Xdebug",
      "type": "php",
      "request": "launch",
      "port": 9003,
      "log": true,
      "pathMappings": {
        "/var/www/html": "${workspaceFolder}/.devcontainer/var/www/html"
      }
    }
  ]
}
```

Notes:
- No duplicate mappings are needed; the single root mapping covers WordPress core and plugins.
- If you change the workspace docroot path, update the right-hand side of `pathMappings` accordingly.

## 🧠 Editor setup: IntelliSense (Intelephense)

- WordPress core is present in the workspace docroot, so Intelephense indexes the real source. No custom `intelephense.stubs` configuration is required.
- If you previously configured stubs, you may remove that setting from `.vscode/settings.json` to use Intelephense’s defaults.
- Changes to editor settings apply immediately; if the UI looks stale, run “Developer: Reload Window”.

### WP‑CLI IntelliSense

For better IntelliSense when writing WP‑CLI commands, we include a lightweight editor-only stub:

- File: `.vscode/intelephense-stubs/wp-cli.php`
- This stub is for static analysis only and is not loaded at runtime by WordPress.

## 🔐 Important Notes

- **Development Only**: This environment is for development and testing only. Do not use in production.
- **Security**: Default credentials are weak and intended for local development only.
- **Performance**: First startup may take several minutes as Docker images are downloaded and WordPress is configured.

## 📚 Additional Resources

- [WordPress Plugin Developer Handbook](https://developer.wordpress.org/plugins/)
- [WP-CLI Documentation](https://wp-cli.org/)
- [GitHub Codespaces Documentation](https://docs.github.com/en/codespaces)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## 📄 License

This project is licensed under the GPL-3.0 - see the LICENSE file for details.
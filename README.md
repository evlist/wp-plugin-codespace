<!--
SPDX-FileCopyrightText: 2025 Eric van der Vlist <vdv@dyomedea.com>

SPDX-License-Identifier: GPL-3.0-or-later OR MIT
-->

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
├── .cs_env                        # Local environment variables overriding .devcontainer/.cs_env
├── bootstrap-local.sh          # Local bootstrap script
├── .devcontainer/
│   ├── devcontainer.json       # VS Code devcontainer configuration
│   ├── docker-compose.yml      # Docker Compose services definition
│   ├── Dockerfile              # WordPress container with WP-CLI
│   ├── .cs_env                    # Environment variables (customizable)
│   └── bin/
│       ├── bootstrap-wp.sh     # Bootstrap: DB, Apache, WP core, symlinks, ends up calling the localbootstrap script
│       └── merge-env.sh        # Merge .cs_env files
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

All configuration is managed through `.devcontainer/.cs_env`:

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

To customize your environment, edit these values in the local .cs_env file before creating your codespace or rebuild after changes.

## 🧩 Optional: Local bootstrap script (LOCALBOOTSTRAP)

To keep project‑generic bootstrap logic separate from plugin‑specific steps, you can provide a local script that runs at the very end of `.devcontainer/bin/bootstrap-wp.sh`.

- Purpose: add site content, tweak settings, activate extra plugins/themes, etc., without modifying the shared bootstrap (e.g., skip creating the hello‑world post when debugging other plugins).
- Execution model: the script is sourced (not executed), so it runs in the same shell and inherits all variables and the `wp` function defined by the bootstrap. Errors are logged but do not abort provisioning.
- Where to declare: preferably in a workspace‑local `.cs_env` file at the repository root, which is merged into `.devcontainer/.cs_env` on startup.

Setup

1) Create your script in the repo (relative to workspace), e.g. `scripts/bootstrap-local.sh`:
```bash
#!/usr/bin/env bash
# Example: seed content and adjust options
log "Local bootstrap: seeding content"

# The `wp` function is available and already targets $DOCROOT as www-data
wp post create --post_type=post --post_status=publish \
  --post_title="Hello from local script" \
  --post_content="[local_hello_world name=\"Codespaces\"]" \
  --post_author=1 || true

# Example: activate additional plugins from your env
# wp plugin install query-monitor --activate || true
```

2) In your workspace root `.cs_env` file (not .devcontainer/.cs_env), set the relative path:
```env
# file: .cs_env (workspace root)
LOCALBOOTSTRAP=scripts/bootstrap-local.sh
```

3) Rebuild the container or restart the Codespace to run the local bootstrap at the end of provisioning.

Behavior details

- If `LOCALBOOTSTRAP` is unset: nothing happens.
- If set but the file isn’t found: a warning is logged and provisioning continues.
- If the script returns non‑zero: the status is logged and provisioning continues.
- Absolute paths are allowed; relative paths are resolved against `$WORKSPACE`.
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

## Credits

This plugin was inspired by examples and guidance from:

- [WordPress Plugin Developer Handbook](https://developer.wordpress.org/plugins/)
- [WordPress REST API Handbook](https://developer.wordpress.org/rest-api/)
- [Admin Bar API (`admin_bar_menu` / `add_node`)](https://developer.wordpress.org/reference/hooks/admin_bar_menu/)
- [Admin Notices (`admin_notices`)](https://developer.wordpress.org/reference/hooks/admin_notices/)
- [WP‑CLI Handbook and Commands Cookbook](https://make.wordpress.org/cli/handbook/) · [Commands cookbook](https://make.wordpress.org/cli/handbook/commands-cookbook/)
- [Hello Dolly plugin](https://wordpress.org/plugins/hello-dolly/) for a minimal plugin structure
- [WordPress Coding Standards](https://github.com/WordPress/WordPress-Coding-Standards)

Developed in GitHub Codespaces with assistance from GitHub Copilot.

## License

This project is dual-licensed:

- GPL-3.0-or-later OR
- MIT

You may choose either license. See the [LICENSE](LICENSE) file and the full texts in the LICENSES/ directory.

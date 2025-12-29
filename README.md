# wp-plugin-codespace

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=evlist/wp-plugin-codespace)

A complete GitHub Codespaces development environment for WordPress plugin debugging and development.

## 🚀 Quick Start

1. Click the "Open in GitHub Codespaces" badge above or go to the repository and click "Code" → "Codespaces" → "Create codespace on main"
2. Wait for the devcontainer to build and the WordPress installation to complete (this takes a few minutes on first run)
3. Once ready, you'll see a notification to open the WordPress site. Click it or navigate to the "Ports" tab and open port 8080
4. Access WordPress:
   - **Site URL**: `http://localhost:8080`
   - **Admin URL**: `http://localhost:8080/wp-admin`
   - **Username**: `admin`
   - **Password**: `admin`

## ✨ Features

This devcontainer provides a complete WordPress development environment with:

- **WordPress & MySQL**: Configurable versions via environment variables
- **WP-CLI**: Pre-installed for command-line WordPress management
- **Docker Compose**: Three-service architecture (workspace, wordpress, db)
- **Helper Scripts**: Easy access to WP-CLI and MySQL from the workspace
- **Automatic Setup**: Idempotent installer script completes WordPress configuration
- **Plugin Mounting**: Local plugin directory automatically mounted and activated
- **Sample Plugin**: "Local Hello World" plugin demonstrating WordPress features
- **Port Forwarding**: WordPress accessible via Codespaces preview (port 8080)

## 📁 Project Structure

```
.
├── .devcontainer/
│   ├── devcontainer.json       # VS Code devcontainer configuration
│   ├── docker-compose.yml      # Docker Compose services definition
│   ├── Dockerfile              # WordPress container with WP-CLI
│   ├── .env                    # Environment variables (customizable)
│   └── bin/
│       ├── wp.sh               # WP-CLI wrapper script
│       ├── db.sh               # MySQL client wrapper script
│       └── wp-install.sh       # WordPress installation script
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


## ⚠️ Important Notes

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

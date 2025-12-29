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
# WordPress Version
WP_VERSION=latest

# MySQL Version
MYSQL_VERSION=5.7

# Database Configuration
MYSQL_ROOT_PASSWORD=rootpassword
MYSQL_DATABASE=wordpress
MYSQL_USER=wordpress
MYSQL_PASSWORD=wordpress

# WordPress Configuration
WP_HOST_PORT=8080
WP_SITE_URL=http://localhost:8080
WP_TITLE=WordPress Plugin Development
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=admin
WP_ADMIN_EMAIL=admin@example.com
WP_LOCALE=en_US

# Additional Plugins (comma-separated)
WP_PLUGINS=loco-translate

# Local Plugin Configuration
PLUGIN_SLUG=local-hello-world
```

To customize your environment, edit these values before creating your codespace or rebuild after changes.

## 🛠️ Available Commands

### WP-CLI Commands
Execute WP-CLI commands in the WordPress container:

```bash
# Run any WP-CLI command
.devcontainer/bin/wp.sh [command]

# Examples:
.devcontainer/bin/wp.sh plugin list
.devcontainer/bin/wp.sh user list
.devcontainer/bin/wp.sh post create --post_title="Test Post" --post_status=publish
.devcontainer/bin/wp.sh local-hello-world greet "Developer"
```

### MySQL Commands
Execute MySQL commands in the database container:

```bash
# Run MySQL client
.devcontainer/bin/db.sh mysql -u wordpress -pwordpress wordpress

# Check database status
.devcontainer/bin/db.sh mysqladmin ping
```

### Docker Compose Commands
Manage the containers directly:

```bash
cd .devcontainer

# View logs
docker compose logs -f wordpress
docker compose logs -f db

# Restart services
docker compose restart wordpress

# Stop all services
docker compose down

# Rebuild and restart
docker compose up -d --build
```

## 🔌 Developing Your Plugin

1. **Create your plugin directory** in `plugins-src/`:
   ```bash
   mkdir plugins-src/my-plugin
   ```

2. **Update the `.env` file** to point to your plugin:
   ```bash
   PLUGIN_SLUG=my-plugin
   ```

3. **Rebuild the devcontainer**:
   - Press `F1` or `Ctrl+Shift+P`
   - Select "Codespaces: Rebuild Container"

4. **Start developing**: Your plugin will be automatically mounted and activated in WordPress

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

## 🐛 Troubleshooting

### WordPress not loading
```bash
# Check service status
cd .devcontainer && docker compose ps

# View WordPress logs
docker compose logs wordpress

# Restart services
docker compose restart
```

### Database connection issues
```bash
# Check database health
.devcontainer/bin/db.sh mysqladmin ping

# View database logs
cd .devcontainer && docker compose logs db
```

### Rebuild from scratch
```bash
# Stop and remove all containers and volumes
cd .devcontainer
docker compose down -v

# Rebuild and start
docker compose up -d --build

# Run installer again
./bin/wp-install.sh
```

## ⚠️ Important Notes

- **Development Only**: This environment is for development and testing only. Do not use in production.
- **Security**: Default credentials are weak and intended for local development only.
- **Performance**: First startup may take several minutes as Docker images are downloaded and WordPress is configured.
- **Persistence**: Database data is persisted in a Docker volume. Use `docker compose down -v` to reset completely.
- **Port 8080**: Ensure port 8080 is available, or change `WP_HOST_PORT` in `.env`.

## 📚 Additional Resources

- [WordPress Plugin Developer Handbook](https://developer.wordpress.org/plugins/)
- [WP-CLI Documentation](https://wp-cli.org/)
- [GitHub Codespaces Documentation](https://docs.github.com/en/codespaces)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

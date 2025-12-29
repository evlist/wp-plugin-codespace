# Single-container dev image with Apache, MariaDB, PHP, WP-CLI, and GitHub CLI
FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu

ENV DEBIAN_FRONTEND=noninteractive

# Apache + MariaDB + PHP + common extensions + prerequisites
RUN apt-get update && apt-get install -y \
    apache2 mariadb-server \
    php libapache2-mod-php php-mysql php-xml php-mbstring php-curl php-zip \
    curl jq less unzip ca-certificates gnupg && \
    a2enmod rewrite && \
    \
    # Install GitHub CLI (gh)
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && apt-get install -y gh && \
    \
    rm -rf /var/lib/apt/lists/*

# WP-CLI
RUN curl -fsSL -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp

# Apache conf: allow .htaccess in /var/www/html
RUN printf "<Directory /var/www/html>\n  AllowOverride All\n  Require all granted\n</Directory>\n" \
      > /etc/apache2/conf-available/wordpress.conf && \
    a2enconf wordpress

# Ensure docroot exists and owned by www-data
RUN mkdir -p /var/www/html && chown -R www-data:www-data /var/www/html

# No bootstrap script copied; it lives in the workspace and runs via postStartCommand.
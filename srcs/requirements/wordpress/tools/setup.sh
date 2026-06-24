#!/bin/bash
set -e

WP_PATH="/var/www/html"

# Read password from secret file
if [ -n "$WORDPRESS_DB_PASSWORD_FILE" ] && [ -f "$WORDPRESS_DB_PASSWORD_FILE" ]; then
    WORDPRESS_DB_PASSWORD=$(cat "$WORDPRESS_DB_PASSWORD_FILE")
    export WORDPRESS_DB_PASSWORD
fi

if [ -n "$WORDPRESS_USER_PASSWORD_FILE" ] && [ -f "$WORDPRESS_USER_PASSWORD_FILE" ]; then
    WORDPRESS_USER_PASSWORD=$(cat "$WORDPRESS_USER_PASSWORD_FILE")
fi

if [ -n "$WORDPRESS_ADMIN_PASSWORD_FILE" ] && [ -f "$WORDPRESS_ADMIN_PASSWORD_FILE" ]; then
    WORDPRESS_ADMIN_PASSWORD=$(cat "$WORDPRESS_ADMIN_PASSWORD_FILE")
fi

echo "Setting up WordPress..."

# Download and configure WordPress if not present
if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "Downloading WordPress..."
    wget -q https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz
    tar -xzf /tmp/wordpress.tar.gz -C /tmp
    rm /tmp/wordpress.tar.gz

    # Copy only missing files (avoid overwriting existing content)
    cp -rn /tmp/wordpress/* "$WP_PATH" || true
    rm -rf /tmp/wordpress

    # Fetch security salts from WordPress API
    WP_SALTS=$(wget -qO- https://api.wordpress.org/secret-key/1.1/salt/)

    # Create wp-config.php
    cat > "$WP_PATH/wp-config.php" << EOF
<?php
define('DB_NAME', '${WORDPRESS_DB_NAME}');
define('DB_USER', '${WORDPRESS_DB_USER}');
define('DB_PASSWORD', '${WORDPRESS_DB_PASSWORD}');
define('DB_HOST', '${WORDPRESS_DB_HOST}');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

\$table_prefix = '${WORDPRESS_TABLE_PREFIX:-wp_}';

${WP_SALTS}

define('WP_DEBUG', false);

// Redis configuration
define('WP_REDIS_HOST', 'redis');
define('WP_REDIS_PORT', 6379);
define('WP_REDIS_TIMEOUT', 1);
define('WP_REDIS_READ_TIMEOUT', 1);
define('WP_REDIS_DATABASE', 0);

if ( !defined('ABSPATH') )
    define('ABSPATH', __DIR__ . '/');

require_once ABSPATH . 'wp-settings.php';
EOF

    # Set secure permissions
    find "$WP_PATH" -type d -exec chmod 750 {} \;
    find "$WP_PATH" -type f -exec chmod 640 {} \;
    chown -R www-data:www-data "$WP_PATH"

    echo "WordPress files prepared. Installing/Configuring via WP-CLI..."
    
    # Wait for MariaDB to be ready
    until mysqladmin -h mariadb -u "${WORDPRESS_DB_USER}" -p"${WORDPRESS_DB_PASSWORD}" ping >/dev/null 2>&1; do
        echo "Waiting for MariaDB..."
        sleep 2
    done

    # Finish WordPress installation
    wp core install --allow-root \
        --url="${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WORDPRESS_ADMIN_USER:-admin}" \
        --admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
        --admin_email="${WORDPRESS_ADMIN_EMAIL:-admin@example.com}" \
        --path="$WP_PATH"

    # Install and enable Redis plugin
    wp plugin install redis-cache --activate --allow-root --path="$WP_PATH"
    wp redis enable --allow-root --path="$WP_PATH"

    echo "WordPress setup complete."
else
    echo "WordPress already initialized, skipping setup."
fi

# Wait for MariaDB to be ready (required to interact with DB via WP-CLI)
until mysqladmin -h mariadb -u "${WORDPRESS_DB_USER}" -p"${WORDPRESS_DB_PASSWORD}" ping >/dev/null 2>&1; do
    echo "Waiting for MariaDB..."
    sleep 2
done

# Create regular second user if missing
if ! wp user get "${WORDPRESS_USER}" --allow-root --path="$WP_PATH" >/dev/null 2>&1; then
    echo "Creating second WordPress user..."
    wp user create "${WORDPRESS_USER}" "${WORDPRESS_USER_EMAIL}" \
        --role=author \
        --user_pass="${WORDPRESS_USER_PASSWORD}" \
        --allow-root \
        --path="$WP_PATH"
fi

echo "Starting PHP-FPM..."
exec php-fpm8.2 -F

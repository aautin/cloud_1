#!/bin/sh

#
# Set bash options:
# -e = exit if a command fails
# -u = exit if an environment variable isn't set
set -eu

#
# Initially, the /var/www/html volume is empty and overrides "wp-load.php".
# We take its put it back from /usr/src/wordpress.
# WordPress loads wp-load.php as part of its normal requests bootstrap.
#
if [ ! -f /var/www/html/wp-load.php ]; then
    cp -a /usr/src/wordpress/. /var/www/html/
    chown -R www-data:www-data /var/www/html
fi

#
# Create the wp-config.php file if it doesn't exist.
# It sets up the database connection.
#
until wp --allow-root core config \
    --dbname="$MYSQL_DATABASE" \
    --dbuser="$MYSQL_USER" \
    --dbpass="$MYSQL_PASSWORD" \
    --dbhost="db" \
    --path=/var/www/html \
    --skip-check \
    --force; do
    sleep 3
done

#
# Add a snippet to wp-config.php to handle HTTPS behind a reverse proxy.
#
if ! grep -q "HTTP_X_FORWARDED_PROTO" /var/www/html/wp-config.php; then
    sed -i '/require_once ABSPATH/i\
if (isset($_SERVER["HTTP_X_FORWARDED_PROTO"]) && $_SERVER["HTTP_X_FORWARDED_PROTO"] === "https") {\
    $_SERVER["HTTPS"] = "on";\
}' /var/www/html/wp-config.php
fi

#
# Set up wordpress admin user and wordpress url and title
#
if ! wp --allow-root core is-installed --path=/var/www/html; then
    wp --allow-root core install \
        --path=/var/www/html \
        --url="https://$APP_DOMAIN/" \
        --title="$WORDPRESS_TITLE" \
        --admin_user="$WORDPRESS_ADMIN_USER" \
        --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
        --admin_email="$WORDPRESS_ADMIN_EMAIL" \
        --skip-email
fi

exec apache2-foreground
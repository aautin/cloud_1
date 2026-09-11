#!/bin/sh

if ! command -v wp >/dev/null 2>&1; then
	curl -fsSL -o /tmp/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x /tmp/wp-cli.phar
	mv /tmp/wp-cli.phar /usr/local/bin/wp
fi

mkdir -p /var/www/html
cd /var/www/html

if [ ! -f wp-includes/version.php ]; then
	wp core download --allow-root
fi

if [ ! -f wp-config.php ]; then
	wp config create --dbname="$DB_NAME" --dbuser="$DB_USERNAME" --dbpass="$DB_PASSWORD" --allow-root --dbhost=mariadb:3306
fi

until wp db check --allow-root >/dev/null 2>&1; do
	sleep 2
done

if ! wp core is-installed --allow-root >/dev/null 2>&1; then
	wp core install --url="aautin.42.fr" --title="TEST" --admin_user="$WP_ADMIN_USERNAME" --admin_password="$WP_ADMIN_PASSWORD" --admin_email="$WP_ADMIN_EMAIL" --allow-root
fi

exec php-fpm8.2 --nodaemonize

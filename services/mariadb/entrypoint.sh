#!/bin/sh

#mariadb installation
service mariadb start && mysql_secure_installation << END

n
if [ -f /var/lib/mysql/.cloud1-initialized ]; then
	exec mariadbd
fi

service mariadb start

mariadb << END
CREATE DATABASE IF NOT EXISTS $DB_NAME;
CREATE USER IF NOT EXISTS '$DB_ADMIN_USERNAME'@'$DB_ADMIN_HOST' IDENTIFIED BY '$DB_ADMIN_PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO '$DB_ADMIN_USERNAME'@'$DB_ADMIN_HOST';
CREATE USER IF NOT EXISTS '$DB_USERNAME'@'$DB_HOST' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USERNAME'@'$DB_HOST';
FLUSH PRIVILEGES;
END

touch /var/lib/mysql/.cloud1-initialized
service mariadb stop
exec mariadbd
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USERNAME'@'$DB_HOST';

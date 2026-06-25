#!/bin/bash

set -e

echo "Initializing MariaDB..."

# Initialize MySQL data directory if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

# Configure database and user if the target database doesn't exist
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "Starting temp MariaDB server (without networking)..."
    mysqld --skip-networking --skip-grant-tables --socket=/run/mysqld/mysqld.sock --user=mysql &
    pid="$!"

    echo "Waiting for MariaDB to be ready..."
    until mysqladmin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; do
        sleep 1
    done
    echo "MariaDB is ready!"

    # Read passwords from secret files if provided
    if [ -n "$MYSQL_ROOT_PASSWORD_FILE" ] && [ -f "$MYSQL_ROOT_PASSWORD_FILE" ]; then
        MYSQL_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")
    fi

    if [ -n "$MYSQL_PASSWORD_FILE" ] && [ -f "$MYSQL_PASSWORD_FILE" ]; then
        MYSQL_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")
    fi

    echo "Setting up SQL..."
    mysql --socket=/run/mysqld/mysqld.sock -u root << EOF
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    echo "Shutting down temporary MariaDB..."
    mysqladmin --socket=/run/mysqld/mysqld.sock -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    
    # Wait for shutdown
    wait "$pid" || true
    echo "Initialization complete."
else
    echo "MariaDB database already setup, skipping SQL config."
fi

echo "Starting MariaDB..."
exec mysqld --user=mysql --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock
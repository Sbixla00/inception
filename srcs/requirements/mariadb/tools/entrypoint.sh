#!/bin/sh
set -eu


set -a
. /run/secrets/credentials
. /run/secrets/db_password
. /run/secrets/db_root_password
set +a

# Required environment variables
: "${MYSQL_DATABASE:?}"
: "${MYSQL_USER:?}"
: "${MYSQL_PASSWORD:?}"
: "${MYSQL_ROOT_PASSWORD:?}"

# Create needed directories and permissions
mkdir -p /run/mysqld /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql

# First run: initialize database
if [ ! -d /var/lib/mysql/mysql ]; then
  echo "Initializing MariaDB..."
  mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/dev/null

  echo "Starting temporary MariaDB..."
  mariadbd --user=mysql --datadir=/var/lib/mysql \
    --skip-networking \
    --socket=/run/mysqld/mysqld.sock &
  pid="$!"

  # Wait for MariaDB (max 30s)
  for i in $(seq 1 30); do
    if mariadb-admin --socket=/run/mysqld/mysqld.sock ping --silent; then
      break
    fi
    sleep 1
  done

  if ! mariadb-admin --socket=/run/mysqld/mysqld.sock ping --silent; then
    echo "MariaDB init failed"
    kill "$pid"
    exit 1
  fi

  echo "Creating database and user..."
  mariadb --socket=/run/mysqld/mysqld.sock <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`
  CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
SQL

  echo "Stopping temporary MariaDB..."
  mariadb-admin --socket=/run/mysqld/mysqld.sock \
    -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown
  wait "$pid"
fi

echo "Starting MariaDB..."
exec mariadbd --user=mysql --datadir=/var/lib/mysql

#!/bin/sh
set -eu

# ---------- Required non-secret config ----------
: "${DOMAIN_NAME:?}"
: "${WP_TITLE:?}"
: "${WP_ADMIN_USER:?}"
: "${WP_ADMIN_EMAIL:?}"
: "${WP_USER:?}"
: "${WP_USER_EMAIL:?}"

: "${MYSQL_DATABASE:?}"
: "${MYSQL_USER:?}"

# ---------- Passwords from env (your choice) ----------
# TODO: Make sure these are set via env_file: .env in docker-compose.yml
: "${MYSQL_PASSWORD:?}"
: "${MYSQL_ROOT_PASSWORD:?}"
: "${WP_ADMIN_PASSWORD:?}"
: "${WP_USER_PASSWORD:?}"

WP_PATH="/var/www/html"

# ---------- Wait for MariaDB ----------
# Uses the DB user you created (MYSQL_USER/MYSQL_PASSWORD)
until mysqladmin ping -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent; do
  echo "Waiting for MariaDB..."
  sleep 2
done

# ---------- Download WordPress core (only if missing) ----------
if [ ! -f "${WP_PATH}/wp-settings.php" ]; then
  wp core download --path="${WP_PATH}" --allow-root
fi

# ---------- Create wp-config.php (only if missing) ----------
if [ ! -f "${WP_PATH}/wp-config.php" ]; then
  wp config create \
    --path="${WP_PATH}" \
    --dbname="${MYSQL_DATABASE}" \
    --dbuser="${MYSQL_USER}" \
    --dbpass="${MYSQL_PASSWORD}" \
    --dbhost="mariadb" \
    --allow-root
fi

# ---------- Install WordPress + create users (only once) ----------
if ! wp core is-installed --path="${WP_PATH}" --allow-root; then
  wp core install \
    --path="${WP_PATH}" \
    --url="https://${DOMAIN_NAME}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email \
    --allow-root

  # Second user (non-admin)
  wp user create \
    "${WP_USER}" "${WP_USER_EMAIL}" \
    --user_pass="${WP_USER_PASSWORD}" \
    --role="author" \
    --path="${WP_PATH}" \
    --allow-root
fi

# ---------- Start php-fpm in foreground ----------
exec php-fpm83 -F

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
: "${MYSQL_PASSWORD:?}"
: "${MYSQL_ROOT_PASSWORD:?}"
: "${WP_ADMIN_PASSWORD:?}"
: "${WP_USER_PASSWORD:?}"

WP_PATH="/var/www/html"

# ---------- Wait for MariaDB ----------
until mysqladmin ping -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent; do
  echo "Waiting for MariaDB..."
  sleep 2
done

# ---------- Wait for Redis ----------
until nc -z redis 6379; do
  echo "Waiting for Redis..."
  sleep 2
done

# ---------- Download WordPress core (only if missing) ----------
if [ ! -f "${WP_PATH}/wp-settings.php" ]; then
  wp core download  --allow-root
fi

# ---------- Create wp-config.php (only if missing) ----------
if [ ! -f "${WP_PATH}/wp-config.php" ]; then
  wp config create \
     \
    --dbname="${MYSQL_DATABASE}" \
    --dbuser="${MYSQL_USER}" \
    --dbpass="${MYSQL_PASSWORD}" \
    --dbhost="mariadb" \
    --allow-root
  
  # Add Redis configuration to wp-config.php
  wp config set WP_REDIS_HOST "redis" --allow-root 
  wp config set WP_REDIS_PORT "6379" --raw --allow-root 
  wp config set WP_CACHE "true" --raw --allow-root 
fi

# ---------- Install WordPress + create users (only once) ----------
if ! wp core is-installed  --allow-root; then
  wp core install \
     \
    --url="https://${DOMAIN_NAME}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email \
    --allow-root
fi

  # Second user (non-admin)
if ! wp user get "${WP_USER}"  --allow-root >/dev/null 2>&1; then
  wp user create \
    "${WP_USER}" "${WP_USER_EMAIL}" \
    --user_pass="${WP_USER_PASSWORD}" \
    --role="author" \
     \
    --allow-root
fi

# ---------- Install and activate Redis Object Cache plugin ----------
if ! wp plugin is-installed redis-cache  --allow-root; then
  wp plugin install redis-cache --activate  --allow-root
fi

# Enable Redis cache if not already enabled
if ! wp redis status  --allow-root 2>/dev/null | grep -q "Connected"; then
  wp redis enable  --allow-root || true
fi

# ---------- Start php-fpm in foreground ----------
exec php-fpm83 -F

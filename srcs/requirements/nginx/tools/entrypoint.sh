#!/bin/sh
set -eu

set -a
. /run/secrets/credentials
. /run/secrets/db_password
. /run/secrets/db_root_password
set +a


DOMAIN="aayache.42.fr"
CERT="/etc/nginx/ssl/nginx.crt"
KEY="/etc/nginx/ssl/nginx.key"

if [ ! -f "$CERT" ] || [ ! -f "$KEY" ]; then
  openssl req -x509 -nodes -newkey rsa:2048 \
    -keyout "$KEY" \
    -out "$CERT" \
    -days 365 \
    -subj "/C=MA/ST=Casablanca/L=Casablanca/O=Inception/OU=Dev/CN=${DOMAIN}" \
    -addext "subjectAltName=DNS:${DOMAIN}"
fi

exec nginx -g "daemon off;"


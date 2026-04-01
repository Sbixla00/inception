#!/bin/sh
set -eu


set -a
. /run/secrets/credentials
. /run/secrets/db_password
. /run/secrets/db_root_password
set +a

: "${FTP_USER:?}"
: "${FTP_PASSWORD:?}"
: "${PASV_ADDRESS:?FTP server requires PASV_ADDRESS to be set}"

FTP_ROOT="/var/www/html"

mkdir -p "$FTP_ROOT"

if ! id "$FTP_USER" >/dev/null 2>&1; then
  adduser -D -h "$FTP_ROOT" -s /sbin/nologin "$FTP_USER"
fi

echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd

if [ -n "$PASV_ADDRESS" ]; then
  echo "pasv_address=${PASV_ADDRESS}" >> /etc/vsftpd/vsftpd.conf
else
  echo "ERROR: PASV_ADDRESS is empty" >&2
  exit 1
fi

chown -R "$FTP_USER:$FTP_USER" "$FTP_ROOT"
chmod -R 755 "$FTP_ROOT"

touch /var/log/vsftpd.log

echo "FTP user:     $FTP_USER"
echo "FTP root:     $FTP_ROOT"
echo "PASV port:    21100"
echo "PASV address: $PASV_ADDRESS"

exec /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf

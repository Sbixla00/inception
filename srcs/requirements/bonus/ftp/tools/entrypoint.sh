#!/bin/sh
set -eu

: "${FTP_USER:?}"
: "${FTP_PASSWORD:?}"

# Optional env vars
FTP_ROOT="${FTP_ROOT:-/var/www/html}"
PASV_ADDRESS="${PASV_ADDRESS:-}"
ENABLE_TLS="${ENABLE_TLS:-0}"     # 0/1

mkdir -p "$FTP_ROOT"

# Create user if not exists
if ! id "$FTP_USER" >/dev/null 2>&1; then
  adduser -D -h "$FTP_ROOT" -s /sbin/nologin "$FTP_USER"
fi

# Set password (always reset to match env)
echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd

chown -R "$FTP_USER:$FTP_USER" "$FTP_ROOT" || true
chmod -R 755 "$FTP_ROOT" || true

if [ -n "$PASV_ADDRESS" ]; then
  if grep -q '^pasv_address=' /etc/vsftpd/vsftpd.conf; then
    sed -i "s|^pasv_address=.*|pasv_address=${PASV_ADDRESS}|" /etc/vsftpd/vsftpd.conf
  else
    echo "pasv_address=${PASV_ADDRESS}" >> /etc/vsftpd/vsftpd.conf
  fi
fi

# Log file
touch /var/log/vsftpd.log

echo "FTP user: $FTP_USER"
echo "FTP root: $FTP_ROOT"
echo "PASV port: 21100"
echo "PASV address: ${PASV_ADDRESS:-'(not set)'}"
echo "TLS enabled: $ENABLE_TLS"

exec /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf

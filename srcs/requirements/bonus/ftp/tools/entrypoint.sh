#!/bin/sh
set -eu

: "${FTP_USER:?}"
: "${FTP_PASS:?}"

# Create user if not exists
if ! id "$FTP_USER" >/dev/null 2>&1; then
  adduser -D -h /var/www/html -s /sbin/nologin "$FTP_USER"
  echo "$FTP_USER:$FTP_PASS" | chpasswd
fi

# Ensure correct ownership so FTP can write
chown -R "$FTP_USER":"$FTP_USER" /var/www/html || true

# Write pasv_address dynamically if provided
# if [ -n "${FTP_PASV_ADDRESS:-}" ]; then
#   # replace existing or append
#   if grep -q '^pasv_address=' /etc/vsftpd/vsftpd.conf; then
#     sed -i "s|^pasv_address=.*|pasv_address=${FTP_PASV_ADDRESS}|" /etc/vsftpd/vsftpd.conf
#   else
#     echo "pasv_address=${FTP_PASV_ADDRESS}" >> /etc/vsftpd/vsftpd.conf
#   fi
# fi

exec /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf

#!/bin/sh
set -eu

# Create log directory if it doesn't exist
mkdir -p /var/log/vsftpd

# Update FTP user password from environment variable if provided
if [ -n "${FTP_USER:-}" ] && [ -n "${FTP_PASSWORD:-}" ]; then
    echo "Setting up FTP user: ${FTP_USER}"
    
    # Create user if it doesn't exist
    if ! id "${FTP_USER}" >/dev/null 2>&1; then
        adduser -D -h /var/ftp "${FTP_USER}"
    fi
    
    # Set password
    echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd
fi

echo "Starting vsftpd FTP server..."
exec /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf

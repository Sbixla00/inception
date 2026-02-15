echo "FTP Server starting..."

# Create necessary directories
mkdir -p /var/log/vsftpd /var/run/vsftpd /var/ftp

# Update FTP user password from environment if provided
if [ -n "${FTP_USER:-}" ] && [ -n "${FTP_PASSWORD:-}" ]; then
    echo "Setting up FTP user: ${FTP_USER}"
    
    # Create user if doesn't exist
    if ! id "${FTP_USER}" >/dev/null 2>&1; then
        adduser -D -h /var/ftp "${FTP_USER}"
    fi
    
    # Set password
    echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd
    echo "Password updated for ${FTP_USER}"
fi

# Ensure ftpuser can access WordPress directory
if [ -d /var/www/html ]; then
    chown -R ftpuser:ftpuser /var/www/html 2>/dev/null || true
fi

# Find vsftpd binary
VSFTPD=$(which vsftpd)
if [ -z "$VSFTPD" ]; then
    echo "ERROR: vsftpd not found!"
    exit 1
fi

echo "Found vsftpd at: $VSFTPD"
echo "Starting vsftpd FTP server (plain FTP, no SSL)..."

# Start vsftpd
exec $VSFTPD /etc/vsftpd/vsftpd.conf
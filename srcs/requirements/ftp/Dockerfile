FROM alpine:3.22

RUN apk add --no-cache vsftpd openssl tini

# Create FTP user and directory
RUN adduser -D -h /var/ftp ftpuser \
 && echo "ftpuser:ftppassword" | chpasswd \
 && mkdir -p /var/ftp /var/log/vsftpd

# Generate self-signed SSL certificate for FTPS
RUN mkdir -p /etc/ssl/private \
 && openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/vsftpd.key \
    -out /etc/ssl/certs/vsftpd.crt \
    -subj "/C=MA/ST=BeniMellal/L=Khouribga/O=42/CN=ftp.localhost"

COPY conf/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 21 21100-21110

ENTRYPOINT ["/sbin/tini","--","/entrypoint.sh"]

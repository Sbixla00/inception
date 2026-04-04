FROM alpine:3.22

RUN apk add --no-cache vsftpd openssl

# copy config + entrypoint
COPY conf/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 21 21100

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
